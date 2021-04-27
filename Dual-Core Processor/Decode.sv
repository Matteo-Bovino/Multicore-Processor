`timescale 1ns / 1ps

module Decode(
        input logic [31:0] instruction, PC4_f, PC4_wb, res_wb, res_wb_o, sourceA_d, sourceB_d,
        input logic clk, reset, prediction, link_wb, wr_reg_en_wb, wr_reg_en_wb_o, kill_decode_now, stall_decode_now,
        input logic [4:0] wr_reg_addr_wb, wr_reg_addr_wb_o,
        output logic [4:0] shamt_ex, wr_reg_addr_ex, rs, rt,
        output logic [5:0] alu_control_ex,
        output logic [31:0] PC4_ex, sourceA_ex, sourceB_ex, NPC4_jr, zero_imm_ex, upper_imm_ex, sign_imm_ex, RD1, RD2,
        output logic [1:0] alu_src_ex, mem_to_reg_ex, store_hb_ex,
        output logic wr_reg_en_ex, link_ex, mem_wr_ex, NOP, sign_zero_ext_ex, load_hb_ex, hi_wr_en_ex, lo_wr_en_ex, jump_r,
        output logic beq_ex, bne_ex, blez_ex, bgtz_ex, bgez_ex, bltz_ex, div_ex, overflow_ex, mult_ex, mfhi_ex, mflo_ex, mthi_ex, mtlo_ex     
     
    );
    
        logic [1:0] mem_to_reg, alu_src, store_hb;
        logic [31:0] zero_imm_d, upper_imm_d, sign_imm_d;             
        logic wr_reg_en_d, link_d, mem_wr, sign_zero_ext, load_hb, hi_wr_en_d, lo_wr_en_d;  
        logic beq, bne, blez, bgtz, bgez, bltz, div, overflow,  mult, mfhi, mflo, mthi, mtlo;    
        logic [31:0] PC4_d, NPC4_d, wr_data, wr_data_o;
        logic [4:0] A1, A2, wr_addr, wr_addr_o, wr_reg_addr_d, shamt_d;
        logic [5:0] alu_control;
        
        assign A1 = instruction[25:21];
        assign A2 = instruction[20:16];
        
        Control_Unit control_unit_1 (.*);             
        Reg_file reg_file_1 (.*);   
             
        assign NPC4_jr = RD1; 
                     
        always_comb
        begin                      
            if (wr_reg_en_wb) 
            begin
                wr_addr = wr_reg_addr_wb;      
            if(link_wb)     
                wr_data = PC4_wb;
            else
                wr_data = res_wb;                                
            end 
            if (wr_reg_en_wb_o) 
            begin
                wr_addr_o = wr_reg_addr_wb_o;                  
                wr_data_o = res_wb_o;                                
            end               
        end
        
        always_ff@(posedge clk, posedge reset, posedge stall_decode_now, posedge kill_decode_now)
            if(stall_decode_now)
                ;
            else if(reset | kill_decode_now)
            begin 
                wr_reg_addr_ex <= 5'b0;   
                sign_imm_ex <= 32'b0;
                zero_imm_ex <= 32'b0;
                upper_imm_ex <= 32'b0; 
                shamt_ex <= 5'b0;
                alu_control_ex <= 6'b0;
                alu_src_ex <= 2'b0;
                load_hb_ex <= 0;
                PC4_ex <= 32'b0;
                sourceA_ex <= 32'b0;
                sourceB_ex <= 32'b0;
                link_ex <= 0;  
                hi_wr_en_ex <= 0;
                lo_wr_en_ex <= 0;
                wr_reg_en_ex <= 0;
                mult_ex <= 0;
                div_ex <= 0;
                mfhi_ex <= 0;
                overflow_ex <= 0;
                mflo_ex <= 0;
                mthi_ex <= 0;
                mtlo_ex <= 0;
                mem_wr_ex <= 0;
                beq_ex <= 0;
                bne_ex <= 0;
                bgez_ex <= 0;
                blez_ex <= 0;
                bltz_ex <= 0;
                bgtz_ex <= 0;
                sign_zero_ext_ex <= 0;  
                store_hb_ex <= 2'b0;
                mem_to_reg_ex <= 2'b0;
            end                 
            else if(clk)
            begin
                wr_reg_addr_ex <= wr_reg_addr_d;   
                sign_imm_ex <= sign_imm_d;
                zero_imm_ex <= zero_imm_d;
                upper_imm_ex <= upper_imm_d; 
                shamt_ex <= shamt_d;
                alu_control_ex <= alu_control;
                alu_src_ex <= alu_src;
                load_hb_ex <= load_hb;
                PC4_ex <= PC4_d;
                sourceA_ex <= sourceA_d;
                sourceB_ex <= sourceB_d;                
                link_ex <= link_d;  
                hi_wr_en_ex <= hi_wr_en_d;
                lo_wr_en_ex <= lo_wr_en_d;
                wr_reg_en_ex <= wr_reg_en_d;
                mult_ex <= mult;
                beq_ex <= beq;
                bne_ex <= bne;
                bgtz_ex <= bgtz;
                bgez_ex <= bgez;
                bltz_ex <= bltz;
                blez_ex <= blez;
                div_ex <= div;
                mfhi_ex <= mfhi;
                overflow_ex <= overflow;
                mflo_ex <= mflo;
                mthi_ex <= mthi;
                mtlo_ex <= mtlo;
                mem_wr_ex <= mem_wr;
                sign_zero_ext_ex <= sign_zero_ext;  
                store_hb_ex <= store_hb;
                mem_to_reg_ex <= mem_to_reg;
            end                   
endmodule