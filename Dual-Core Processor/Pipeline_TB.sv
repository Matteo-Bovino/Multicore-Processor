`timescale 1ns / 1ps


module Pipeline_1(
        input logic [31:0] mem_data_out, res_wb_2, alu_to_mem_2, 
        input logic clk, reset, stall_fetch_now, stall_decode_now, stall_execute_now, stall_mem_wb_now, wr_reg_en_wb_2, rd_intent_2, wr_intent_2, ex_or_shared_2,
        input logic [4:0] wr_reg_addr_wb_2,
        output logic mem_rd, main_mem_wr, rst_dly, stall, wr_reg_en_wb_1, rd_intent_1, wr_intent_1, ex_or_shared_1, copy_back,
        output logic [1:0] w_sel, mem_to_reg,
        output logic [4:0] addr_mem, wr_reg_addr_ex, rs, rt, wr_reg_addr_wb_1,
        output logic [31:0] res_wb_1, read_data_mem, alu_to_mem_1
    );

        logic [31:0] instruction, instruction_pls, PC4, PC4_wb;
        logic branch, prediction, mem_reg_wr, wb_reg_wr, hi_wr_en_mem, lo_wr_en_mem, hi_wr_en_ex, lo_wr_en_ex, hi_wr_en_wb, lo_wr_en_wb, load_hb_ex, load_hb_mem, wr_reg_en_wb, wr_reg_en_wb_o;
        logic [4:0]  wr_reg_addr_mem, wr_reg_addr_wb, wr_reg_addr_wb_o, shamt_d, shamt_ex;
        logic [31:0] zero_imm_d, zero_imm_ex, upper_imm_d, upper_imm_ex, sign_imm_d, sign_imm_ex, res_mem, alu_to_wb, RD1, RD2;
        logic [31:0] res_wb, res_wb_o, res_ex, hi_out, lo_out, pc, correct_pc, PC4_d, PC4_mem, PC4_ex, PC4_f, NPC4_f, NPC4_jr, res_hi_wb, res_lo_wb, extended_wb, extended_mem;        
        logic [31:0] sourceA_d, sourceB_d, sourceA_ex, sourceB_ex, alu_to_mem_o, alu_to_mem, res_hi_mem, hi_ex, lo_ex, res_lo_mem, hi_lo_ex, hi_lo_mem, sourceB_mem, read_data_wb, hi_lo_wb;           
        logic [1:0] taken, alu_src, alu_src_ex, mem_to_reg_ex, mem_to_reg_mem, store_hb, store_hb_ex, store_hb_mem, mem_to_reg_wb;
        logic [5:0] alu_control, alu_control_ex;
        logic rd_intent, wr_intent, ex_or_shared, wrong, wr_reg_en_d, wr_reg_en_ex, wr_reg_en_mem, link_d, link_ex, link_mem, link_wb, mem_wr, mem_wr_ex, mem_wr_mem;
        logic rd_intent_o, wr_intent_o, ex_or_shared_o, kill_decode_now, hlt, NOP, sign_zero_ext, sign_zero_ext_ex, sign_zero_ext_mem;
        logic beq_ex, bne_ex, blez_ex, bgtz_ex, bgez_ex, bltz_ex, div, div_ex, overflow, overflow_ex, overflow_trap;
        logic jump, jump_r, mult, mult_ex, mfhi, mfhi_ex, mfhi_mem, mfhi_wb, mflo, mflo_ex, mflo_mem, mflo_wb, mthi, mthi_ex, mthi_mem, mtlo_mem, mtlo, mtlo_ex;  
        
        assign wr_reg_addr_wb_1 = wr_reg_addr_wb;
        assign wr_reg_addr_wb_o = wr_reg_addr_wb_2;
        assign res_wb_1 = res_wb;
        assign res_wb_o = res_wb_2;        
        assign wr_reg_en_wb_1 = link_wb? 0 : wr_reg_en_wb;  
        assign wr_reg_en_wb_o = wr_reg_en_wb_2; 
        assign rd_intent_1 = rd_intent;
        assign rd_intent_o = rd_intent_2;        
        assign wr_intent_1 = wr_intent;
        assign wr_intent_o = wr_intent_2;        
        assign ex_or_shared_1 = ex_or_shared;          
        assign ex_or_shared_o = ex_or_shared_2;  
        assign alu_to_mem_1 = alu_to_mem;          
        assign alu_to_mem_o = alu_to_mem_2;
        
              
        FETCH fetch_1 (.*); 
        Prediction prediction_1 (.*);    
        Decode decode_1 (.*);
        Forwarding_unit forwarding_unit_1 (.*);
        Execute execute_1 (.*);    
        Memory memory_1 (.*);
        Write_back write_back_1 (.*);
      
endmodule