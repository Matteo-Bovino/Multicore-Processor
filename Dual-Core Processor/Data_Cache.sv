`timescale 1ns / 1ps


module Data_cache(

        input logic clk, reset, we, re, index, cache_data_src, hit, first, second, copy_back,
        input logic [1:0] store_hb_mem, w_sel, copy,
        input logic [3:0] offset,
        input logic [31:0] alu_to_mem, sourceB_mem, mem_data_out,
        output logic [31:0] read_data_mem
             
    );

//////////////////////////////////////////////////TWO WAY SET ASSOCIATIVE CACHE///////////////////////////////////////////////
        logic [127:0] data_cache [0:3];
        logic [7:0] alu_to_mem12;
        logic [127:0] block, block_c;        
        logic [31:0] word, cache_data_in;

        initial 
        begin
            $readmemh("data_cache.mem", data_cache);//For testing purposes the instruction memory is filled using an initial coefficient file
        end                                                       

        assign alu_to_mem12 = alu_to_mem[7:0];  
        
        always_comb
        begin
            case(index)
                0:
                    if(first) 
                        block = data_cache[0];        //The set containes two ways, thus the first/second enable bits need to
                    else if(second)              // specify which of the two ways is the one needed.
                        block = data_cache[1];                               
                    
                1:  
                    if(first) 
                        block = data_cache[2];        
                    else if(second)              
                        block = data_cache[3];                      
                default:
                    ;
            endcase        
        
            case(copy)
                2'b00:
                        block_c = data_cache[0];                           
                2'b01:  
                        block_c = data_cache[1];                               
                2'b10:
                        block_c = data_cache[2];        
                2'b11:
                        block_c = data_cache[3]; 
                default:
                    ;
            endcase        
       
                    
            case(w_sel)
                2'b11: 
                    word = copy_back? block_c[127:96] : block[127:96];
                2'b10:
                    word = copy_back? block_c[95:64] : block [95:64];
                2'b01:
                    word = copy_back? block_c[63:32] : block [63:32];
                2'b00:                                   
                    word = copy_back? block_c[31:0] : block [31:0];
               default:
                     ;                          
            endcase

            cache_data_in = cache_data_src ? mem_data_out : sourceB_mem; 

        end           
                                                                                         
        always_comb
        begin            
            if(reset)
                data_cache = '{default:256'h0};                 
            else                            //Put write first and reading in the neg edge try that
            begin
                if(re)                         
                    read_data_mem[31:0] =  word;                 
                else
                begin
                    if(we)
                    begin
                        if(hit)
                        begin
                        case(offset)
                            4'b0000:                                
                                if(store_hb_mem == 2'b00)
                                    block [7:0] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [15:0] = cache_data_in[15:0];
                                else
                                    block [31:0] = cache_data_in[31:0];
                                    
                            4'b0001:
                                if(store_hb_mem == 2'b00)
                                    block [15:8] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [23:8] = cache_data_in[15:0];
                                else
                                    block [39:8] = cache_data_in[31:0];

                            4'b0010:
                                if(store_hb_mem == 2'b00)
                                    block [23:16] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [31:16] = cache_data_in[15:0];
                                else
                                    block [47:16] = cache_data_in[31:0];

                            4'b0011:
                                if(store_hb_mem == 2'b00)
                                    block [31:24] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [39:24] = cache_data_in[15:0];
                                else
                                    block [55:24] = cache_data_in[31:0];

                            4'b0100:
                                if(store_hb_mem == 2'b00)
                                    block [39:32] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [47:32] = cache_data_in[15:0];
                                else
                                    block [63:32] = cache_data_in[31:0];

                            4'b0101:
                                if(store_hb_mem == 2'b00)
                                    block [47:40] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [55:40] = cache_data_in[15:0];
                                else
                                    block [71:40] = cache_data_in[31:0];


                            4'b0110:
                                if(store_hb_mem == 2'b00)
                                    block [55:48] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [63:48] = cache_data_in[15:0];
                                else
                                    block [79:48] = cache_data_in[31:0];

                            4'b0111:
                                if(store_hb_mem == 2'b00)
                                    block [63:56] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [71:56] = cache_data_in[15:0];
                                else
                                    block [87:56] = cache_data_in[31:0];
 

                            4'b1000:
                                if(store_hb_mem == 2'b00)
                                    block [71:64] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [79:64] = cache_data_in[15:0];
                                else
                                    block [95:64] = cache_data_in[31:0];

                            4'b1001:
                                if(store_hb_mem == 2'b00)
                                    block [79:72] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [87:72] = cache_data_in[15:0];
                                else
                                    block [103:72] = cache_data_in[7:0];

                            4'b1010:
                                if(store_hb_mem == 2'b00)
                                    block [87:80] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [95:80] = cache_data_in[15:0];
                                else
                                    block [111:80] = cache_data_in[31:0];

                            4'b1011:
                                if(store_hb_mem == 2'b00)
                                    block [95:88] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [103:88] = cache_data_in[15:0];
                                else
                                    block [119:88] = cache_data_in[31:0];

                            4'b1100:
                                if(store_hb_mem == 2'b00)
                                    block [103:96] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [111:96] = cache_data_in[15:0];
                                else
                                    block [127:96] = cache_data_in[31:0];

                            4'b1101:
                                if(store_hb_mem == 2'b00)
                                    block [111:104] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [119:104] = cache_data_in[15:0];
                                else
                               ; // word alignment constraints required the word to begin at a multiple of 4 excluding
                                 // the last possible byte. i.e. The 127th bit can't be the start of a new word
                             // its place is taken by the word starting at 0, so the toal number of 128 words is intact                                                                                                                                                                                                           

                            4'b1110:
                                if(store_hb_mem == 2'b00)
                                    block [119:112] = cache_data_in[7:0];
                                else if(store_hb_mem == 2'b01)
                                    block [127:112] = cache_data_in[15:0];
                                else                                                                                                                                                                                 
                                    ;

                            4'b1111:
                                if(store_hb_mem == 2'b00)
                                    block [127:120] = cache_data_in[7:0];
                                else                                                                                                                                                                                 
                                    ;
                            default:
                                ;                                                                                
                    endcase                                 
                end
                
                else // if the writing is from memory, i.e. no hit
                case(w_sel)
                    2'b11:
                            block [127:96] = cache_data_in;                                                                                           
                    2'b10:                                                      
                            block [95:64] = cache_data_in;                                                         
                    2'b01:                                                      
                            block [63:32] = cache_data_in;                                                          
                    2'b00:            
                            block [31:0] = cache_data_in;                        
                    default:
                        ;
               endcase                         
            end
         end 
         
         if(we)
         case(index)
                0:
                    if(first)
                        data_cache [0] = block;
                    else if(second)
                        data_cache [1] = block;                    
                1: 
                    if(first)
                        data_cache [2] = block;
                    else if(second)
                        data_cache [3] = block;
            default:
                ;         
       endcase 
    end
    end                                                     
endmodule
