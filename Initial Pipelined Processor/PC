`timescale 1ns / 1ps


module PC(
        input logic [31:0] PCnext, 
        input logic reset , clk,
        output logic [31:0] pc
    );
        logic [31:0] PCreg;

        assign pc = PCreg;
        
        always_ff@(posedge clk, posedge reset)
            if(reset)
                begin
                PCreg <= 0;                
                end
            else
                PCreg <= PCnext;
endmodule
