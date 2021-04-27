`timescale 1ns / 1ps

module Hazard_detection(
        input logic clk, reset,
        input logic [4:0] wr_reg_addr_ex, wr_reg_addr_ex_2, rs, rs_2, rt, rt_2,
        input logic [1:0] mem_to_reg, mem_to_reg_2,
        input logic stall, stall_2,
        output logic stall_fetch_now, stall_decode_now, stall_execute_now, stall_mem_wb_now,
        output logic stall_fetch_now_2, stall_decode_now_2, stall_execute_now_2, stall_mem_wb_now_2        
    );
        
        logic stall_fetch, stall_decode, stall_mem_wb, stall_execute;
        logic stall_fetch_2, stall_decode_2, stall_mem_wb_2, stall_execute_2;
        
/////////////////////////////////////////////////////CONTROL HAZARDS//////////////////////////////////////////// 
        always_comb
            begin 
            stall_fetch = 0;
            stall_decode = 0;
            stall_execute = 0;
            stall_mem_wb = 0; 
            stall_fetch_2 = 0;
            stall_decode_2 = 0;
            stall_execute_2 = 0;
            stall_mem_wb_2 = 0;
                                                        
            if(mem_to_reg != 2'b00)                                 //memory access indicating a load
                begin
                if((rs == wr_reg_addr_ex) | (rt == wr_reg_addr_ex))       //If a load is followed by an instruction that reads the same register the decode stage is stalled
                    begin
                    stall_decode = 1;
                    stall_fetch = 1;
                    stall_mem_wb = 0;
                    stall_execute = 0;
                    end
                end

                
            if(mem_to_reg_2 != 2'b00)                                 //memory access indicating a load
            begin
                if((rs_2 == wr_reg_addr_ex_2) | (rt_2 == wr_reg_addr_ex_2))       //If a load is followed by an instruction that reads the same register the decode stage is stalled
                begin    
                    stall_decode_2 = 1;
                    stall_fetch_2 = 1;
                    stall_mem_wb_2 = 0;
                    stall_execute_2 = 0;
                end
             end          
            end  
/////////////////////////////////////////////////////TWO CORES - OUT OF ORDER HAZARDS//////////////////////////////////////////////////////                  
        
        always_ff@(clk, reset, stall, stall_fetch, stall_decode, stall_execute, stall_mem_wb)
            if(~stall)
                begin
                stall_fetch_now <= 1;
                stall_decode_now <= 1;
                stall_execute_now <= 1;
                stall_mem_wb_now <= 1;
                end                       
            else if(reset)
                begin
                stall_fetch_now <= 0;
                stall_decode_now <= 0;
                stall_execute_now <= 0;
                stall_mem_wb_now <= 0;                
                end   
            else
                begin
                stall_fetch_now <= stall_fetch;
                stall_decode_now <= stall_decode;
                stall_execute_now <= stall_execute;
                stall_mem_wb_now <= stall_mem_wb;
                end

        always_ff@( clk, reset, stall_2, stall_fetch_2, stall_decode_2, stall_execute_2, stall_mem_wb_2)
            if(~stall_2)
                begin
                stall_fetch_now_2 <= 1;
                stall_decode_now_2 <= 1;
                stall_execute_now_2 <= 1;
                stall_mem_wb_now_2 <= 1;
                end                       
            else if(reset)
                begin
                stall_fetch_now_2 <= 0;
                stall_decode_now_2 <= 0;
                stall_execute_now_2 <= 0;
                stall_mem_wb_now_2 <= 0;                
                end   
            else
                begin
                stall_fetch_now_2 <= stall_fetch_2;
                stall_decode_now_2 <= stall_decode_2;
                stall_execute_now_2 <= stall_execute_2;
                stall_mem_wb_now_2 <= stall_mem_wb_2;
                end                
endmodule