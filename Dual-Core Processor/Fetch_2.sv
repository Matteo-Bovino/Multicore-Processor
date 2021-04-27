`timescale 1ns / 1ps

module Fetch_2(

        input logic [31:0] NPC4_f, NPC4_jr, correct_pc, branch,
        input logic clk, reset, prediction, NOP, wrong, stall_fetch_now, jump_r, jump, hlt,
        output logic [31:0] instruction, instruction_pls, PC4_f, PC4, pc                             
    );
    
        logic [31:0]  PCnext;
        logic [31:0]  instruction_reg, instruction_next;
        
        MUX mux_1(.*);
        Instruction_ROM_2 instr_ROM2 (.RD(instruction_next), .A(pc));        
        PC program_counter1 (.*);                        
        
        assign instruction_pls = (NOP | wrong) ? 32'b0 : instruction_next;
    
        always_ff@(posedge clk, posedge reset, posedge stall_fetch_now)
        begin
            if(stall_fetch_now)
                      ;                   //Do not update the values if stall is in place or the program has reached the end.
            else if(reset | NOP)
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