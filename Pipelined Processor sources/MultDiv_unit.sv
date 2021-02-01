`timescale 1ns / 1ps


module MultDiv_unit(
        input logic [31:0] sourceA_ex, sourceB_ex,
        input logic mult_ex, div_ex, overflow_ex,
        output logic overflow_trap_md,
        output logic [63:0] res64
    );
        always_comb
        begin
            case({mult_ex, div_ex})
                2'b10:
                    res64 = sourceA_ex * sourceB_ex;                
                2'b01:
                    res64 = {sourceA_ex % sourceB_ex, sourceA_ex / sourceB_ex};
                default:
                    ;//no operation              
                                        
            endcase
           
        if((overflow_ex)&((sourceB_ex[31] == sourceA_ex[31]) & (sourceB_ex[31] == ~res64[63]))) // overflow detection
            overflow_trap_md = 1;
        else
            overflow_trap_md = 0;         
        end
endmodule
