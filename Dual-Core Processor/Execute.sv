`timescale 1ns / 1ps


module Execute(
        input logic [4:0] wr_reg_addr_ex, shamt_ex,        
        input logic [5:0] alu_control_ex,
        input logic [31:0] hi_ex, lo_ex, PC4_ex, sourceB_ex, sourceA_ex, zero_imm_ex, upper_imm_ex, sign_imm_ex, res_hi_wb, res_lo_wb,
        input logic [1:0] alu_src_ex, mem_to_reg_ex, store_hb_ex,
        input logic clk, reset, stall_execute_now, wr_reg_en_ex, link_ex, mem_wr_ex, load_hb_ex, sign_zero_ext_ex, lo_wr_en_wb, lo_wr_en_ex, hi_wr_en_ex, hi_wr_en_wb,
        input logic beq_ex, bne_ex, blez_ex, bgtz_ex, bgez_ex, bltz_ex, div_ex, overflow_ex, mult_ex, mfhi_ex, mflo_ex, mthi_ex, mtlo_ex,
        output logic wr_reg_en_mem, link_mem, mem_wr_mem, load_hb_mem, sign_zero_ext_mem, overflow_trap, mfhi_mem, mflo_mem, hi_wr_en_mem, lo_wr_en_mem,
        output logic [1:0] mem_to_reg_mem, store_hb_mem, taken, 
        output logic [4:0] wr_reg_addr_mem,
        output logic [31:0] alu_to_mem, res_ex, res_hi_mem, res_lo_mem, PC4_mem, hi_lo_mem, sourceB_mem, hi_out, lo_out, hi_lo_ex

    );
        logic [31:0] sourceB_ex1, res_hi_ex, res_lo_ex; 
        logic [31:0] hi_reg, lo_reg;
        logic [63:0] res64;
        logic overflow_trap_alu, overflow_trap_md;
        
        assign res_hi_ex = (mthi_ex)? sourceA_ex : res64[63:32];                //Muxes to choose between calculated result and register value
        assign res_lo_ex = (mtlo_ex)? sourceA_ex : res64[31:0];
        assign overflow_trap = overflow_trap_alu | overflow_trap_md; 
        
        ALU alu_unit_1 (.*);
        MultDiv_unit multdiv_unit_1 (.*);
        
        always_comb
        begin        
            if(alu_src_ex == 2'b11)
                sourceB_ex1 = upper_imm_ex;
            else if(alu_src_ex == 2'b01)
                sourceB_ex1 = sign_imm_ex;
            else if(alu_src_ex == 2'b10)
                sourceB_ex1 = zero_imm_ex;
            else
                sourceB_ex1 = sourceB_ex;

            if(clk == 1)  
            begin                           
                if(hi_wr_en_wb)
                    hi_reg = res_hi_wb;
                else if (lo_wr_en_wb)
                    lo_reg = res_lo_wb;
            end 
            
            hi_out = hi_reg;
            lo_out = lo_reg; 

            case({mfhi_ex, mflo_ex})
                2'b01:
                    hi_lo_ex = lo_ex;
                
                2'b10:
                    hi_lo_ex = hi_ex ; 
            
              default:
                    hi_lo_ex = 32'b0;
            endcase                
        end

        always_ff@(posedge clk, posedge reset, posedge stall_execute_now)                    // high and low registers for the mult/div unit
            begin
            if(stall_execute_now)
                ; // Do not update the registers 
            else if(reset)
            begin
                hi_reg <= 32'b0;
                lo_reg <= 32'h0;
                wr_reg_addr_mem <= 5'b0;   
                PC4_mem <= 32'b0;
                link_mem <= 0;
                wr_reg_en_mem <= 0;
                mem_wr_mem <= 0;
                sign_zero_ext_mem <= 0;  
                store_hb_mem <= 2'b0;
                load_hb_mem <= 0;
                mem_to_reg_mem <= 2'b0;
                alu_to_mem <= 32'b0;
                mfhi_mem <= 0;
                mflo_mem <= 0;
                hi_lo_mem <= 32'b0;
                res_lo_mem <= 32'b0;
                res_hi_mem <= 32'b0;
                sourceB_mem <= 32'b0;
                lo_wr_en_mem <= 0;
                hi_wr_en_mem <= 0;                
            end
            else 
            begin
                wr_reg_addr_mem <= wr_reg_addr_ex;   
                PC4_mem <= PC4_ex;
                link_mem <= link_ex;
                wr_reg_en_mem <= wr_reg_en_ex;
                mem_wr_mem <= mem_wr_ex;
                sign_zero_ext_mem <= sign_zero_ext_ex;  
                store_hb_mem <= store_hb_ex;
                load_hb_mem <= load_hb_ex;
                mem_to_reg_mem <= mem_to_reg_ex;
                alu_to_mem <= res_ex;
                mfhi_mem <= mfhi_ex;
                mflo_mem <= mflo_ex;
                hi_lo_mem <= hi_lo_ex;
                res_lo_mem <= res_lo_ex;
                res_hi_mem <= res_hi_ex;
                sourceB_mem <= sourceB_ex;
                PC4_mem <= PC4_ex; 
                lo_wr_en_mem <= lo_wr_en_ex;
                hi_wr_en_mem <= hi_wr_en_ex;                          
            end        
        end                                                                              
endmodule