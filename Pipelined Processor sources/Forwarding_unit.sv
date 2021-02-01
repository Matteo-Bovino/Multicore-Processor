`timescale 1ns / 1ps


module Forwarding_unit(
        input logic [4:0] rs_ex, rt_ex, mem_dst, wb_dst,
        input logic clk, mem_reg_wr, wb_reg_wr, mult_ex, div_ex,
        input logic [31:0] RD1_ex, RD2_ex, res_wb, res_mem,
        output logic forward_hi_lo,
        output logic [31:0] sourceA_ex, sourceB_ex

    );
    
    logic [1:0] forwardA, forwardB;
    logic forward_hi_lo_next;
    
/////////////////////////////////////////////////////////////////////FORWARDING LOGIC//////////////////////////////////////////////////////////////////
    always_comb
    begin
        if((wb_dst == rs_ex) & (wb_reg_wr))                                                    //MUX A SELECTION 
            forwardA = 2'b01;
        else if ((wb_dst == rt_ex) & (wb_reg_wr))
            forwardB = 2'b01;
                        
        if((mem_dst == rt_ex) & (mem_reg_wr))                                                    //MUX B SELECTION 
            forwardB = 2'b10;
        else if ((mem_dst == rs_ex) & (mem_reg_wr))  
            forwardA = 2'b10; 
                           
            case(forwardA)                                      // needs to be update with three bits to consider the new half sizes.                
                2'b01:
                    sourceA_ex = res_wb;
                2'b10:
                    sourceA_ex = res_mem;
                default:
                    sourceA_ex = RD1_ex;
            endcase
            
            case(forwardB)
                2'b10:
                    sourceB_ex = res_wb;
                2'b10:
                    sourceB_ex = res_mem;
              default:
                    sourceB_ex = RD2_ex;            
            endcase 
        
        assign forward_hi_lo_next = mult_ex | div_ex;    
        end
        
        always_ff@(posedge clk)
            begin
                forward_hi_lo <= forward_hi_lo_next;
            end                
endmodule
