`ifndef WRITE_AGENT_SV
`define WRITE_AGENT_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "write_driver.sv"
`include "write_monitor.sv"
`include "write_sequencer.sv"

class write_agent extends uvm_agent;
    write_driver w_drv;
    write_monitor w_mon;
    write_sequencer w_sqr;
    uvm_analysis_port #(fifo_transaction) ap;

    function new(string name = "write_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(write_agent)
endclass

function void write_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active() == UVM_ACTIVE)begin
        w_drv = write_driver::type_id::create("w_drv", this);
        w_sqr = write_sequencer::type_id::create("w_sqr", this);
    end
    w_mon = write_monitor::type_id::create("w_mon", this);
endfunction

function void write_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE)begin
        w_drv.seq_item_port.connect(w_sqr.seq_item_export);       
    end
    ap = w_mon.ap;
endfunction

`endif