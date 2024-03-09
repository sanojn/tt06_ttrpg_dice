/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock, 32768 Hz
    input  wire       rst_n     // reset_n - low to reset
);

    // Synchronize reset input to avoid metastability
    // Use rst_sync as internal asynchronous reset
    reg rst_sync1, rst_sync;
    always @(negedge clk)
        {rst_sync, rst_sync1} = {rst_sync1, rst_n};
    
    wire btn4, btn6, btn8, btn10, btn12, btn20, btn100;
    //debouncer (clk, rst_sync, ui_in[0], btn4);
    //debouncer (clk, rst_sync, ui_in[1], btn6);
    //debouncer (clk, rst_sync, ui_in[2], btn8);
    //debouncer (clk, rst_sync, ui_in[3], btn10);
    //debouncer (clk, rst_sync, ui_in[4], btn20);
    //debouncer (clk, rst_sync, ui_in[5], btn100);
    assign btn4 = ui_in[0];
    assign btn6 = ui_in[1];
    assign btn8 = ui_in[2];
    assign btn10 = ui_in[3];
    assign btn12 = ui_in[4];
    assign btn20 = ui_in[5];
    assign btn100 = ui_in[6];
    
    wire anybtn;
    assign anybtn = btn4 | btn6 | btn8 | btn10 | btn12 | btn20 | btn100;
    
    reg [3:0] digit1, digit10;
    always @(posedge clk)
        if (rst_sync==0) begin
          digit10 <= 4'd0; digit1 <= 4'd1;
        end
        else if (anybtn) begin
            if (digit10 == 4'd0 && digit1 == 4'd1 && !btn100) begin
                if      (btn4)   begin digit10 <= 4'd0; digit1 <= 4'd4; end
                else if (btn6)   begin digit10 <= 4'd0; digit1 <= 4'd6; end
                else if (btn8)   begin digit10 <= 4'd0; digit1 <= 4'd8; end
                else if (btn10)  begin digit10 <= 4'd1; digit1 <= 4'd0; end
                else if (btn12)  begin digit10 <= 4'd1; digit1 <= 4'd2; end
                else if (btn20)  begin digit10 <= 4'd2; digit1 <= 4'd0; end
            end
            else begin
                // decrement
                if (digit1 != 0) digit1 <= digit1 - 4'd1;
                else begin
                    digit1 <= 4'd9;
                    if (digit10 == 0) digit10 <= 4'd9; else digit10 <= digit10 - 4'd1;
                end
            end
        end

    // All output pins must be assigned. If not used, assign to 0.
    //assign uo_out[7:0] = {digit10, digit1};
    //assign uio_out = 8'b0;
    //assign uio_oe  = 8'b0;

     sky130_sram_1kbyte_1rw1r_8x1024_8(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Port 0: RW
         clk0(clk),csb0(ui_in[0]),web0(ui_in[1]),wmask0(1'b1),addr0({uio_in[7:0],ui_in[3:2]),din0(digit1,digit10),dout0(uio_out),
// Port 1: R
                                                                     clk1(clk),csb1(ui_in[4]),addr1(digit1,digit10),dout1(uio_oe)
  );
        
endmodule
