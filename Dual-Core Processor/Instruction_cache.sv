`timescale 1ns / 1ps

module Instruction_ROM(
        
        input logic [31:0] A,
        output logic [31:0] RD
    );
        (* rom_style = "distributed" *) logic [31:0] instruction_ROM [0:63];
        logic [5:0] AT;
                
        initial 
        begin
            $readmemh("Instructions_1.mem", instruction_ROM);//For testing purposes the instruction memory is filled using an initial coefficient file
        end                                                    // containing the Fibonacci sequence

        always_comb
        begin
            AT= A >> 2;        
            RD = instruction_ROM[AT];                    // if NOP is asserted an sll instruction with zero takes place i.e No Operation
        end
endmodule

