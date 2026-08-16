`ifndef FIFO_ENV_SV
`define FIFO_ENV_SV
`include "read_agent.sv"
`include "write_agent.sv"
`include "fifo_model.sv"
`include "fifo_scoreboard.sv"
`include "fifo_coverage.sv"
`include "fifo_if.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

class fifo_env extends uvm_env;
    virtual fifo_if vif;
    read_agent r_agt;
    write_agent w_agt;
    fifo_model mdl;
    fifo_scoreboard scb;

    uvm_tlm_analysis_fifo #(fifo_transaction) w_agt_mdl_fifo;
    uvm_tlm_analysis_fifo #(fifo_transaction) mdl_scb_fifo;
    uvm_tlm_analysis_fifo #(fifo_transaction) r_agt_scb_fifo;
    fifo_coverage cov;
    

    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);

    `uvm_component_utils(fifo_env)
endclass

function void fifo_env::build_phase(uvm_phase phase);
    super.build_phase(phase);
    r_agt = read_agent::type_id::create("r_agt", this);
    w_agt = write_agent::type_id::create("w_agt", this);
    r_agt.is_active = UVM_ACTIVE;
    w_agt.is_active = UVM_ACTIVE;
    mdl = fifo_model::type_id::create("mdl", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
    w_agt_mdl_fifo = new("w_agt_mdl_fifo", this);
    mdl_scb_fifo = new("mdl_scb_fifo", this);
    r_agt_scb_fifo = new("r_agt_scb_fifo", this);
    cov = fifo_coverage::type_id::create("cov", this);

endfunction

function void fifo_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    w_agt.ap.connect(w_agt_mdl_fifo.analysis_export);
    mdl.port.connect(w_agt_mdl_fifo.blocking_get_export);

    mdl.ap.connect(mdl_scb_fifo.analysis_export);
    scb.expect_port.connect(mdl_scb_fifo.blocking_get_export);

    r_agt.ap.connect(r_agt_scb_fifo.analysis_export);
    scb.actual_port.connect(r_agt_scb_fifo.blocking_get_export);
endfunction

`endif