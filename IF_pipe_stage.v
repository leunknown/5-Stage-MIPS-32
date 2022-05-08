`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    wire[9:0] branch;
    wire[9:0] pc_i;
    reg[9:0] pc_o;
    assign pc_plus4 = pc_o + 4;

    mux2 #(.mux_width(10)) branch_mux(
        .sel(branch_taken),
        .a(pc_plus4),
        .b(branch_address),
        .y(branch)
    );

    mux2 #(.mux_width(10)) jump_mux(
        .sel(jump),
        .a(branch),
        .b(jump_address),
        .y(pc_i)
    );

    instruction_mem mux_instr(
        .read_addr(pc_o),
        .data(instr)
    );
/*pc counter*/
always @(posedge clk or posedge reset)
    begin
        if(reset)
            pc_o <= 10'b0;
        else if (en)
            pc_o <= pc_i;
    end
    
endmodule
