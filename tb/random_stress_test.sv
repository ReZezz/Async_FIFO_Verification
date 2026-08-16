`ifndef RANDOM_STRESS_TEST_SV
`define RANDOM_STRESS_TEST_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "base_test.sv"
`include "fifo_transaction.sv"

class write_stress_sequence extends uvm_sequence#(fifo_transaction);
    int pkt_num = 100;

    `uvm_object_utils(write_stress_sequence)

    function new(string name = "write_stress_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            if($urandom_range(1, 100) < 30) begin
                repeat($urandom_range(0,5)) begin
                    #($urandom_range(1, 5) * 10ns);
                end
            end
            tr = new("tr");
            start_item(tr);
            tr.op = fifo_transaction::WRITE;
            tr.wdata = $urandom();
            finish_item(tr);
        end
    endtask
endclass

class read_stress_sequence extends uvm_sequence#(fifo_transaction);
    int pkt_num = 100;

    `uvm_object_utils(read_stress_sequence)

    function new(string name = "read_stress_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            if($urandom_range(1, 100) < 30) begin
                repeat($urandom_range(0,5)) begin
                    #($urandom_range(1, 5) * 14ns);
                end
            end
            tr = new("tr");
            start_item(tr);
            tr.op = fifo_transaction::READ;
            finish_item(tr);
        end
    endtask
endclass

class random_stress_test extends base_test;

    function new(string name = "random_stress_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(random_stress_test)
endclass

task random_stress_test::main_phase(uvm_phase phase);
    write_stress_sequence w_seq;
    read_stress_sequence r_seq;

    phase.raise_objection(this);
    `uvm_info("RANDOM_STRESS_TEST", "Test Started: Pushing 100 randomized packets into FIFO...", UVM_LOW)

    w_seq = write_stress_sequence::type_id::create("w_seq");
    r_seq = read_stress_sequence::type_id::create("r_seq");

    fork
        w_seq.start(env.w_agt.w_sqr);
        r_seq.start(env.r_agt.r_sqr);
    join

    #1000ns;

    phase.drop_objection(this);
    `uvm_info("RANDOM_STRESS_TEST", "Test Finished. Waiting for Scoreboard final verdict...", UVM_LOW)
endtask

`endif