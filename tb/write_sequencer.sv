`ifndef WRITE_SEQUENCER_SV
`define WRITE_SEQUENCER_SV
`include "fifo_transaction.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

class write_sequencer extends uvm_sequencer #(fifo_transaction);

    function new(string name = "write_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    `uvm_component_utils(write_sequencer)
endclass

`endif