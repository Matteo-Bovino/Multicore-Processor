`timescale 1ns / 1ps


module Control_Unit(
        input logic prediction,
        input logic [31:0] instruction, PC4_f,
        output logic [31:0] zero_imm_d, upper_imm_d, sign_imm_d,
        output logic [4:0] shamt_d, wr_reg_addr_d, rs, rt,
        output logic [31:0] PC4_d, NPC4_d,
        output logic [5:0] alu_control,
        output logic [1:0] alu_src, mem_to_reg,
        output logic branch, jump, wr_reg_en_d, link_d, mem_wr, hlt, NOP, sign_zero_ext, store_hb,
        output logic beq, bne, blez, bgtz, bgez, bltz, div, overflow, mult, mfhi, mflo, mthi, mtlo      
    );
        logic [5:0] opcode, funct;
        assign opcode = instruction [31:26];
        assign rs = instruction [25:21];               
        assign rt = instruction [20:16];
        assign rd = instruction [15:11];
        assign funct = instruction [5:0];
        assign sign_imm_d = 32'(signed'(instruction [15:0]));             //Sign extend
        assign zero_imm_d = {16'b0 , instruction [15:0]};                //Zero extend
        assign upper_imm_d = {(instruction [15:0]), 16'b0};                 
        assign shamt_d = instruction [10:6];    
        assign PC4_d = PC4_f;                             
        
        always_comb
        begin
        alu_src = 2'b00;
        alu_control = 6'b111111;            
        wr_reg_en_d = 1;
        overflow = 1;                   // overflow is active high
        mem_wr = 0; 
        mult = 0;
        mthi = 0;
        mtlo = 0;
        mfhi = 0;
        mflo = 0;
        div = 0;       
        jump = 0;
        branch = 0;
        hlt = 0;
        mem_to_reg = 2'b00;
        link_d = 0;
        NOP = 0;
        sign_zero_ext = 0 ;
        store_hb = 2'b00 ;         
        case(opcode)       

///////////////////////////////////////////////////MEMORY OPERATIONS/////////////////////////////////////////////////////////////////

            6'h20:                          //Load Byte LB instruction
                begin
                alu_control = 6'b000010;
                mem_to_reg = 11;
                alu_src = 01;
                end
                
            6'h24:                          //Load Byte Unsigned LBU instruction
                begin
                alu_control = 6'b000010;
                mem_to_reg = 11;
                alu_src= 01;
                sign_zero_ext = 1 ;
                end 
                
            6'h21:                          //Load Halfword LH instruction
                begin
                alu_control = 6'b000010;
                mem_to_reg = 10;
                alu_src= 01;                
                wr_reg_en_d = 1;
                end

            6'h25:                          //Load Halfword Unsigned LHU instruction
                begin
                alu_control = 6'b000010;
                mem_to_reg = 10;
                wr_reg_en_d= 1; 
                overflow = 0;
                alu_src= 01;                               
                sign_zero_ext = 1 ;
                end 

            6'h28:                          //Store Byte SB instruction
                begin
                alu_control = 6'b000010;
                mem_wr = 1;
                wr_reg_en_d = 0;
                alu_src= 01;     
                store_hb = 00;                                                                              
                end 

            6'h29:                          //Store Halfword SH instruction
                begin
                alu_control = 6'b000010;
                mem_wr = 1;
                wr_reg_en_d = 0;                
                alu_src= 01;
                store_hb = 01;                                                                              
                end                                               
                               
            6'h23:                          //Load
                begin
                alu_control = 6'b000010;
                mem_to_reg = 01;
                alu_src= 01;                
                end
                
            6'h2b:                          //Store
                begin
                alu_control = 6'b000010;
                mem_to_reg = 1;
                mem_wr = 1;
                alu_src = 01;
                store_hb = 11;                                    
                end                                            
                    
///////////////////////////////////////////////////CONTROL FLOW OPERATIONS/////////////////////////////////////////////////////////////////

            6'h02:                          //JUMP
                 begin
                 branch = 1;
                 NOP = 1;                                         
                 NPC4_d = {PC4_d[31:28],instruction [25:0], 2'b00}; 
                 wr_reg_en_d = 0;                                          
                 end 
                                         
            6'h03:                          //JUMP&LINK
                 begin
                 branch = 1;                // CHANGEEEEEE DONE
                 NOP = 1;                   // CHANGEEEEE DONE
                 NPC4_d = {PC4_d[31:28],instruction [25:0], 2'b00}; 
                 link_d = 1;               
                 end 
                                    
            6'h04:               //beq 
                begin
                NPC4_d = PC4_d + {sign_imm_d, 2'b00}; 
                NOP = 1;
                branch = (prediction) ? 1 : 0;
                beq = 1;
                wr_reg_en_d = 0;                
                alu_control = 6'b010010;
                end

            6'h05:               // bne 
                begin
                NPC4_d = PC4_d + {sign_imm_d, 2'b00}; 
                NOP = 1;
                branch = (prediction) ? 1 : 0;
                bne = 1;
                wr_reg_en_d = 0;                                
                alu_control = 6'b010010;
                end

            6'h07:               //blez
                begin
                NPC4_d = PC4_d + {sign_imm_d, 2'b00}; 
                NOP = 1;
                branch = (prediction) ? 1 : 0;
                blez = 1;
                wr_reg_en_d = 0;
                alu_control = 6'b010010;
                end

            6'h06:               //bgtz
                begin
                NPC4_d = PC4_d + {sign_imm_d, 2'b00}; 
                NOP = 1;
                branch = (prediction) ? 1 : 0;
                bgtz = 1;
                wr_reg_en_d = 0;
                alu_control = 6'b010010;
                end
                                                               
            6'h01:                          //various branches identified using the RT field
                begin
                NPC4_d = PC4_d + {sign_imm_d, 2'b00};
                NOP = 1; 
                alu_control = 6'b010010;
                wr_reg_en_d = 1;
                branch = (prediction) ? 1 : 0;
                case(rt)                
                   6'h11:                 //bgezal LIIIIIIIIIIIIINK
                       begin
                       link_d = 1;           // r31 is going to get the pc  
                       bgez = 1;
                       end                     
                   6'h10:                 //bltzal
                       begin
                       link_d = 1;         // r31 = pc;        
                       bltz = 1; 
                       end 
                   6'h01: 
                       begin
                       bgez = 1;          //bgez with no linking
                       wr_reg_en_d = 0; 
                       end
                   default: 
                        begin
                        bltz = 1;
                        link_d = 0;         //bltz with no linking 
                        wr_reg_en_d = 0; 
                        end
                 endcase                       
                end                              
                
///////////////////////////////////////////////////R-TYPE OPERATIONS/////////////////////////////////////////////////////////////////
                
           6'h00:
                begin
                wr_reg_en_d = 1;
                case(funct)
                    6'h20:                              //ADD 
                            begin
                            alu_control = 6'b000010;
                            end
                    6'h21:                              //ADDU
                            begin
                            alu_control = 6'b000010;
                            overflow = 0;
                            end                            
                    6'h24:                                  //AND
                            begin
                            alu_control = 6'b000000;
                            end 
                    6'h22:                                  //SUB
                            begin
                            alu_control = 6'b010010;
                            alu_src = 00;
                            end                         
                    6'h23:                                  //SUBU
                            begin
                            alu_control = 6'b010010;
                            alu_src = 00;
                            overflow = 0;
                            end  
                    6'h26:                                  //XOR
                            begin
                            alu_control = 6'b000101;
                            alu_src = 00;
                            end                                                
                  default://6'h2A:                                  //SLT
                            begin
                            alu_control = 6'b010011;
                            alu_src = 00;
                            end 
                    6'h2B:                                  //SLTU
                            begin
                            alu_control = 6'b010011;
                            alu_src = 00;
                            overflow = 0;
                            end                                                                                
                    6'h27:                                  //NOR switch result of OR op.
                            begin
                            alu_control = 6'b000110;
                            alu_src = 00;
                            end 
                    6'h25:                                   //OR operation       
                            begin
                            alu_control = 6'b000001;
                            alu_src = 00;
                            end 
                    6'h00:                                   //SLL operation       
                            begin
                            alu_control = 6'b000100;
                          //  alu_src = 00;         ?????????????????????????????
                          NOP = 0;
                            end 
                    6'h04:                                   //SLLV operation       
                            begin
                            alu_control = 6'b100100;
                          //  alu_src = 00;         ?????????????????????????????                            
                            end 
                    6'h03:                                   //SRA operation       
                            begin
                            alu_control = 6'b001000;
                          //  alu_src = 00;         ?????????????????????????????                            
                            end
                    6'h07:                                   //SRAV operation       
                            begin
                            alu_control = 6'b101000;
                          //  alu_src = 00;         ?????????????????????????????                            
                            end 
                    6'h02:                                   //SRL operation       
                            begin
                            alu_control = 6'b000111;
                          //  alu_src = 00;         ?????????????????????????????                            
                            end 

                    6'h06:                                   //SRLV operation       
                            begin
                            alu_control = 6'b100111;
                          //  alu_src = 00;         ?????????????????????????????                            
                            end 
                    6'h1A:                                   //DIV operation       
                            begin
                            alu_control = 6'b111111;
                            div = 1;
                            end  
                    6'h1B:                                   //DIVU operation       
                            begin
                            alu_control = 6'b111111;
                            div = 1;
                            overflow = 0;
                            end 
                    6'h18:                                   //MULT operation       
                            begin
                            alu_control = 6'b111111;
                            mult = 1;
                            end 
                    6'h19:                                   //MULTU operation       
                            begin
                            alu_control = 6'b111111;
                            mult = 1;
                            overflow = 0;
                            end
                    6'h10:                                   //MoveFromHIgh operation       
                            begin
                            alu_control = 6'b111111;
                            mfhi = 1;
                            end  
                    6'h12:                                   //MoveFromLOw operation       
                            begin
                            alu_control = 6'b111111;
                            mflo = 1;
                            end 
                    6'h11:                                   //MoveToHI operation       
                            begin
                            alu_control = 6'b111111;
                            mthi = 1;
                            end
                    6'h13:                                   //MoveToLOw operation       
                            begin
                            alu_control = 6'b111111;
                            mtlo = 1;
                            end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
                    6'h08:                              //JR
                            begin
                            branch = 1; 
                            alu_control = 6'b111111;  
                            jump = 1; 
                            NOP = 1;                     
                            wr_reg_en_d = 0;                        
                            end
                     6'h09:                             //JALR
                            begin
                            branch = 1;
                            wr_reg_en_d = 1;
                            alu_control = 6'b000010; 
                            NOP = 1;                                           
                            jump = 1;
                            link_d = 1;
                            end
                 endcase                
                end

///////////////////////////////////////////////////IMMEDIATE OPERATIONS/////////////////////////////////////////////////////////////////
                
            6'h3C:                          //HLT
                 begin
                 wr_reg_en_d = 0; 
                 hlt = 1;
                 end  
                               
            6'h08:                          //ADDI 
                begin
                alu_control = 6'b000010;
                alu_src= 01;                
                end

            6'h08:                          //ADDIU no overflow 
                begin
                alu_control = 6'b000010;
                alu_src= 01; 
                overflow = 0;               
                end                   
                    
            6'h0C:                                  //ANDI
                begin
                alu_control = 6'b000000;
                alu_src= 10;                
                end
                    
            6'h0D:                                  //ORI
                begin
                alu_control = 6'b000001;
                alu_src= 10;                
                end                     

            6'h0A:                               //SLTI
                begin
                alu_control = 6'b010011;
                alu_src = 01;                   
                end 

            6'h0B:                               //SLTIU
                begin
                alu_control = 6'b010011;
                alu_src = 01;   
                overflow = 0;                
                end                                        
                                                                    
            6'h0F:                                  //LUI
                begin
                alu_control = 6'b000010;
                alu_src = 11;
                end

            6'h0E:                                  //XORI
                begin
                alu_control = 6'b000101;
                alu_src = 10;
                end
                
            default:
                   ;                                
            endcase                                         
                  
        if (wr_reg_en_d) begin
            if(link_d)     
                assign wr_reg_addr_d = 5'b11111;          // r31 = pc;    
                                                        
            else if((opcode[5:3] == 3'b000)& (~link_d))
                assign wr_reg_addr_d = rd;
                                
            else  
                assign wr_reg_addr_d = rt;
         end                  
         end   
                       
endmodule
