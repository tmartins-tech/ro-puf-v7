# SPDX-License-Identifier: Apache-2.0
"""RO-PUF V7: smoke tests while the physical oscillator bank is OFF.

Tests safe reset / enable gating and selections without attempting to
simulate inverter-loop oscillation (which requires physical propagation
and is not represented reliably by ideal Verilog logic models).
"""

import cocotb
from cocotb.triggers import Timer


async def verify_disabled(dut, where: str) -> None:
    await Timer(1000, unit="ns")
    out = int(dut.uo_out.value)
    assert out == 0, f"{where}: expected all outputs low, got {out:#04x}"
    assert int(dut.uio_out.value) == 0, f"{where}: uio_out must stay zero"
    assert int(dut.uio_oe.value) == 0, f"{where}: bidirectional pins must stay inputs"


@cocotb.test()
async def test_v7_reset_disable_and_selection(dut):
    dut.clk.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 0
    await verify_disabled(dut, "initial reset")

    # Even with RO_ENABLE asserted, the Tiny Tapeout enable must gate the ROs.
    dut.rst_n.value = 1
    for sel in range(4):
        dut.ui_in.value = 0b100 | sel
        await verify_disabled(dut, f"ena=0 select={sel}")

    # With ena high but local RO_ENABLE low, the loops remain inactive.
    dut.ena.value = 1
    for sel in range(4):
        dut.ui_in.value = sel
        await verify_disabled(dut, f"local enable=0 select={sel}")

    # With rst_n low, even both enables high cannot turn the ROs on.
    dut.rst_n.value = 0
    for sel in range(4):
        dut.ui_in.value = 0b100 | sel
        await verify_disabled(dut, f"reset active select={sel}")

    dut._log.info("V7 inactive-state tests passed; frequency not tested.")
