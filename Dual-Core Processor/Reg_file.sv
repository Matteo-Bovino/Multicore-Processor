`timescale 1ns / 1ps

module Reg_file(
        input logic clk, reset,
        input logic [4:0] A1, A2, wr_addr, wr_addr_o,
        input logic [31:0] wr_data, wr_data_o,
        output logic [31:0] RD1, RD2
    );
        
        logic [31:0] reg_file [0:31];
        logic [31:0] RD1_reg, RD2_reg, RD1_next, RD2_next;


        initial 
        begin
        $readmemh("register_file.mem", reg_file);//For testing purposes the instruction memory is filled using an initial coefficient file
        end       
              

        always_comb
        begin
            if(reset)                                  // with reset on, the instruction's operands are automatically read from the reg_fil
            begin 
                RD1_reg = 32'b0;
                RD2_reg = 32'b0; 
                reg_file = '{default:256'h0};           
            end
            else if(clk == 1)                               // from positive edge to negative the writing will take place 
            begin
                reg_file [wr_addr] <= wr_data;               //CONTROL HERE   
            end 
            else if(clk == 0)                                            // from negative to positive the reading will take place
            begin
                RD1_reg = RD1_next;
                RD2_reg = RD2_next;                
            end                     
        end
            
        assign RD1 = RD1_reg;
        assign RD2 = RD2_reg;
        assign RD1_next = reg_file [A1];
        assign RD2_next = reg_file [A2];
        
endmodule