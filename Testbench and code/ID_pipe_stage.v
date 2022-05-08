`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage.
    wire reg_dst_w;
    wire mem_to_reg_w;
    wire [1:0] alu_op_w;
    wire mem_read_w;
    wire mem_write_w;
    wire alu_src_w;
    wire reg_write_w;
    wire branch;
    //wire jump;
    wire control_sel;

    assign control_sel=(~Data_Hazard) | Control_Hazard;
    assign jump_address = instr[25:0]<<2;//not too sure
    assign branch_taken = branch & (( reg1 ^ reg2 )==32'd0) ? 1'b1: 1'b0;
    assign branch_address = pc_plus4 + (imm_value[9:0]<<2);

    control control(       
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst_w), 
        .mem_to_reg(mem_to_reg_w),
        .alu_op(alu_op_w),
        .mem_read(mem_read_w),  
        .mem_write(mem_write_w),
        .alu_src(alu_src_w),
        .reg_write(reg_write_w),
        .branch(branch),
        .jump(jump)); 
       
//--------------------------------------------- gotta fix the .a one bc its messed up
    mux2 #(.mux_width(1)) mem2reg_mux(
        .sel(control_sel),
        .a(mem_to_reg_w),
        .b(1'b0),
        .y(mem_to_reg)
    );

    mux2 #(.mux_width(2)) aluop_mux(
        .sel(control_sel),
        .a(alu_op_w),
        .b(2'b0),
        .y(alu_op)
    );

    mux2 #(.mux_width(1)) memr_mux(
        .sel(control_sel),
        .a(mem_read_w),
        .b(1'b0),
        .y(mem_read)
    );

    mux2 #(.mux_width(1)) memw_mux(
        .sel(control_sel),
        .a(mem_write_w),
        .b(1'b0),
        .y(mem_write)
    );

    mux2 #(.mux_width(1)) alusrc_mux(
        .sel(control_sel),
        .a(alu_src_w),
        .b(1'b0),
        .y(alu_src)
    );

    mux2 #(.mux_width(1)) regw_mux(
        .sel(control_sel),
        .a(reg_write_w),
        .b(1'b0),
        .y(reg_write)
    );
//--------------------------------------------------------end of mux
    sign_extend sign(
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value)
    );

    register_file regfile_mux (
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1),
        .reg_read_data_2(reg2));
      
//---------------------------------remaining mux for destination reg
    mux2 #(.mux_width(5)) destination_reg_mux(
        .sel(reg_dst_w),
        .a(instr[20:16]),
        .b(instr[15:11]),
        .y(destination_reg)
    );

endmodule
