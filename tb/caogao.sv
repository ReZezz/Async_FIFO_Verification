`ifndef SANITY_TEST_SV
`define SANITY_TEST_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "base_test.sv"
`include "fifo_transaction.sv"

class write_sequence extends uvm_sequence#(fifo_transaction);
    rand int pkt_num;
    constraint c_pkt { pkt_num == 100; }

    `uvm_object_utils(write_sequence)

    function new(string name = "write_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize() with {op == fifo_transaction::WRITE;});
            finish_item(tr);
        end
    endtask
endclass

class read_sequence extends uvm_sequence#(fifo_transaction);
    rand int pkt_num;
    constraint c_pkt { pkt_num == 100; }

    `uvm_object_utils(read_sequence)

    function new(string name = "read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize() with {op == fifo_transaction::READ;});
            finish_item(tr);
        end
    endtask
endclass

class sanity_test extends base_test;

    function new(string name = "sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(sanity_test)
endclass

task sanity_test::main_phase(uvm_phase phase);
    write_sequence w_seq;
    read_sequence r_seq;

    phase.raise_objection(this);
    `uvm_info("SANITY_TEST", "Test Started! Objection Raised.", UVM_LOW)

    w_seq = write_sequence::type_id::create("w_seq");
    r_seq = read_sequence::type_id::create("r_seq");

    // 并发运行，同时启动写和读
    fork
        w_seq.start(env.w_agt.w_sqr);
        r_seq.start(env.r_agt.r_sqr);
    join

    phase.drop_objection(this);
    `uvm_info("SANITY_TEST", "Test Finished! Objection Dropped.", UVM_LOW)
endtask

`endif


`ifndef SANITY_TEST_SV
`define SANITY_TEST_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "base_test.sv"
`include "fifo_transaction.sv"

class write_sequence extends uvm_sequence#(fifo_transaction);
    rand int pkt_num;
    constraint c_pkt { pkt_num == 100; }

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

class read_sequence extends uvm_sequence#(fifo_transaction);
    rand int pkt_num;
    constraint c_pkt { pkt_num == 100; }
    `uvm_object_utils(read_sequence)

    function new(string name = "read_sequence");
        super.new(name);
    endfunction

    virtual task body();
        fifo_transaction tr;
        repeat(pkt_num)begin
            tr = new("tr");
            start_item(tr);
            tr.op = fifo_transaction::READ;
            finish_item(tr);
        end
    endtask
endclass

class sanity_test extends base_test;

    function new(string name = "sanity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(sanity_test)
endclass

task sanity_test::main_phase(uvm_phase phase);
    write_sequence w_seq;
    read_sequence r_seq;

    phase.raise_objection(this);
    `uvm_info("SANITY_TEST", "Test Started! Objection Raised.", UVM_LOW)

    w_seq = write_sequence::type_id::create("w_seq");
    r_seq = read_sequence::type_id::create("r_seq");

    fork
        w_seq.start(env.w_agt.w_sqr);
        r_seq.start(env.r_agt.r_sqr);
    join  

    phase.drop_objection(this);
    `uvm_info("SANITY_TEST", "Test Finished! Objection Dropped.", UVM_LOW)
endtask

`endif