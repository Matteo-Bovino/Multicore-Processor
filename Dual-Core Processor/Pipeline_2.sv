`timescale 1ns / 1ps


module Pipeline_2(
        input logic [31:0] mem_data_out_2, res_wb_1, alu_to_mem_1,
        input logic clk, reset, stall_fetch_now_2, stall_decode_now_2, stall_execute_now_2, stall_mem_wb_now_2, wr_reg_en_wb_1, rd_intent_1, wr_intent_1, ex_or_shared_1,
        input logic [4:0] wr_reg_addr_wb_1,        
        output logic copy_back_2, mem_rd_2, main_mem_wr_2, rst_dly_2, stall_2, wr_reg_en_wb_2, rd_intent_2, wr_intent_2, ex_or_shared_2,
        output logic [1:0] w_sel_2, mem_to_reg_2,
        output logic [4:0] addr_mem_2, wr_reg_addr_wb_2, wr_reg_addr_ex_2, rs_2, rt_2,
        output logic [31:0] res_wb_2, read_data_mem_2, alu_to_mem_2
            
    );

        logic [31:0] instruction, instruction_pls, PC4, PC4_wb;
        logic branch, copy_back, prediction, mem_reg_wr, wb_reg_wr, hi_wr_en_mem, lo_wr_en_mem,hi_wr_en_ex, lo_wr_en_ex, hi_wr_en_wb, lo_wr_en_wb, load_hb_ex, load_hb_mem;
        logic [4:0] addr_mem, wr_reg_addr_ex, wr_reg_addr_mem, wr_reg_addr_wb, wr_reg_addr_wb_o, shamt_d, shamt_ex, rs, rt;
        logic [31:0] zero_imm_d, zero_imm_ex, upper_imm_d, upper_imm_ex, sign_imm_d, sign_imm_ex, res_mem, alu_to_wb, RD1, RD2;
        logic [31:0] mem_data_out, read_data_mem, res_ex, res_wb, res_wb_o, hi_out, lo_out, pc, correct_pc, PC4_d, PC4_mem, PC4_ex, PC4_f, NPC4_f, NPC4_jr, res_hi_wb, res_lo_wb, extended_wb, extended_mem;        
        logic [31:0] sourceA_d, sourceB_d, sourceA_ex, sourceB_ex, alu_to_mem, alu_to_mem_o, res_hi_mem, hi_ex, lo_ex, res_lo_mem, hi_lo_ex, hi_lo_mem, sourceB_mem, read_data_wb, hi_lo_wb;           
        logic [1:0] w_sel, taken, alu_src, alu_src_ex, mem_to_reg, mem_to_reg_ex, mem_to_reg_mem, store_hb, store_hb_ex, store_hb_mem, mem_to_reg_wb;
        logic [5:0] alu_control, alu_control_ex;
        logic rd_intent, wr_intent, ex_or_shared, wrong, wr_reg_en_d, wr_reg_en_ex, wr_reg_en_mem, wr_reg_en_wb, wr_reg_en_wb_o, link_d, link_ex, link_mem, link_wb, mem_wr, mem_wr_ex, mem_wr_mem, stall_execute_now, stall_mem_wb_now, stall_fetch_now, stall_decode_now;
        logic rd_intent_o, wr_intent_o, ex_or_shared_o, mem_rd, main_mem_wr, rst_dly, kill_decode_now, hlt, NOP, sign_zero_ext, sign_zero_ext_ex, sign_zero_ext_mem, stall;
        logic beq_ex, bne_ex, blez_ex, bgtz_ex, bgez_ex, bltz_ex, div, div_ex, overflow, overflow_ex, overflow_trap;
        logic jump, jump_r, mult, mult_ex, mfhi, mfhi_ex, mfhi_mem, mfhi_wb, mflo, mflo_ex, mflo_mem, mflo_wb, mthi, mthi_ex, mthi_mem, mtlo_mem, mtlo, mtlo_ex;      
        
        assign copy_back_2 = copy_back;
        assign read_data_mem_2 = read_data_mem;
        assign mem_data_out = mem_data_out_2;
        assign addr_mem_2 = addr_mem;
        assign w_sel_2 = w_sel;
        assign mem_rd_2 = mem_rd;
        assign main_mem_wr_2 = main_mem_wr;
        assign rst_dly_2 = rst_dly;
        assign wr_reg_addr_ex_2 = wr_reg_addr_ex;
        assign rs_2 = rs;
        assign rt_2 = rt;
        assign mem_to_reg_2 = mem_to_reg;
        assign stall_2 = stall;
        assign stall_fetch_now = stall_fetch_now_2;
        assign stall_decode_now = stall_decode_now_2;
        assign stall_execute_now = stall_execute_now_2;
        assign stall_mem_wb_now = stall_mem_wb_now_2;
        assign wr_reg_addr_wb_2 = wr_reg_addr_wb;
        assign wr_reg_addr_wb_o = wr_reg_addr_wb_1;
        assign res_wb_2 = res_wb;
        assign res_wb_o = res_wb_1;        
        assign wr_reg_en_wb_2 = link_wb? 5'b0 : wr_reg_en_wb;  
        assign wr_reg_en_wb_o = wr_reg_en_wb_1;  
        assign rd_intent_2 = rd_intent;
        assign rd_intent_o = rd_intent_1;        
        assign wr_intent_2 = wr_intent;
        assign wr_intent_o = wr_intent_1;        
        assign ex_or_shared_2 = ex_or_shared;          
        assign ex_or_shared_o = ex_or_shared_1;
        assign alu_to_mem_2 = alu_to_mem;          
        assign alu_to_mem_o = alu_to_mem_1;    
                   
        Fetch_2 fetch_2 (.*); 
        Prediction prediction_2 (.*);    
        Decode decode_2 (.*);
        Forwarding_unit forwarding_unit_2 (.*);
        Execute execute_2 (.*);    
        Memory memory_2 (.*);
        Write_back write_back_2 (.*);   
      
endmodule
