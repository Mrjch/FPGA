`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/06 14:28:18
// Design Name: 
// Module Name: fm_read
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


module fm_read(
    input               clk,
    input               rst_n,
    input               module_en,
    input               refresh,
    input               fm_width,
    input               fm_height,
    output    [2:0]     ram_ren,
    output    [3*11-1:0]      ram_addr          
    );
    
    reg [1:0]state;
    reg [8:0]width_cnt;
    reg [8:0]height_cnt;
    reg [10:0]ram_addr_[0:2];
    genvar i;
    generate
        for(i=0;i<3;i=i+1)
        begin
            assign ram_addr[(i+1)*11-1:i*11] = ram_addr_[i];
        end
    endgenerate
    
    
    always@(posedge clk,negedge rst_n)
    begin
        if(!rst_n)
        begin
            state <= 0;
        end
        else
        begin
            if(module_en)
            begin
                if(width_cnt == fm_width - 1)
                begin
                    width_cnt <= 0;
                    
                    case(state)
                        2'b00:
                        begin
                            ram_addr_[0] <= ram_addr_[0] + 1;
                            ram_addr_[1] <= ram_addr_[1] - fm_width;
                            ram_addr_[2] <= ram_addr_[2] - fm_width;
                            state <= 2'b01;
                        end
                        2'b01:
                        begin
                            ram_addr_[0] <= ram_addr_[0] - fm_width;
                            ram_addr_[1] <= ram_addr_[1] + 1;
                            ram_addr_[2] <= ram_addr_[2] - fm_width;
                            state <= 2'b10;
                        end
                        2'b10:
                        begin
                            ram_addr_[0] <= ram_addr_[0] - fm_width;
                            ram_addr_[1] <= ram_addr_[1] - fm_width;
                            ram_addr_[2] <= ram_addr_[2] + 1;
                            state <= 2'b00;
                        end
                        default:
                        begin
                            ram_addr_[0] <= ram_addr_[0] - fm_width;
                            ram_addr_[1] <= ram_addr_[1] - fm_width;
                            ram_addr_[2] <= ram_addr_[2] - fm_width;   
                            state <= 2'b00;
                        end
                    endcase
                    if(height_cnt <= fm_height - 3) begin
                        ram_addr_[0] <= ram_addr_[0] + 1;
                        ram_addr_[1] <= ram_addr_[0] + 1;
                        ram_addr_[2] <= ram_addr_[0] + 1;
                    end    
                    else
                        height_cnt <= height_cnt + 1;
                end
                else
                begin
                    width_cnt <= width_cnt + 1;
                end
            end
        end
    end
endmodule
