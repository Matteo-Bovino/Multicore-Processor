`timescale 1ns / 1ps

module Core_2(

        input logic clk, reset, copy_back, stall_fetch_now_2, stall_decode_now_2, stall_execute_now_2, stall_mem_wb_now_2, wr_reg_en_wb_1, rd_intent_1, wr_intent_1, ex_or_shared_1,
        input logic [31:0] mem_data_out_2, res_wb_1, alu_to_mem_1,
        input logic [4:0] wr_reg_addr_wb_1,                
        output logic hlt2, main_mem_wr_2, mem_rd_2, rst_dly_2, stall_2, wr_reg_en_wb_2, rd_intent_2, wr_intent_2, ex_or_shared_2, copy_back_2,
        output logic [1:0] w_sel_2, mem_to_reg_2,
        output logic [4:0] addr_core_2, wr_reg_addr_ex_2, wr_reg_addr_wb_2, rs_2, rt_2,
        output logic [31:0] res_wb_2, mem_data_in_2, alu_to_mem_2

    );

        logic [31:0] read_data_mem_2;
        logic [4:0] addr_mem_2;
        
        assign mem_data_in_2 = read_data_mem_2;
        assign addr_core_2 = addr_mem_2;
        
        Pipeline_2 pipeline_core_2 (.*);

endmodule