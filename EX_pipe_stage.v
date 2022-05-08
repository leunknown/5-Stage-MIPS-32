`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    wire [31:0] reg1_o;
    //wire [31:0] reg2_o;
    wire [31:0] together_reg_mux_o;
    wire [3:0] ALU_Control;            //still need to define

    //assign alu_in2_out = reg2_o;
//--------------start of mux-----------------
    mux4 #(.mux_width(32)) reg1_mux(
        .sel(Forward_A),
        .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .y(reg1_o)
    );
    mux4 #(.mux_width(32)) reg2_mux(
        .sel(Forward_B),
        .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .y(alu_in2_out)
    );

    mux2 #(.mux_width(32)) together_reg_mux(
        .sel(id_ex_alu_src),
        .a(alu_in2_out),
        .b(id_ex_imm_value),
        .y(together_reg_mux_o)
    );
//------------ALU----------------------------------
    ALU alu1 (
        .a(reg1_o),
        .b(together_reg_mux_o),
        .alu_control(ALU_Control),
        //.zero(zero),
        .alu_result(alu_result));
    
    ALUControl ALUCont(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control)
    );
endmodule
