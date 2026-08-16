`ifndef READ_SEQUENCER_SV
`define READ_SEQUENCER_SV
`include "fifo_transaction.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

class read_sequencer extends uvm_sequencer#(fifo_transaction);

    function new(string name = "read_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    `uvm_component_utils(read_sequencer)
endclass

`endif