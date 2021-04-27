`timescale 1ns / 1ps


module Forwarding_unit(
        input logic clk, reset, wr_reg_en_ex, wr_reg_en_mem, mult_ex, div_ex, mfhi_mem, mflo_mem, mfhi_ex, mflo_ex,
        input logic [1:0] mem_to_reg_mem,
        input logic [4:0] rs, rt, wr_reg_addr_ex, wr_reg_addr_mem, 
        input logic [5:0] alu_control_ex,        
        input logic [31:0] RD1, RD2, extended_mem, read_data_mem, hi_out, lo_out, hi_lo_mem, hi_lo_ex, res_ex, alu_to_mem, res_hi_mem, res_lo_mem,
        output logic [31:0] sourceA_d, sourceB_d, hi_ex, lo_ex

    );
    
    logic [2:0] forwardA, forwardB;
    logic forward_hi_lo, forward_hi_lo_next;
    
/////////////////////////////////////////////////////////////////////FORWARDING LOGIC//////////////////////////////////////////////////////////////////
    always_comb
    begin                                    
              
        if((wr_reg_addr_ex == rs) & (wr_reg_en_ex) & (rs != 5'b00000))
        begin
            if(mfhi_ex | mflo_ex)
                forwardA = 3'b110;
            else //if (alu_control_ex == 6'b111111)
                forwardA = 3'b101;
        end
            
        else if((wr_reg_addr_mem == rs) & (wr_reg_en_mem) & (rs != 5'b00000)) 
        begin
            if(mfhi_mem | mflo_mem)                                                    
                forwardA = 3'b001; 
            else if(mem_to_reg_mem == 2'b01)  
                forwardA = 3'b010;
            else if(mem_to_reg_mem == 2'b1X)  
                forwardA = 3'b011;
            else if(mem_to_reg_mem == 2'b00)
                forwardA = 3'b100; 
        end 
                
        else
            forwardA = 3'b111;                                                    
                                                                                                                                              
        if((wr_reg_addr_ex == rt) & (wr_reg_en_ex) & (rt != 5'b00000))
        begin
            if(mfhi_ex | mflo_ex)
                forwardB = 3'b110;
            else //if (alu_control_ex == 6'b111111)
                forwardB = 3'b101; 
        end

        else if((wr_reg_addr_mem == rt) & (wr_reg_en_mem) & (rt != 5'b00000))    //The memory stage has multiple values that could be bypassed
        begin
            if(mfhi_mem | mflo_mem)                                                     
                forwardB = 3'b001;                                 //Hi or Lo feeds the value
            else if(mem_to_reg_mem == 2'b01)
                forwardB = 3'b010;                                 //Read_data_mem feeds the value
            else if(mem_to_reg_mem == 2'b1X)
                forwardB = 3'b011;                                 //Extended feeds the value for both byte and half word.
            else if(mem_to_reg_mem == 2'b00)
                forwardB = 3'b100;                                 //ALU feeds the value
        end

        else
            forwardB = 3'b111;                                 //No bypassing
                                                                            
                                                                                                  
            case(forwardA)                                          //Two muxes are needed in order to accommodate both RS and RD
                3'b001:
                    sourceA_d = hi_lo_mem;
                3'b010:
                    sourceA_d = read_data_mem;
                3'b011:
                    sourceA_d = extended_mem;
                3'b100:
                    sourceA_d = alu_to_mem; 
                3'b101:
                    sourceA_d = res_ex;  
                3'b110:
                    sourceA_d = hi_lo_ex;                  
                default:
                    sourceA_d = RD1;
            endcase
            
            case(forwardB)
                3'b001:
                    sourceB_d = hi_lo_mem;
                3'b010:
                    sourceB_d = read_data_mem;
                3'b011:
                    sourceB_d = extended_mem;
                3'b100:
                    sourceB_d = alu_to_mem; 
                3'b101:
                    sourceB_d = res_ex;  
                3'b110:
                    sourceB_d = hi_lo_ex;                  
                default:
                    sourceB_d = RD2;
            endcase

            case(forward_hi_lo)
                1:  
                    begin 
                    hi_ex = res_hi_mem;
                    lo_ex = res_lo_mem;
                    end
            default:
                    begin
                    hi_ex = hi_out;
                    lo_ex = lo_out;
                    end
            endcase       
        forward_hi_lo_next = mult_ex | div_ex;    
        end
        
        always_ff@(posedge clk)
        begin
            forward_hi_lo <= forward_hi_lo_next;
        end  
                                                      
endmodule
