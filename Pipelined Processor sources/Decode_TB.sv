`timescale 1ns / 1ps


module Decode_TB(
        
    );

        logic [31:0] instruction, PC4, PC4_wb, res_wb;
        logic clk, reset, prediction, mem_reg_wr, wb_reg_wr, hi_wr_en_wb, lo_wr_en_wb;;
        logic [4:0] wr_reg_addr_ex, wr_reg_addr_mem, wr_reg_addr_wb, shamt_d, shamt_ex, rs_ex, rt_ex, mem_dst, wb_dst;
        logic [31:0] zero_imm_d, zero_imm_ex, upper_imm_d, upper_imm_ex, sign_imm_d, sign_imm_ex, res_mem;
        logic [31:0] PC4_d, PC4_mem, PC4_ex, PC4_f, RD1, RD2, RD1_ex, RD2_ex, NPC4, res_hi_mem, res_lo_mem, res_hi_wb, res_lo_wb;
        
        logic [31:0] alu_to_mem, res_hi_to_mem, res_lo_to_mem;           
        logic [1:0] alu_src, alu_src_ex, mem_to_reg, mem_to_reg_ex, mem_to_reg_mem;
        logic [5:0] alu_control, alu_control_ex;
        logic branch, wr_reg_en_d, wr_reg_en_ex, wr_reg_en_mem, wr_reg_en_wb, link_d, link_ex, link_mem, link_wb, mem_wr, mem_wr_ex, mem_wr_mem, hlt, NOP, sign_zero_ext, sign_zero_ext_ex, sign_zero_ext_mem, store_hb, store_hb_ex, store_hb_mem;
        logic beq, beq_ex, bne, bne_ex, blez, blez_ex, bgtz, bgtz_ex, bgez, bgez_ex, bltz, bltz_ex, div, div_ex, overflow, overflow_ex, overflow_trap, taken,  mult, mult_ex, mfhi, mfhi_ex, mflo, mflo_ex, mthi, mthi_ex, mtlo, mtlo_ex;      

    FETCH fetch_1 (.*); 
    Decode decode_1 (.*);         
    Execute execute_1 (.*);    
      
    
    always
        begin
        clk <= 1;
        #5;
        clk <= 0;
        #5;
        end
        
    initial
        begin
        #1;
        reset = 1;        
        prediction = 0;
        wr_reg_en_wb = 0;
        wr_reg_addr_wb = 32'h00000001;       
        PC4_wb = 32'hf0f0f0f0;
        res_hi_mem = 32'hffffffff;
        mem_dst = 32'h43243245;
        wb_dst = 32'h43243245;
        mem_reg_wr = 0;
        wb_reg_wr = 0;
        res_lo_mem = 32'hffffffff;
        res_hi_wb = 32'h00000000;
        res_lo_wb = 32'h00000000;
        link_wb = 0;
        #4;
        reset = 0;
        #10;
        //wr_reg_en_wb = 1;
        //res_wb = 32'b1111;
        //NPC4_wb = 32'b1111;
        //wr_reg_addr_wb = 5'b0;
        #100;                
        end
endmodule