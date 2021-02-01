`timescale 1ns / 1ps


module Execute(
        input logic [4:0] rs_ex, rt_ex, mem_dst, wb_dst, wr_reg_addr_ex, shamt_ex,        
        input logic [5:0] alu_control_ex,
        input logic [31:0] PC4_ex, RD1_ex, RD2_ex, res_wb, res_mem, zero_imm_ex, upper_imm_ex, sign_imm_ex, res_hi_mem, res_lo_mem, res_hi_wb, res_lo_wb,
        input logic [1:0] alu_src_ex, mem_to_reg_ex,
        input logic clk, reset, wr_reg_en_ex, link_ex, mem_wr_ex, sign_zero_ext_ex, store_hb_ex, mem_reg_wr, wb_reg_wr, lo_wr_en_wb,
        input logic beq_ex, bne_ex, blez_ex, bgtz_ex, bgez_ex, bltz_ex, div_ex, overflow_ex, mult_ex, mfhi_ex, mflo_ex, mthi_ex, mtlo_ex, hi_wr_en_wb,
        output logic wr_reg_en_mem, link_mem, mem_wr_mem, sign_zero_ext_mem, store_hb_mem, overflow_trap, taken,
        output logic [1:0] mem_to_reg_mem,
        output logic [4:0] wr_reg_addr_mem,
        output logic [31:0] alu_to_mem, res_hi_to_mem, res_lo_to_mem, PC4_mem             

    );
        logic [31:0] sourceB_ex1, sourceB_ex, sourceA_ex, res_ex, res_hi_ex, res_lo_ex; 
        logic [31:0] hi_reg, hi_out, lo_reg, lo_out, hi_ex, lo_ex, hi_lo_ex;
        logic [63:0] res64;
        logic overflow_trap_alu, overflow_trap_md, forward_hi_lo;
        
        assign res_hi_ex = (mthi_ex)? sourceA_ex : res64[64:32];                //Muxes to choose between calculated result and register value
        assign res_lo_ex = (mtlo_ex)? sourceA_ex : res64[31:0];
        assign overflow_trap = overflow_trap_alu | overflow_trap_md; 

        
        Forwarding_unit forwarding_unit_1 (.*);
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
        end

        always_ff@(posedge clk, posedge reset)                    // high and low registers for the mult/div unit
            begin
            if(reset)
                begin
                hi_reg <= 31'b0;
                lo_reg <= 31'b0;
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
                mem_to_reg_mem <= mem_to_reg_ex;
                alu_to_mem <= res_ex;
                res_lo_to_mem <= res_lo_ex;
                res_hi_to_mem <= res_hi_ex;
                PC4_mem <= PC4_ex; 
                                           
                end        
            end 
                                                   
               
        always_comb
        begin
        case(forward_hi_lo)

            1:  
                begin 
                hi_ex = res_hi_mem;
                lo_ex = res_lo_mem;
                end
         default:
                begin
                hi_ex = hi_out;
                lo_ex = lo_out;
                end
         endcase 
                             
         
         case({mfhi_ex, mflo_ex})
            2'b01:
                hi_lo_ex = lo_ex;
                
            2'b10:
                hi_lo_ex = hi_ex ; 
            
            default:
                    ;  
         endcase  

            if(clk == 1)  
                begin                           
                if(hi_wr_en_wb)
                    hi_reg = res_hi_wb;
                else if (lo_wr_en_wb)
                    lo_reg = res_lo_wb;
                end 
            
        assign hi_out = hi_reg;
        assign lo_out = lo_reg; 
        end          
endmodule