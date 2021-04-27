`timescale 1ns / 1ps


module MUX(
        input logic [31:0] PC4, NPC4_f, NPC4_jr, correct_pc, pc,
        input logic prediction, jump, jump_r, wrong, branch, hlt,
        output logic [31:0] PCnext
    );
        logic [31:0] PC_jr, PC_branch, PC_correct;
        
        always_comb
        begin
            PC_branch = (jump) | (prediction & branch) ? NPC4_f : PC4;               //order matters since there is an hierarchy in the control flow
            PC_jr = jump_r ? NPC4_jr : PC_branch;
            PC_correct = wrong ? correct_pc : PC_jr;
            PCnext = hlt? pc : PC_correct; 
        end                   
endmodule
