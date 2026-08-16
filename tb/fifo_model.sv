`ifndef FIFO_MODEL_SV
`define FIFO_MODEL_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_transaction.sv"

class fifo_model extends uvm_component;
    uvm_blocking_get_port #(fifo_transaction) port;
    uvm_analysis_port #(fifo_transaction) ap;

    function new(string name = "fifo_model", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    extern virtual function void build_phase(uvm_phase phase);

    `uvm_component_utils(fifo_model)
endclass

function void fifo_model::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    port = new("port", this);
    ap = new("ap", this);
endfunction

task fifo_model::main_phase(uvm_phase phase);
    fifo_transaction tr;                               //来自write_monitor的包
    fifo_transaction new_tr;
    super.main_phase(phase);
    while(1)begin
        port.get(tr);                                  //这里只是get了指针，所以不用创建实例
        if(tr.op == fifo_transaction::WRITE) begin
            new_tr = new("new_tr");
            new_tr.rdata = tr.wdata;
            new_tr.op = fifo_transaction::READ;
            `uvm_info("fifo_model","get one transaction, copy and print it:", UVM_LOW);
            new_tr.print();
            ap.write(new_tr);
        end
    end
endtask
        
`endif