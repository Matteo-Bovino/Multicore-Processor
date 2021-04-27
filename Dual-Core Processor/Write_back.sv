`timescale 1ns / 1ps

module Write_back(
            input logic [31:0] alu_to_wb, read_data_wb, extended_wb, hi_lo_wb,
            input logic [1:0] mem_to_reg_wb,
            input logic mfhi_wb, mflo_wb,
            output logic [31:0] res_wb
    );
    
            logic [31:0] res_alu_mem;
            logic move_from_hi_lo;
            
            assign move_from_hi_lo = mfhi_wb | mflo_wb;
            always_comb
            begin
                case(mem_to_reg_wb)
                    2'b01:
                        res_alu_mem = read_data_wb;
                    2'b10:
                        res_alu_mem = extended_wb;
                  default:
                        res_alu_mem = alu_to_wb;
                endcase
                
                case(move_from_hi_lo)
                     1:
                         res_wb = hi_lo_wb;
                     0:
                         res_wb = res_alu_mem;
                  default:
                        ;
                 endcase
            end
endmodule
