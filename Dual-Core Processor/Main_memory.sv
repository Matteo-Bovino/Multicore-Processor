`timescale 1ns / 1ps

module Main_memory(
        input logic [31:0] mem_data_in, mem_data_in_2,
        input logic clk, reset, main_mem_wr, main_mem_wr_2, mem_rd, mem_rd_2, rst_dly, rst_dly_2, copy_back, copy_back_2,
        input logic [1:0] w_sel, w_sel_2,
        input logic [4:0] addr_core_1, addr_core_2,
        output logic [31:0] mem_data_out, mem_data_out_2
    );
    
        logic [127:0] fill_in, fill_in_2, fill_out, fill_out_2;
        logic we, we_2, fast_share, fast_share_2;

        blk_mem_gen_0 Main_Memory_Unit (
                .clka(clk),    // input wire clka
                .rsta(reset),    // input wire rsta
                .ena(~rst_dly),      // input wire ena        
                .wea(we),      // input wire [0 : 0] wea
                .addra(addr_core_1),  // input wire [4 : 0] addra
                .dina(fill_in),    // input wire [127 : 0] dina
                .douta(fill_out),  // output wire [127 : 0] douta
                .clkb(clk),    // input wire clkb
                .rstb(reset),    // input wire rstb
                .enb(~rst_dly_2),      // input wire enb
                .web(we_2),      // input wire [0 : 0] web
                .addrb(addr_core_2),  // input wire [4 : 0] addrb
                .dinb(fill_in_2),    // input wire [127 : 0] dinb
                .doutb(fill_out_2)  // output wire [127 : 0] doutb
        );             
    
        always_ff@(posedge clk)
        begin
            if(reset)
            begin
                fast_share <= 0;
                fast_share_2 <= 0;
            end
            else
            begin
                fast_share <= copy_back;
                fast_share_2 <= copy_back_2;
            end
        end
            
        always_comb
        begin
            mem_data_out = 32'b0;
            mem_data_out_2 = 32'b0;
            we = 0;
            we_2 = 0;
            fill_in = 128'b0;
            fill_in_2 = 128'b0;
            
            if(main_mem_wr) 
            begin
                case(w_sel)
                    2'b00:
                            begin
                            fill_in [31:0] = mem_data_in;
                            we = 1;
                            end
                    2'b01:
                            begin
                            fill_in [63:32] = mem_data_in;
                            we = 1;
                            end
                    2'b10:
                            begin
                            fill_in [95:64] = mem_data_in;
                            we = 1;
                            end
                    2'b11:
                            begin
                            fill_in [127:96] = mem_data_in;
                            we = 1;
                            end
                    default:
                            fill_in_2 = 128'b0;
                endcase
            end
                
            else if(mem_rd)
            begin
                case(w_sel)
                    2'b00:
                            mem_data_out = fast_share_2? fill_out_2[31:0] : fill_out [31:0];
                    2'b01:
                            mem_data_out = fast_share_2? fill_out_2[63:32] : fill_out [63:32];
                    2'b10:
                            mem_data_out = fast_share_2? fill_out_2[95:64] : fill_out [95:64];
                    2'b11:
                            mem_data_out = fast_share_2? fill_out_2 [127:96] : fill_out [127:96];
                    default:
                            mem_data_out = 32'b0;
                endcase
            end                        
    
            if(main_mem_wr_2) 
            begin
                case(w_sel_2)
                    2'b00:
                            begin
                            fill_in_2 [31:0] = mem_data_in_2;
                            we_2 = 1;
                            end
                    2'b01:    
                            begin
                            fill_in_2 [63:32] = mem_data_in_2;
                            we_2 = 1;
                            end
                    2'b10:
                            begin
                            fill_in_2 [95:64] = mem_data_in_2;
                            we_2 = 1;
                            end
                    2'b11:
                            begin
                            fill_in_2 [127:96] = mem_data_in_2;
                            we_2 = 1;
                            end
                    default:
                            fill_in_2 = 128'b0;
                endcase
            end
    
            else if(mem_rd_2)
            begin 
                case(w_sel_2)
                    2'b00:
                            mem_data_out_2 = fast_share? fill_out[31:0] : fill_out_2 [31:0];
                    2'b01:
                            mem_data_out_2 = fast_share? fill_out[63:32] : fill_out_2 [63:32];
                    2'b10:
                            mem_data_out_2 = fast_share? fill_out[95:64] : fill_out_2 [95:64];
                    2'b11:
                            mem_data_out_2 = fast_share? fill_out[127:96] : fill_out_2 [127:96];
                    default:
                            mem_data_out_2 = 32'b0;
                endcase
            end                                   
        end //comb
endmodule
