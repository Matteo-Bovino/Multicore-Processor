`timescale 1ns / 1ps

module Core_1(

        input logic clk, reset, stall_fetch_now, stall_decode_now, stall_execute_now, stall_mem_wb_now, wr_reg_en_wb_2, rd_intent_2, wr_intent_2, ex_or_shared_2,
        input logic [31:0] mem_data_out, res_wb_2, alu_to_mem_2,
        input logic [4:0] wr_reg_addr_wb_2,        
        output logic hlt, main_mem_wr, mem_rd, rst_dly, stall, wr_reg_en_wb_1, rd_intent_1, wr_intent_1, ex_or_shared_1, copy_back,
        output logic [1:0] w_sel, mem_to_reg,
        output logic [4:0] addr_core_1, wr_reg_addr_ex, rs, rt, wr_reg_addr_wb_1,
        output logic [31:0] res_wb_1, mem_data_in, alu_to_mem_1
        
    );

        logic [31:0] read_data_mem;
        logic [4:0] addr_mem;
        
        assign mem_data_in = read_data_mem;
        assign addr_core_1 = addr_mem;
        
        Pipeline_1 pipeline_1 (.*);

endmodule