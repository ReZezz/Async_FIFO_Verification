`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "base_test.sv"
`include "fifo_if.sv"
`include "random_stress_test.sv"

module top_tb;
reg  wclk;
reg  rclk;
reg  wrst_n;
reg  rrst_n;

fifo_if async_if(wclk, rclk, wrst_n, rrst_n);

async_fifo async_fifo(
    .wclk              (wclk),
    .rclk              (rclk),
    .wrst_n            (wrst_n),
    .rrst_n            (rrst_n),
    .winc              (async_if.winc),
    .rinc              (async_if.rinc),
    .wdata             (async_if.wdata),
    .rdata             (async_if.rdata),
    .wfull             (async_if.wfull),
    .rempty            (async_if.rempty)
);

initial begin
    wclk = 0;
    forever begin
        #5 wclk = ~wclk;
    end
end

initial begin
    rclk = 0;
    forever begin
        #7 rclk = ~rclk;
    end
end

initial begin
    wrst_n = 1'b0;
    #100;
    wrst_n = 1'b1;
end

initial begin
    rrst_n = 1'b0;
    #100;
    rrst_n = 1'b1;
end

initial begin
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.w_agt.w_drv", "vif", async_if);
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.w_agt.w_mon", "vif", async_if);

    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.r_agt.r_drv", "vif", async_if);
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.r_agt.r_mon", "vif", async_if);

    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env.cov", "vif", async_if);
    run_test("random_stress_test");
end

endmodule

