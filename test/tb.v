`default_nettype none
`timescale 1ns / 1ps

module tb ();
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

`ifdef GL_TEST
    wire VPWR = 1'b1;
    wire VGND = 1'b0;
`endif

    initial begin
        $dumpfile("tb.fst");
        $dumpvars(0, tb);
    end

    tt_um_ro_puf_4_v7 user_project (
`ifdef GL_TEST
        .VPWR(VPWR),
        .VGND(VGND),
`endif
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );
endmodule

`default_nettype wire

// Lightweight RTL models. GL_TEST uses the mapped SKY130 cell library.
`ifndef GL_TEST
module sky130_fd_sc_hd__inv_2 (
    input wire A,
    output wire Y
);
    assign Y = ~A;
endmodule

module sky130_fd_sc_hd__nand2_1 (
    input wire A,
    input wire B,
    output wire Y
);
    assign Y = ~(A & B);
endmodule
`endif
