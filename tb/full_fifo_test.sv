`ifndef FULL_FIFO_TEST_SV
`define FULL_FIFO_TEST_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "base_test.sv"
`include "fifo_transaction.sv"
`include "fifo_env.sv"

class write_sequence extends uvm_sequence#(fifo_transaction);
    int pkt_num = 20;

    `uvm_object_utils(write_sequence)

    function new(string name = "write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            tr = new("tr");
            start_item(tr);
            tr.op = fifo_transaction::WRITE;
            tr.wdata = $urandom();
            finish_item(tr);
        end
    endtask
endclass

class full_fifo_test extends base_test;

    function new(string name = "full_fifo_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(full_fifo_test)
endclass

task full_fifo_test::main_phase(uvm_phase phase);
    write_sequence w_seq;

    phase.raise_objection(this);
    `uvm_info("FULL_FIFO_TEST", "Test Started: Pushing more data than FIFO depth...", UVM_LOW)

    w_seq = write_sequence::type_id::create("w_seq");
    
    fork
        w_seq.start(env.w_agt.w_sqr);
        begin
            wait(env.w_agt.w_mon.vif.wfull === 1'b1);
            `uvm_info("FULL_FIFO_TEST", "FIFO is FULL now!", UVM_MEDIUM)
        end
    join
    #1000ns;
    phase.drop_objection(this);
    `uvm_info("FULL_FIFO_TEST", "Test Finished. Check Scoreboard for consistency.", UVM_LOW)
endtask

`endif