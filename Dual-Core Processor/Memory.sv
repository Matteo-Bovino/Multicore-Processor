`timescale 1ns / 1ps


module Memory(

        input logic clk, reset, hi_wr_en_mem, lo_wr_en_mem, stall_mem_wb_now, wr_reg_en_mem, 
        input logic rd_intent_o, wr_intent_o, ex_or_shared_o, link_mem, mem_wr_mem, sign_zero_ext_mem, load_hb_mem, mfhi_mem, mflo_mem,
        input logic [1:0] mem_to_reg_mem, store_hb_mem, 
        input logic [4:0] wr_reg_addr_mem, 
        input logic [31:0] alu_to_mem, res_hi_mem, res_lo_mem, hi_lo_mem, PC4_mem, sourceB_mem, mem_data_out, alu_to_mem_o,
        output logic copy_back, rst_dly, link_wb, wr_reg_en_wb, mfhi_wb, mflo_wb, hi_wr_en_wb, lo_wr_en_wb, stall, mem_rd, main_mem_wr, rd_intent, wr_intent, ex_or_shared,
        output logic [4:0] wr_reg_addr_wb, addr_mem,
        output logic [1:0] mem_to_reg_wb, w_sel,
        output logic [31:0] alu_to_wb, read_data_wb, extended_wb, hi_lo_wb, PC4_wb, res_hi_wb, res_lo_wb, read_data_mem      
    );
        
        logic [31:0] sign_ext, zero_ext, extended;
        logic [7:0] read_data_byte;
        logic [15:0] read_data_half;
        logic index, hit, first, second, rd_en, cache_wr, cache_rd, cache_data_src;
        logic [3:0] offset;
        logic [26:0] tag;
        logic [1:0] copy;
        
        assign tag = alu_to_mem [31:5];
        assign index = alu_to_mem [4];
        assign offset = alu_to_mem [3:0]; 
        assign rd_en = |mem_to_reg_mem; // The or reduction gives a value of 1 only for load instructions, which indeed require a read operations
  
        
        Data_cache cache_data_1 (.re(cache_rd), .we(cache_wr), .*);
        Cache_controller cache_controller_1 (.wr_en(mem_wr_mem), .*);
        
        always_ff@(posedge clk, posedge reset, posedge stall_mem_wb_now)                    // high and low registers for the mult/div unit
        begin
            if(stall_mem_wb_now)
                ;
            else if(reset)
            begin
                wr_reg_addr_wb <= 5'b0;   
                PC4_wb <= 32'b0;
                link_wb <= 0;
                wr_reg_en_wb <= 0;
                read_data_wb <= 32'b0;
                mem_to_reg_wb <= 2'b00;
                alu_to_wb <= 32'b0;
                hi_lo_wb <= 32'b0;
                mfhi_wb <= 0;
                mflo_wb <= 0;
                res_hi_wb <= 32'b0;
                res_lo_wb <= 32'b0;
                extended_wb <= 32'b0;
                lo_wr_en_wb <= 0;
                hi_wr_en_wb <= 0;                
            end
            else 
            begin
                wr_reg_addr_wb <= wr_reg_addr_mem;   
                PC4_wb <= PC4_mem;
                link_wb <= link_mem;
                wr_reg_en_wb <= wr_reg_en_mem;
                read_data_wb <= read_data_mem;
                mem_to_reg_wb <= mem_to_reg_mem;
                alu_to_wb <= alu_to_mem;
                hi_lo_wb <= hi_lo_mem;
                mfhi_wb <= mfhi_mem;
                mflo_wb <= mflo_mem;
                res_hi_wb <= res_hi_mem;
                res_lo_wb <= res_lo_mem;
                extended_wb <= extended;
                lo_wr_en_wb <= lo_wr_en_mem;
                hi_wr_en_wb <= hi_wr_en_mem;                           
            end        
        end 
            
        always_comb
        begin
            if(load_hb_mem == 0)
            begin
                zero_ext = {24'b0, read_data_mem[7:0]};
                sign_ext = 32'(signed'(read_data_mem[7:0]));
            end
            else if (load_hb_mem == 1)
            begin
                zero_ext = {16'b0, read_data_mem[15:0]};
                sign_ext = 32'(signed'(read_data_mem[15:0]));
            end
                
                
            case(sign_zero_ext_mem)
                  0:
                    extended = sign_ext;         
            default:
                    extended = zero_ext;
            endcase            
         end              
endmodule
