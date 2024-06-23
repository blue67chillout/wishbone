// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter   [31:0]  BASE_ADDRESS    = 32'h3000_0000,
    parameter   [31:0]  New_add   = 32'h3000_0004
    
    
   ) (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    input wire          clk,
    input wire          reset,

    // wishbone slave ports
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output [31:0] wbs_dat_o,

    output [4:0]sum,
    output [4:0] io_oeb
   
);
    wire valid;
    wire [3:0]sel;
    wire [7:0]wdata;
    reg [4:0]rdata;
    reg [4:0] sum;
    reg [3:0] a, b;
   //assign result = sum;
    assign io_oeb = 5'b0;

//wishbone write
    assign valid = wbs_cyc_i && wbs_stb_i ;
    assign sel = wbs_sel_i & {4{wbs_we_i}} ; 
    assign wdata = wbs_dat_i[7:0]   ;
    assign wbs_dat_o = {{27{1'b0}},rdata};

    always@(posedge clk) begin
        sum <= a + b;
    end
   
// wishbone write
    always @(posedge clk ) begin
        if(reset) begin
          wbs_ack_o <=0;
            end
        else begin 
            wbs_ack_o <=0;
            if(valid && wbs_we_i && !wbs_ack_o && (wbs_adr_i == BASE_ADDRESS || wbs_adr_i == New_add)) begin
            wbs_ack_o <=1;
            a <= wdata[3:0];
            b <= wdata[7:4];
             end
        end
    end

// wishbone read

    always@(posedge clk) begin
        if (reset) begin
            wbs_ack_o <=0;
        end
        else begin
        
        if ( !wbs_we_i && wbs_cyc_i && wbs_stb_i && (wbs_adr_i == BASE_ADDRESS ) ) begin
            wbs_ack_o <=1;
            rdata <= sum;
            
        end
        end
    end

   /* always@(posedge clk) begin
        if(reset) begin
            wbs_ack_o = 0;
        end
        else if(wbs_stb_i &&  (wbs_adr_i == BASE_ADDRESS  )) begin
            wbs_ack_o = 1;
        end
    end*/

    
endmodule

`default_nettype wire
