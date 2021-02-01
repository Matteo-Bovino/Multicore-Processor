`timescale 1ns / 1ps

module Reg_file(
        input logic clk, reset,
        input logic [4:0] A1, A2, wr_addr,
        input logic [31:0] wr_data,
        output logic [31:0] RD1, RD2
    );
        
        logic [31:0] reg_file [0:31];
        logic [31:0] RD1_reg, RD2_reg, RD1_next, RD2_next;

        genvar j;
        generate
            for (j=0; j<2**5; j++) 
                assign reg_file[j] = $urandom(); 
        endgenerate        
              

        always_comb
        begin
            if(reset)                                  // with reset on, the instruction's operands are automatically read from the reg_fil
                begin 
                RD1_reg = reg_file [A1];
                RD2_reg = reg_file [A2];             
                end
            else if(clk == 1)                               // from positive edge to negative the reading will take place 
                begin
                RD1_reg = RD1_next;
                RD2_reg = RD2_next;
                end 
            else
                begin
                reg_file [wr_addr] <= wr_data;            // from negative to positive the writing will take place 
                end                     
            end
            
        assign RD1 = RD1_reg;
        assign RD2 = RD2_reg;
        assign RD1_next = reg_file [A1];
        assign RD2_next = reg_file [A2];
        
endmodule