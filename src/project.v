/*
 * Tiny Tapeout SKY130 - RO-PUF V7 (fixed unparameterized oscillator modules)
 * Four oscillator lengths: 5, 9, 15, and 23 inverting stages.
 * Each oscillator has one NAND enable stage and (N-1) physical inverters.
 * A 4:1 multiplexer selects one raw frequency output.
 *
 * Unparameterized modules avoid unresolved $paramod instances in the
 * Tiny Tapeout/Yosys synthesis flow.
 *
 * Educational topology-comparison circuit: frequency differences are
 * intentionally influenced by oscillator length, not just device mismatch.
 * RTL/gate-level simulation does not establish physical oscillation.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

(* keep_hierarchy = "yes" *)
module ro_puf_v7_ring_5 (
    input  wire en,
    output wire osc_out
);
    (* keep = "true" *) wire [4:0] ring;

    // One NAND stage provides enable and the required inversion.
    (* keep = "true", dont_touch = "true" *)
    sky130_fd_sc_hd__nand2_1 u_enable (
        .A(ring[4]),
        .B(en),
        .Y(ring[0])
    );

    genvar stage;
    generate
        for (stage = 0; stage < 4; stage = stage + 1) begin : g_inv
            (* keep = "true", dont_touch = "true" *)
            sky130_fd_sc_hd__inv_2 u_inv (
                .A(ring[stage]),
                .Y(ring[stage+1])
            );
        end
    endgenerate

    assign osc_out = ring[4];
endmodule

(* keep_hierarchy = "yes" *)
module ro_puf_v7_ring_9 (
    input  wire en,
    output wire osc_out
);
    (* keep = "true" *) wire [8:0] ring;

    // One NAND stage provides enable and the required inversion.
    (* keep = "true", dont_touch = "true" *)
    sky130_fd_sc_hd__nand2_1 u_enable (
        .A(ring[8]),
        .B(en),
        .Y(ring[0])
    );

    genvar stage;
    generate
        for (stage = 0; stage < 8; stage = stage + 1) begin : g_inv
            (* keep = "true", dont_touch = "true" *)
            sky130_fd_sc_hd__inv_2 u_inv (
                .A(ring[stage]),
                .Y(ring[stage+1])
            );
        end
    endgenerate

    assign osc_out = ring[8];
endmodule

(* keep_hierarchy = "yes" *)
module ro_puf_v7_ring_15 (
    input  wire en,
    output wire osc_out
);
    (* keep = "true" *) wire [14:0] ring;

    // One NAND stage provides enable and the required inversion.
    (* keep = "true", dont_touch = "true" *)
    sky130_fd_sc_hd__nand2_1 u_enable (
        .A(ring[14]),
        .B(en),
        .Y(ring[0])
    );

    genvar stage;
    generate
        for (stage = 0; stage < 14; stage = stage + 1) begin : g_inv
            (* keep = "true", dont_touch = "true" *)
            sky130_fd_sc_hd__inv_2 u_inv (
                .A(ring[stage]),
                .Y(ring[stage+1])
            );
        end
    endgenerate

    assign osc_out = ring[14];
endmodule

(* keep_hierarchy = "yes" *)
module ro_puf_v7_ring_23 (
    input  wire en,
    output wire osc_out
);
    (* keep = "true" *) wire [22:0] ring;

    // One NAND stage provides enable and the required inversion.
    (* keep = "true", dont_touch = "true" *)
    sky130_fd_sc_hd__nand2_1 u_enable (
        .A(ring[22]),
        .B(en),
        .Y(ring[0])
    );

    genvar stage;
    generate
        for (stage = 0; stage < 22; stage = stage + 1) begin : g_inv
            (* keep = "true", dont_touch = "true" *)
            sky130_fd_sc_hd__inv_2 u_inv (
                .A(ring[stage]),
                .Y(ring[stage+1])
            );
        end
    endgenerate

    assign osc_out = ring[22];
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
    // ui_in[1:0] : RO index (00=5, 01=9, 10=15, 11=23 stages)
    // ui_in[2]   : oscillator enable (1=on)
    // ena/rst_n  : Tiny Tapeout global enable and reset; both must be high
    // uo_out[0]  : raw output from the selected oscillator
    // uo_out[7:1]: tied low
    // clk        : unused; oscillators use physical delay feedback

    wire run = ena & rst_n & ui_in[2];
    (* keep = "true" *) wire [3:0] ro_signals;

    // Fixed, distinct cell modules: no parameterized child modules.
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring_5  u_ro0 (.en(run), .osc_out(ro_signals[0]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring_9  u_ro1 (.en(run), .osc_out(ro_signals[1]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring_15 u_ro2 (.en(run), .osc_out(ro_signals[2]));
    (* keep = "true", dont_touch = "true" *)
    ro_puf_v7_ring_23 u_ro3 (.en(run), .osc_out(ro_signals[3]));

    (* keep = "true" *) wire selected_ro = ro_signals[ui_in[1:0]];
    assign uo_out = {7'b0000000, (run & selected_ro)};

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    wire _unused = &{clk, ui_in[7:3], uio_in, 1'b0};
endmodule

`default_nettype wire
