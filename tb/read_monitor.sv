`ifndef READ_MONITOR_SV
`define READ_MONITOR_SV
`include "fifo_transaction.sv"
`include "fifo_if.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"

class read_monitor extends uvm_monitor;
    virtual fifo_if vif;
    uvm_analysis_port #(fifo_transaction) ap;
    bit rinc_delay;

    function new(string name = "read_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if(!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("read_monitor", "virtual interface must be set for vif!!!")
    endfunction
    
    extern virtual task collect_one_pkt(fifo_transaction tr);
    extern virtual task main_phase(uvm_phase phase);

    `uvm_component_utils(read_monitor)
endclass

task read_monitor::main_phase(uvm_phase phase);
    fifo_transaction tr;
    super.main_phase(phase);
    rinc_delay = 0;

    wait(vif.rrst_n == 1'b1);

    while(1)begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
    end
endtask

task read_monitor::collect_one_pkt(fifo_transaction tr); 
    while(1)begin
        @(posedge vif.rclk);

        if (vif.rinc && vif.rempty) begin
            `uvm_error("read_monitor", "FATAL: rinc is HIGH while rempty is HIGH! FIFO Underflow!")
        end


        if(rinc_delay == 1'b1) begin
            rinc_delay = vif.rinc && !vif.rempty;
            break; 
        end
        rinc_delay = vif.rinc && !vif.rempty;
    end  
    `uvm_info("read_monitor", "begin to collect one pkt", UVM_HIGH)
    tr.op = fifo_transaction::READ;
    tr.rdata = vif.rdata;
    `uvm_info("read_monitor", "end to collect one pkt and print it", UVM_HIGH)
    tr.print();
endtask

`endif