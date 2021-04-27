`timescale 1ns / 1ps


module PC(
        input logic [31:0] PCnext, 
        input logic reset , clk, stall_fetch_now,
        output logic [31:0] pc
    );
        logic [31:0] PCreg;

        assign pc = PCreg;
        
        always_ff@(posedge clk, posedge reset, posedge stall_fetch_now)
            if(stall_fetch_now)
                ;
            else if(reset)
                PCreg <= 0;                
            else
                PCreg <= PCnext;
endmodule
