/*
 * Tiny Tapeout SKY130 — RO-PUF V7
 * Four independently instantiated ring oscillators with different lengths:
 * 5, 9, 15, and 23 inverting stages, respectively.
 *
 * Each ring has one NAND enable stage and STAGES-1 SKY130 inverter cells.
 * One 4:1 MUX selects which raw oscillator signal reaches uo_out[0].
 *
 * This is an educational comparison of oscillator lengths, NOT a
 * conventional matched-oscillator PUF. The frequency differences are
 * deliberately influenced by topology, not only manufacturing variability.
 * RTL/gate-level simulation cannot establish physical oscillation.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

(* keep_hierarchy = "yes" *)
module ro_puf_v7_ring #(
    parameter integer STAGES = 5
) (
    input  wire en,
    output wire osc_out
);
    // STAGES must be odd and at least three. Used as 5, 9, 15, 23.
    (* keep = "true" *) wire [STAGES-1:0] ring;

    // Stage 0: enabling NAND. With en=0 the ring settles to a static state.
    (* keep = "true", dont_touch = "true" *)
    sky130_fd_sc_hd__nand2_1 u_enable (
        .A(ring[STAGES-1]),
        .B(en),
        .Y(ring[0])
    );

    genvar stage;
    generate
        for (stage = 0; stage < STAGES-1; stage = stage + 1) begin : g_inv
            (* keep = "true", dont_touch = "true" *)
            sky130_fd_sc_hd__inv_2 u_inv (
                .A(ring[stage]),
                .Y(ring[stage+1])
            );
        end
    endgenerate

    assign osc_out = ring[STAGES-1];
endmodule

module tt_um_ro_puf_4_v7 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // ui_in[1:0] : 00=RO0 (5), 01=RO1 (9), 10=RO2 (15), 11=RO3 (23)
    // ui_in[2]   : local oscillator enable (1=on, 0=off)
    // ena, rst_n : Tiny Tapeout global enable and reset, also required high
    // uo_out[0]  : selected raw ring-oscillator signal
    // uo_out[7:1]: tied low
    // clk        : unused; rings use physical feedback, not external clock

    wire run = ena & rst_n & ui_in[2];
    (* keep = "true" *) wire [3:0] ro_signals;

    // Four deliberately DIFFERENT oscillator lengths.
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring #(.STAGES(5))  u_ro0 (.en(run), .osc_out(ro_signals[0]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring #(.STAGES(9))  u_ro1 (.en(run), .osc_out(ro_signals[1]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring #(.STAGES(15)) u_ro2 (.en(run), .osc_out(ro_signals[2]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring #(.STAGES(23)) u_ro3 (.en(run), .osc_out(ro_signals[3]));

    // MUX 4:1. Keep output low whenever the rings are disabled.
    (* keep = "true" *) wire selected_ro = ro_signals[ui_in[1:0]];
    assign uo_out = {7'b0000000, (run & selected_ro)};

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    wire _unused = &{clk, ui_in[7:3], uio_in, 1'b0};
endmodule

`default_nettype wire
