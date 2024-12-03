# test_my_design.py (extended)

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, Timer, Event
from cocotb.binary import BinaryValue
from cocotbext.axi import (AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor, AxiStreamFrame)


#async def generate_clock(dut):
    #"""Generate clock pulses."""

    #for cycle in range(10):
        #dut.aclk.value = 0
        #await Timer(1, units="ns")
        #dut.aclk.value = 1
        #await Timer(1, units="ns")

async def reset_dut(dut):
    dut.arstn.value = 0
    await Timer(3, units="ns")
    dut.arstn.value = 1

@cocotb.test()
async def single_word_test(dut):
    """Try accessing the design."""

    cocotb.start_soon(Clock(dut.aclk, 2, units="ns").start())

    await reset_dut(dut)

    dut._log.info(f"Test Started")

    axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.aclk, dut.arstn, False)
    axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.aclk, dut.arstn, False)
    #axis_mon= AxiStreamMonitor(AxiStreamBus.from_prefix(dut, "m_axis"), dut.aclk, dut.arstn)

    for x in range(0, 256):
        #work on resize
        data = bytes(f"{str(x)}", 'utf-8').ljust(dut.BUS_WIDTH.value, b'0')
        tx_frame = AxiStreamFrame(data, tx_complete=Event())
        await axis_source.send(tx_frame)
        await tx_frame.tx_complete.wait()
        rx_frame = await axis_sink.recv()
        assert rx_frame.tdata == tx_frame.tdata, "data does not match"

    await Timer(5, units="ns")  # wait a bit
    await FallingEdge(dut.aclk)  # wait for falling edge/"negedge"

    dut._log.info(f"Test Complete")

    assert dut.s_axis_tready.value[0] == 1, "tready is not 1!"
