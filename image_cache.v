`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/05 19:19:35
// Design Name: 
// Module Name: image_cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "enet_head.vh"
module image_cache(
    input                                           clk,
    input                                           rst_n,
    input                                           module_en,
    input                                           over,
//    input                                           padding_flag,
    input                                           row_switch_en,
    input           [`PRECISION*`CROW-1:0]          cache_input,
    input           [`CROW-1:0]                     din_valid,
    output          [`PRECISION*`CSIZE-1:0]         cache_output,
    output  reg     [`CSIZE-1:0]                    dout_valid
    );
    
    reg [`PRECISION-1:0]image_cache[`CSIZE-1:0];
    reg [1:0] cache_cnt;
    wire din_en;
    assign din_en = |din_valid;
    genvar i;
    generate
        for(i=0;i<`CSIZE;i=i+1)
        begin
            assign cache_output[(i+1)*`PRECISION-1:i*`PRECISION] = image_cache[i];
        end
    endgenerate
    
    always@(posedge clk,negedge rst_n)
    begin
        if(!rst_n)
        begin
            image_cache[0] <= 8'h0;
            image_cache[1] <= 8'h0;
            image_cache[2] <= 8'h0;
            image_cache[3] <= 8'h0;
            image_cache[4] <= 8'h0;
            image_cache[5] <= 8'h0;
            image_cache[6] <= 8'h0;
            image_cache[7] <= 8'h0;
            image_cache[8] <= 8'h0;
            dout_valid <= 9'h00;
        end
        else if(over)
        begin
            image_cache[0] <= 8'h0;
            image_cache[1] <= 8'h0;
            image_cache[2] <= 8'h0;
            image_cache[3] <= 8'h0;
            image_cache[4] <= 8'h0;
            image_cache[5] <= 8'h0;
            image_cache[6] <= 8'h0;
            image_cache[7] <= 8'h0;
            image_cache[8] <= 8'h0;
        end
        else 
        begin
            if(module_en)
            begin
                if(din_en)
                begin
                    image_cache[0] <= image_cache[1];
                    image_cache[3] <= image_cache[4];
                    image_cache[6] <= image_cache[7];
                    image_cache[1] <= image_cache[2];
                    image_cache[4] <= image_cache[5];
                    image_cache[7] <= image_cache[8];
                    image_cache[2] <= cache_input[`PRECISION-1:0];
                    image_cache[5] <= cache_input[`PRECISION*2-1:`PRECISION];
                    image_cache[8] <= cache_input[`PRECISION*3-1:`PRECISION*2];
                    if(cache_cnt==3)
                    begin
                        dout_valid <= 9'b1111_1111_1;
                    end
                    else
                    begin
                        dout_valid <= 9'b0000_0000_0;
                    end
                end
            end
        end
    end
    
    
    always@(posedge clk,negedge rst_n)
    begin
        if(!rst_n)
        begin
            cache_cnt <= 0;
        end
        else if(over)
        begin
            cache_cnt <= 0;
        end
        else 
        begin
            if(module_en)
            begin
                if(din_en)
                begin
                    if(row_switch_en)
                    begin
                        cache_cnt <= 0;
                    end
                    else
                    begin
                        if(cache_cnt==3)
                            cache_cnt <= cache_cnt;
                        else
                            cache_cnt <= cache_cnt + 1;
                    end
                end
                else
                begin
                    cache_cnt <= cache_cnt;
                end
            end
        end
    end
    
    
    
    
    
endmodule
