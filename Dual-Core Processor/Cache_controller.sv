`timescale 1ns / 1ps

module Cache_controller(
        input logic [31:0] alu_to_mem, alu_to_mem_o,
        input logic [26:0] tag,
        input logic index, wr_en, rd_en, clk, reset, rd_intent_o, wr_intent_o, ex_or_shared_o,
        output logic [4:0] addr_mem,
        output logic [1:0] w_sel, copy,
        output logic stall, cache_wr, cache_rd, mem_rd, main_mem_wr, hit, rst_dly, first, second, cache_data_src, rd_intent, wr_intent, ex_or_shared, copy_back
    );
    
        logic [29:0] tag_cache [0:3]; //two extra bits for valid bit and dirty bit.
        logic [29:0] line_1, line_2, new_entry_1, new_entry_2, new_entry_c;
        logic memory_access, dirty, mem_addr_src, copy_back_now, copy_back_1, copy_back_2, copy_back_3;
        logic hit_1, hit_2;
        logic [4:0] old_tag;
        logic [3:0] offset;
        logic [1:0] MESI, MESI_new;
            
        typedef enum{idle, wr_cache, rd_cache, ww1, ww2, ww3, rw0, rw1, rw2, rw3} state_type;      // FSM multiple stages for each word being transferred,
        state_type current_state, next_state;                                                           // slower but less error prone           
        
        always_ff@(posedge clk, posedge reset)
        begin
            if(reset)
            begin
                current_state <= idle;
            end
            else
            begin
                current_state <= next_state;
                copy_back_1 <= copy_back_now;
                copy_back_2 <= copy_back_1;
                copy_back_3 <= copy_back_2;
            end
        end 
        
        always_ff@(posedge clk, posedge reset)
        begin
            if(reset)
                tag_cache <= '{default:29'h18000000};
            else if((index == 0) & (memory_access))                      // if it gives timing issues, save old index in a register. 
            begin          
                tag_cache [0] <= new_entry_1;
                tag_cache [1] <= new_entry_2;
            end
            else if((index == 1) & (memory_access))                                  
            begin          
                tag_cache [2] <= new_entry_1;
                tag_cache [3] <= new_entry_2;
            end
            else if(rd_intent_o | wr_intent_o)
            begin
                if(copy == 2'b00)
                    tag_cache [0] <= new_entry_c;
                else if(copy == 2'b01)
                    tag_cache [1] <= new_entry_c;
                else if(copy == 2'b10)
                    tag_cache [2] <= new_entry_c;
                else if(copy == 2'b11)
                    tag_cache [3] <= new_entry_c;                    
            end                  
        end
            
        assign offset = alu_to_mem[3:0];
        assign memory_access = (wr_en | rd_en);        
        assign copy_back = copy_back_now | copy_back_1 | copy_back_2 | copy_back_3;            //Copy back must remain high for the duration of the write back.                   
                         
        always_comb
        begin           
            if(mem_addr_src) 
                addr_mem = copy_back? alu_to_mem_o[8:4] : old_tag;
            else
                addr_mem = alu_to_mem[8:4]; 
                           
            case(index)
                0:
                    begin
                    line_1 = tag_cache [0];
                    line_2 = tag_cache [1];
                    end
                1:
                    begin
                    line_1 = tag_cache [2];
                    line_2 = tag_cache [3];
                    end                
                
              default:
                    ;
            endcase
             
            if(memory_access)
            begin
                if(tag == line_1[26:0])
                begin
                    hit_2 = 0;
                    hit_1 = (line_1[28:27] == 2'b11) ? 0 : 1; //to indicate that the data is not valid, all valid bits are automatically set to 2'b11 at reset
                    dirty = (line_1[28:27] == 2'b00)? 1 : 0;    
                    first = 1;                          //signals used to allow precise identification of the block in data cache.
                    second = 0;          
                end
               
                else if(tag == line_2[26:0])
                begin
                    hit_1 = 0;
                    hit_2 = (line_2[28:27] == 2'b11)? 0 : 1; //to indicate that the data is not valid, all valid bits are automatically set to zero at reset
                    dirty = (line_2[28:27] == 2'b00)? 1 : 0;    
                    first = 0;                         
                    second = 1;                                                         
                end
                else
                begin  
                    hit_1 = 0;
                    hit_2 = 0;
                        if(line_1[28:27] == 2'b11)      // First we chek if any of the two ways hold invalid data, if so, they can be safely ejected
                        begin
                            dirty = 0;
                            first = 1;
                            second = 0;
                        end
                        else if(line_2[28:27] == 2'b11)
                        begin
                            dirty = 0;
                            first = 0;
                            second = 1;                        
                        end
                        else
                        begin
                            if(line_2[29] == 0) //This line is not the most recently used, so it will be the one ejected
                            begin
                                dirty = (line_2[28:27] == 2'b00) ? 1 : 0;
                                first = 0;
                                second = 1;  
                                old_tag = {line_2[3:0], index};                                                      
                            end
                            else
                            begin
                                dirty = (line_1[28:27] == 2'b00) ? 1 : 0;
                                first = 1;
                                second = 0;
                                old_tag = {line_1[3:0], index};                                                       
                            end
                        end            
                  end
            end            
            else
            begin
                dirty = 0;
                hit_1 = 0;
                hit_2 =0;
            end 
                
            if(hit_1 | hit_2)  
            begin                  
                new_entry_1 = first ? {1'b1, MESI_new, line_1[26:0]} : second? {1'b0, line_1[28:0]} : new_entry_1;  //To implement LRU in a 2 way set            
                new_entry_2 = second ? {1'b1, MESI_new, line_2[26:0]} : first? {1'b0, line_2[28:0]} : new_entry_2;  //associative cache, only two bits are needed
            end
            else
            begin
                new_entry_1 = first ? {1'b1, MESI_new, tag[26:0]} : second? {1'b0, line_1[28:0]} : new_entry_1;  //To implement LRU in a 2 way set            
                new_entry_2 = second ? {1'b1, MESI_new, tag[26:0]} : first? {1'b0, line_2[28:0]} : new_entry_2;  //associative cache, only two bits are needed
            end
                
            case(copy)
                2'b00:
                        new_entry_c = {tag_cache[0][29], MESI_new, tag_cache[0][26:0]};                           
                2'b01:  
                        new_entry_c = {tag_cache[1][29], MESI_new, tag_cache[1][26:1]};                           
                2'b10:
                        new_entry_c = {tag_cache[2][29], MESI_new, tag_cache[2][26:0]};                           
                2'b11:
                        new_entry_c = {tag_cache[3][29], MESI_new, tag_cache[3][26:0]};                           
                default:
                    ;
            endcase
     
            end                                                                                                        
     
            always_comb
            begin       
                next_state = current_state;
                stall = 0; //Active low
                cache_wr = 0;
                cache_rd = 0;
                mem_rd = 0;
                main_mem_wr = 0;
                cache_data_src = 1;
                mem_addr_src = 1;
                rst_dly = 0;
                w_sel = 2'b00;
                hit = hit_1 | hit_2;                      
                case(current_state)
                            
                idle:
                    begin
                    if(memory_access)
                        begin                    
                        if(rd_en & hit)
                            begin                        
                            //next_state = rd_cache;                  //Operations take place now in order to correct timing activation of the signals
                            stall = 1;
                            cache_rd = 1;
                            rst_dly = 1;
                            w_sel = offset >> 2;
                            cache_data_src = 0;                            
                            end
                        else if(wr_en & hit)
                            begin
                            //next_state = wr_cache;
                            stall = 1;
                            cache_wr = 1;
                            rst_dly = 1;
                            w_sel = offset >> 2;
                            cache_data_src = 0;
                            end
                        else if(~hit & ~dirty)  //Whenever a miss occurs the data must be loaded from memory, after that the cache can be used
                            begin
                            next_state = rw0;   //rw0 has ben automatically added here, although it is still present since it may be accessed from ww3
                            //mem_rd = 1;
                            //cache_wr = 1;
                            mem_addr_src = 0; // ?????????????????????????????????????????????????????????????????????????????/
                            end
                        else if(~hit & dirty)
                            begin
                            next_state = ww1;   //ww0 has been automatically added here 
                            main_mem_wr = 1;
                            cache_rd = 1;                    
                            end
                        end 
                    else if(copy_back)
                        begin
                        next_state = ww1;   
                        main_mem_wr = 1;
                        cache_rd = 1;                         
                        end
                    else
                        begin
                        stall = 1;
                        rst_dly = 1;
                        end
                    end                                                                                      
                                                
            rd_cache:                        
                    begin
                    stall = 1;
                    rst_dly = 1;
                    cache_rd = 1;
                    next_state = idle;
                    cache_data_src = 0;                                                
                    end

            wr_cache:                        
                    begin
                    stall = 1;
                    rst_dly = 1;
                    cache_wr = 1;
                    next_state = idle;
                    cache_data_src = 0;
                    end 

                 ww1:                        
                    begin
                    hit = 0;
                    main_mem_wr = 1;
                    //mem_rd = 1; //
                    cache_rd = 1;
                   // cache_wr = 1; //
                    w_sel = 2'b01;                                                            
                    next_state = ww2;
                    end  

                 ww2:                        
                    begin
                    hit = 0;                    
                    main_mem_wr = 1;
                   // mem_rd = 1;//
                    cache_rd = 1;
                    w_sel = 2'b10;                    
                    next_state = ww3;
                    end 

                 ww3:                        
                    begin
                    hit = 0;                    
                    main_mem_wr = 1;
                    cache_rd = 1;
                    w_sel = 2'b11;
                    if(copy_back)
                        next_state = idle;   
                    else 
                        next_state = rw0;                        
                    end

                 rw0:                        
                    begin
                    mem_rd = 1;
                    cache_wr = 1;
                    mem_addr_src = 0;
                    next_state = rw1;
                    hit = 0;                    
                    end                     

                 rw1:                        
                    begin
                    mem_rd = 1;
                    cache_wr = 1;
                    mem_addr_src = 0;
                    w_sel = 2'b01;                    
                    next_state = rw2;
                    hit = 0;                    
                    end   

                 rw2:                        
                    begin
                    mem_rd = 1;
                    cache_wr = 1;
                    mem_addr_src = 0;
                    w_sel = 2'b10;
                    next_state = rw3;
                    hit = 0;                    
                    end 

                 rw3:                        
                    begin
                    hit = 0;                    
                    mem_rd = 1;
                    cache_wr = 1;
                    mem_addr_src = 0;
                    w_sel = 2'b11; 
                    if(rd_en)                   
                        next_state = rd_cache;
                    else if(wr_en)
                        next_state = wr_cache;
                    else
                        next_state = idle;
                    end                                                                                                                                                                         
                 
                 default:
                        next_state = idle;                              
           endcase                              
        end
        
        always_comb                     //Snooping based cache coherency protocol, Write Invalidate.
            begin
            if(memory_access)
                begin
                if(hit)
                    MESI = hit_1? line_1[28:27] : hit_2? line_2[28:27] : MESI; 
                else 
                    MESI = 2'b11;           //For a miss the data is automatically in the invalid state                
                end                      
                                                       
            else if(alu_to_mem_o[31:5] == tag_cache[0][26:0])
                begin
                MESI = tag_cache[0][28:27];
                copy = 2'b00;
                end    
            else if(alu_to_mem_o[31:5] == tag_cache[1][26:0]) 
                begin
                MESI = tag_cache[1][28:27];
                copy = 2'b01;
                end                                
            else if(alu_to_mem_o[31:5] == tag_cache[2][26:0]) 
                begin
                MESI = tag_cache[2][28:27];
                copy = 2'b10;
                end                                   
            else if(alu_to_mem_o[31:5] == tag_cache[3][26:0]) 
                begin
                MESI = tag_cache[3][28:27];
                copy = 2'b11;
                end                
                                  
                
            rd_intent = 0;
            wr_intent = 0;
            MESI_new = MESI;
            ex_or_shared = 0; 
            copy_back_now = 0;           
            case(MESI)
                2'b00:                      //Modified state
                    begin
                    if(hit)
                        MESI_new = 2'b00; 
                    else if(wr_intent_o)
                        begin
                        MESI_new = 2'b11;
                        copy_back_now = 1;  
                        end                     
                    else if(rd_intent_o)
                        begin
                        MESI_new = 2'b10;
                        copy_back_now = 1;
                        end
                    end
                    

                2'b01:                      //Exclusive state
                    begin
                    if(rd_en & hit)
                        MESI_new = 2'b01; 
                    else if(wr_en & hit)
                        MESI_new = 2'b00; 
                    else if(wr_intent_o)
                        MESI_new = 2'b11; 
                    else if(rd_intent_o)
                        begin
                        MESI_new = 2'b10;
                        ex_or_shared = 1;           //If the other cache receives a value of 1 that means the data has to be considered in the Shared state
                        end                         
                    end 

                2'b10:                      //Shared state
                    begin
                    if(wr_en & hit)
                        begin
                        MESI_new = 2'b00; 
                        wr_intent = 1;
                        end
                    else if(rd_en & hit)
                        MESI_new = 2'b10;                     
                    else if(wr_intent_o)
                        MESI_new = 2'b11;                     
                    else if(rd_intent_o)
                        begin
                        MESI_new = 2'b10;
                        ex_or_shared = 1;       //If the other cache receives a value of 0, on the other hand, that means the data has to be 
                        end                     //considered in the Exclusive state
                    end     

                2'b11:                      //Invalid state
                    begin
                    if(wr_en & ~hit)
                        begin
                        MESI_new = 2'b00; 
                        wr_intent = 1;
                        end
                    else if(rd_en & ~hit)
                        begin
                        rd_intent = 1;
                        MESI_new = ex_or_shared_o? 2'b10 : 2'b01; 
                        end                                                  
                    end  
                 //write for this or that processor, diff line diff mesi
                default:
                    ;
            endcase                                                    
        end      
endmodule
