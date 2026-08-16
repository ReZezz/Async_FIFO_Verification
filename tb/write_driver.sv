`ifndef WRITE_DRIVER_SV
`define WRITE_DRIVER_SV
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "fifo_if.sv"
`include "fifo_transaction.sv"

class write_driver extends uvm_driver #(fifo_transaction);
    virtual fifo_if vif;
    fifo_transaction tr;

    function new(string name = "write_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);                  //因为要消耗仿真时间所以要用task
    extern virtual task drive_one_pkt(fifo_transaction tr);

    `uvm_component_utils(write_driver)
endclass

function void write_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db # (virtual fifo_if)::get(this, "", "vif", vif))
        `uvm_fatal("write_driver", "virtual interface must be set for vif!!!")
endfunction

task write_driver::drive_one_pkt(fifo_transaction tr);
    if(tr.op == fifo_transaction::WRITE) begin
        `uvm_info("write_driver", "begin to drive one pkt", UVM_HIGH)
        while(vif.wfull == 1)begin
            vif.winc <= 1'b0;
            @(posedge vif.wclk);
        end
        vif.winc <= 1'b1;
        vif.wdata <= tr.wdata;

        `uvm_info("write_driver", "end to drive one pkt", UVM_HIGH)
    end
    else begin
        vif.winc <= 1'b0;    
    end
    @(posedge vif.wclk);
    vif.winc <= 1'b0;
endtask

task write_driver::main_phase(uvm_phase phase);
    super.main_phase(phase);
    vif.winc <= 0;
    vif.wdata <= 0;
    while(!vif.wrst_n)
        @(posedge vif.wclk);
    while(1) begin
        seq_item_port.try_next_item(req);
        if(req == null) begin
            vif.winc <= 1'b0;
            @(posedge vif.wclk);
        end
        else begin
            drive_one_pkt(req);
            seq_item_port.item_done();                //别忘了反馈
        end
    end
endtask

`endif