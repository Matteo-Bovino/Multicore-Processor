`timescale 1ns / 1ps

module FETCH(

        input logic [31:0] NPC4,
        input logic branch, reset, clk, NOP,
        output logic [31:0] instruction, PC4_f                     
    );
    
    logic [31:0] PC4, PCnext, pc;
    logic [31:0]  instruction_reg, instruction_next, instruction_pls;
        
        MUX mux_1(.*);
        PC program_counter1 (.*);
        INSTRUCTION_MEMORY instruction_mem1 (.RD(instruction_next), .A(pc));
        
    assign instruction_pls = NOP ? 32'b0 : instruction_next;
    
    always_ff@(posedge clk, posedge reset)
        begin
        if(reset) 
            instruction_reg <= 0;
        else 
        begin
            instruction_reg <= instruction_pls;
            PC4_f <= PC4;
        end
        end
        assign instruction = instruction_reg;
        assign PC4 = pc + 4;
endmodule
