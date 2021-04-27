`timescale 1ns / 1ps

module Instruction_cache(
        
        input logic [31:0] A,
        output logic [31:0] RD
    );
        logic [31:0] instruction_ROM [0:15];
        logic [3:0] AT;
                
        initial 
        begin
        $readmemb("Instruction_memory.mem", instruction_ROM);//For testing purposes the instruction memory is filled using an initial coefficient file
        end                                                    // containing the Fibonacci sequence

        assign AT= A >> 2;        
        assign RD = instruction_ROM[AT];                    // if NOP is asserted an sll instruction with zero takes place i.e No Operation
endmodule

