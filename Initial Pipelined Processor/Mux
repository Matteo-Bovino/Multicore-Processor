`timescale 1ns / 1ps


module MUX(
        input logic [31:0] PC4, NPC4, 
        input logic branch,
        output logic [31:0] PCnext
    );
        
        always_comb
            case(branch)                
                                 
                1:
                    PCnext = NPC4; // if a branch occurs the new PC is PC + 4 + OFFSET 
               
              default:
                    PCnext = PC4;
            endcase                        
endmodule
