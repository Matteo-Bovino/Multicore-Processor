`timescale 1ns / 1ps

module Dual_Core(
    //input logic clk, reset, supposed to be coming from the board
    output logic hlt, hlt2      
    );
        
        logic [31:0] mem_data_in, mem_data_in_2, read_data_mem, res_wb_2, res_wb_1;
        logic [4:0] addr_core_1, addr_core_2, wr_reg_addr_ex, wr_reg_addr_ex_2, wr_reg_addr_wb_1, wr_reg_addr_wb_2, rs, rs_2, rt, rt_2;
        logic [1:0] w_sel, w_sel_2, mem_to_reg, mem_to_reg_2;
        logic clk, reset, copy_back, copy_back_2, main_mem_wr, main_mem_wr_2, mem_rd, mem_rd_2, rst_dly, rst_dly_2, stall, stall_2, wr_reg_en_wb_1, wr_reg_en_wb_2;
        logic [31:0] mem_data_out, mem_data_out_2, alu_to_mem_1, alu_to_mem_2; 
        logic stall_fetch_now, stall_decode_now, stall_execute_now, stall_mem_wb_now;
        logic stall_fetch_now_2, stall_decode_now_2, stall_execute_now_2, stall_mem_wb_now_2;
        logic rd_intent_1, wr_intent_1, ex_or_shared_1, rd_intent_2, wr_intent_2, ex_or_shared_2;              
             
            
        Core_1 core_number_1 (.*);
        Main_memory main_mem (.*);        
        Core_2 core_number_2 (.*);
        Hazard_detection hazard_1 (.*);     


        always
        begin
            clk <= 1;
            #5;
            clk <= 0;
            #5;
        end

        initial
        begin
            reset <= 0;
            #2
            reset <= 1;
            #5
            reset <=0;
        end
endmodule