`timescale 1ns / 1ps

///////////////////////////////////BRANCH HISTORY TABLE SCHEME//////////////////////////////////
// the reason behind the choice of using a BHT with just one level prediction is due to the hardware requirements and warm-up
//period associated with two level prediction schemes. Although the prediction is higher for such schemes, the time needed
// to train all the tables and patterns would be too damaging for the short test programs that I plan on using. A BHT 
// on the other hand, has fairly reasonable prediction accuracy (80% - 90%) and it is also quite fast to train. To speed up
// the training part, I have decided to develop 2 bit saturating counters with taken and not taken shortcuts, which will be 
// implemented using FSMs.

module Prediction(
            
        input logic [31:0] instruction_pls, PC4,
        input logic clk, reset,
        input logic [1:0] taken,
        output logic [31:0] correct_pc, NPC4_f,
        output logic wrong, prediction, jump, kill_decode_now, branch, hlt       
    );
    
        logic [4:0] BHT_INDEX, old_addr, addr_temp;
        logic kill_decode;
        logic [1:0] BHT [0:2**5-1];
        logic [5:0] opcode;
        logic [1:0] state, old_state, state_temp, updated;                                       //temporary storage so that the branch can
        logic [31:0] saved_PC4, saved_PC4_temp, saved_NPC4_temp, saved_NPC4, sign_imm_f;                                 // be in sync with the taken signal.
        
        assign BHT_INDEX = {instruction_pls[28:26], instruction_pls[21], instruction_pls[16]};           // to index the table I took the most useful bits within the instruction, in the hope to reduce
        assign opcode = instruction_pls[31:26];                                                                     
        assign sign_imm_f = 32'(signed'(instruction_pls[15:0]));             //Sign extend
                                                                     
        assign state = BHT [BHT_INDEX];                                                                  

        
        always_ff@(posedge clk, posedge reset)
        begin
            if(reset)                           
                BHT <= '{default:2'b01}; // when reset occurs both states need to be set to weak not taken.
            else
            begin
                state_temp <= state;
                old_state <= state_temp;
                addr_temp <= BHT_INDEX;  // Due to the two cycle latency between prediction and actual result, the current BHT address and value are saved
                old_addr <= addr_temp;   // in registers. The third register is inserted to avoid racin
                saved_PC4_temp <= PC4;
                saved_PC4 <= saved_PC4_temp;
                saved_NPC4_temp <= NPC4_f;
                saved_NPC4 <= saved_NPC4_temp;
                kill_decode_now <= kill_decode;  
                BHT[old_addr] <= updated;              
            end
         end  


        always_comb
        begin            
            if((clk == 0) & (branch)) //During the negative part reading will take place ONLY for bracnh instructions
            begin
                prediction = 0;
                case(state)
                    2'b00:                         //Strong not taken
                        prediction = 0;        
                    2'b01:                         //Weak not taken
                        prediction = 0;
                    2'b10:                         //Weak taken
                        prediction = 1;
                    2'b11:                         //Strong taken
                        prediction = 1;                    
                default:                       //Default is not taken
                        prediction = 0;
                endcase
            end            
                        
            else if (clk == 1) //During the positive part writing will take place. This is in order to make sure that the updated 
            begin               //value can be read in time if necessary.
                kill_decode = 0;
                wrong = 0; 
            case(old_state)
                2'b01:       //Weak not taken
                    begin
                    if(taken == 2'b01)
                        begin
                        updated = 2'b11;
                        wrong = 1;
                        kill_decode = 1;
                        correct_pc = saved_NPC4; 
                        end                       
                    else if(taken == 2'b00)
                        updated = 2'b00;              // in this FSM the fast acting hysteresis is a result of the jump                                                           
                    else                                     // from weak to strong without middle steps that would slow down the training procedure 
                        updated = BHT[old_addr]; 
                    end                                                           
                     

                2'b10:       //Weak taken
                    begin
                    if(taken == 2'b00)
                        begin
                        updated  = 2'b00;
                        wrong = 1;
                        kill_decode = 1;
                        correct_pc = saved_PC4;                        
                        end
                    else if(taken == 2'b01)
                        updated = 2'b11; 
                    else
                        updated  = BHT[old_addr]; 
                    end

                2'b11: //strong taken
                    begin
                    if(taken == 2'b00)
                        begin
                        updated = 2'b10;
                        wrong = 1;
                        kill_decode = 1;
                        correct_pc = saved_PC4; 
                        end 
                    else
                        BHT[old_addr] = 2'b11;                                              
                    end

              default: //strong not taken
                    begin
                    if(taken == 2'b01)
                        begin
                        updated = 2'b01;
                        wrong = 1;
                        kill_decode = 1;
                        correct_pc = saved_NPC4;
                        end
                    else
                        updated = 2'b00;
                    end                                                                              
              endcase 
             end 
         end                                                                

        always_comb
        begin
            hlt = 0;            
            case(opcode) 
                           
            6'h3C:                          //HLT is inserted here to immediately stop the PC
                 begin
                 hlt = 1;
                 end 
                             
             6'h02:                          //JUMP
                 begin
                 branch = 0;
                 jump = 1;
                 NPC4_f = {PC4[31:28],instruction_pls[25:0], 2'b00}; 
                 end 

            6'h03:                          //JUMP&LINK
                 begin
                 branch = 0;
                 jump = 1;
                 NPC4_f = {PC4[31:28],instruction_pls[25:0], 2'b00}; 
                 end 
                 
    6'h01, 6'h04, 6'h05, 6'h06, 6'h07:      //All other branches
                 begin
                 branch = 1;
                 jump = 0;
                 NPC4_f = PC4 + {sign_imm_f, 2'b00}; 
                 end
                                  
            default:
                 begin
                 jump = 0;
                 branch = 0;
                 NPC4_f = 32'b0;                  
                 end
           endcase
        end 
endmodule
