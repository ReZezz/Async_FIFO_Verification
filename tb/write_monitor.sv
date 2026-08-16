`ifndef WRITE_MONITOR_SV
`define WRITE_MONITOR_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_if.sv"
`include "fifo_transaction.sv"

class write_monitor extends uvm_monitor;
    virtual fifo_if vif;
    uvm_analysis_port #(fifo_transaction) ap;

    function new(string name = "write_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("write_monitor", "virtual interface must be set for vif!!!")
    endfunction

    extern virtual task collect_one_pkt(fifo_transaction tr);
    extern virtual task main_phase(uvm_phase phase);

    `uvm_component_utils(write_monitor)
endclass

task write_monitor::main_phase(uvm_phase phase);                   //重灾区
    fifo_transaction tr;
    wait(vif.wrst_n == 1'b1); 
    while(1)begin   
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
    end
endtask


task write_monitor::collect_one_pkt(fifo_transaction tr);          //重灾区

    while(1) begin
        @(posedge vif.wclk);
        if(vif.winc && vif.wfull) begin
            `uvm_error("WRITE_MONITOR", "FATAL: winc is HIGH while wfull is HIGH! FIFO Overflow!")
        end
        if(vif.winc && !vif.wfull)break;
    end
 
    `uvm_info("write_monitor", "begin to collect one pkt", UVM_HIGH)
    tr.op = fifo_transaction::WRITE;
    tr.wdata = vif.wdata;                                          //单纯的软件类的变量不要使用非阻塞式赋值
    `uvm_info("write_monitor", "end to collect one pkt and print it", UVM_HIGH)
    tr.print();
endtask

`endif