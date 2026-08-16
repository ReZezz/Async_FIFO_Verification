`ifndef READ_DRIVER_SV
`define READ_DRIVER_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_if.sv"
`include "fifo_transaction.sv"

class read_driver extends uvm_driver#(fifo_transaction);
    virtual fifo_if vif;
    function new(string name = "read_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if)::get(this, "", "vif", vif))
            `uvm_fatal("read_driver", "virtual interface must be set for vif!!!")
    endfunction 

    extern virtual task drive_one_pkt(fifo_transaction tr);
    extern virtual task main_phase(uvm_phase phase);

    `uvm_component_utils(read_driver)
endclass

task read_driver::main_phase(uvm_phase phase);

    super.main_phase(phase);
    vif.rinc <= 1'b0;
    while(!vif.rrst_n)
        @(posedge vif.rclk);
    while(1)begin
        seq_item_port.try_next_item(req);
        if(req == null)begin
            vif.rinc <= 1'b0;
            @(posedge vif.rclk);
        end
        else begin
            drive_one_pkt(req);
            seq_item_port.item_done();
        end
    end
endtask

task read_driver::drive_one_pkt(fifo_transaction tr);
    if(tr.op == fifo_transaction::READ)begin
        `uvm_info("read_driver", "begin to drive one pkt", UVM_HIGH)
        while(vif.rempty == 1) begin
            vif.rinc <= 1'b0;
            @(posedge vif.rclk);
        end
        vif.rinc <= 1'b1;
        `uvm_info("read_driver", "end to drive one pkt", UVM_HIGH)
    end
    else begin
        vif.rinc <= 1'b0;
    end
    @(posedge vif.rclk);
    vif.rinc <= 1'b0;
endtask

`endif