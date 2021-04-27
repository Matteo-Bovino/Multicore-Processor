`timescale 1ns / 1ps


module INSTRUCTION_MEMORY(
        
        input logic [31:0] A,
        output logic [31:0] RD
    );
        logic [31:0] instruction_ROM [0:2**12-1];
        logic [11:0] AT;
        assign AT= A[11:0];
        //initial 
        //$readmemb{"MIPS_INSTRUCTIONS_MEMORY", rom);   For simulation purposes the register file and the instruction memory are filled using
                                                     // randomly generated values.
        genvar i;
        generate
            for (i=0; i<2**12; i++) 
                assign instruction_ROM[i] = $urandom(); 
        endgenerate
        
        assign RD = instruction_ROM[AT]; // if NOP is asserted an sll instruction with zero takes place i.e No Operation
endmodule
