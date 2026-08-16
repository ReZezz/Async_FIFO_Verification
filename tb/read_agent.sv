`ifndef READ_AGENT_SV
`define READ_AGENT_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "read_driver.sv"
`include "read_monitor.sv"
`include "read_sequencer.sv"
`include "fifo_transaction.sv"

class read_agent extends uvm_agent;
    read_driver r_drv;
    read_monitor r_mon;
    read_sequencer r_sqr;
    uvm_analysis_port #(fifo_transaction) ap;

    function new(string name = "read_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(read_agent)
endclass

function void read_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(get_is_active() == UVM_ACTIVE)begin
        r_drv = read_driver::type_id::create("r_drv", this);
        r_sqr = read_sequencer::type_id::create("r_sqr", this);
    end
    r_mon = read_monitor::type_id::create("r_mon", this);
endfunction

function void read_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE)begin
        r_drv.seq_item_port.connect(r_sqr.seq_item_export);  
    end
    ap = r_mon.ap;
endfunction

`endif