`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:15:49 09/01/2015 
// Design Name: 
// Module Name:    Lab7_2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Lab7_2(
   switch_year,button_mon_date,button_ten,clk,rst_n,display_ctl,display,pressed,row_out,col_out,col_n,row_n
    );
input switch_year;	 
input button_ten;
input button_mon_date;
input clk,rst_n;
input	[3:0] col_n;
output [14:0] display;
output [3:0] display_ctl; 
output pressed;
output [3:0] row_out,col_out,row_n;

wire clk_out;//1s
wire [1:0]clk_ctl;//for scan
wire clk_150;
wire  [3:0] bcd;
wire [3:0]scanf_in;
wire fsm_ten_in;
wire sel_ten;
wire pb_ten;
wire [4:0]clk_date;

wire pb_mon_date;
wire fsm_mon_date;
wire sel_mon_date;

wire [3:0]date_t,date_s,mon_t,mon_s;

assign col_out=~col_n;
assign row_out=~row_n;


freq_divider fl(
   .clk_out(clk_out), // divided clock output
	.clk_ctl(clk_ctl), // divided clock output for scan freq
	.clk_150(clk_150),
	.clk(clk), // global clock input
	.rst_n(rst_n), // active low reset
	.cnt_h(clk_date)
	); 

scanf sl(
   .ftsd_ctl(display_ctl), // ftsd display control signal 
	.ftsd_in(bcd), // output to ftsd display
	.in0(mon_t), // 1st input
	.in1(mon_s), // 2nd input
	.in2(date_t), // 3rd input
	.in3(date_s), // 4th input
	.ftsd_ctl_en(clk_ctl) // divided clock for scan control
	);
bcd_d bl(
   .display(display), // 14-segment display output
	.bcd(bcd) // BCD input
	);
	
keypad_scan ksl(
.clk(clk_150), // scan clock
.rst_n(rst_n), // active low reset
.col_n(col_n), // pressed column index
.row_n(row_n), // scanned row index
.key(scanf_in), // returned pressed key
.pressed(pressed) // whether key pressed (1) or not (0)
);
debounce de_ten(
.clk(clk_150), // clock control
.rst_n(rst_n), // reset
.pb_in(button_ten), //push button input
.pb_debounced(pb_ten)// debounced push button output
);	
one_pause_ten opten(
.clk(clk), // clock input
.rst_n(rst_n), //active low reset
.in_trig(pb_ten), // input trigger
.out_pulse(fsm_ten_in) // output one pulse
);
fsm_ten ft(
.rst(rst_n),
.clk(clk),
.sel_out(sel_ten),
.in(fsm_ten_in)
    );
de_mon_date dmd(
.clk(clk_150), // clock control
.rst_n(rst_n), // reset
.pb_in(button_mon_date), //push button input
.pb_debounced(pb_mon_date) // debounced push button output
);
pluse_mon_date pmd(
.clk(clk), // clock input
.rst_n(rst_n), //active low reset
.in_trig(pb_mon_date), // input trigger
.out_pulse(fsm_mon_date) // output one pulse
);
fsm_mon_date fmd(
   .rst(rst_n),
	.clk(clk),
	.sel_out(sel_mon_date),
	.in(fsm_mon_date)
    );
mon_date md(
.switch_year(switch_year),
.pressed(pressed),
.sel_mon_date(sel_mon_date),
.sel_add_sub(scanf_in),
.sel_ten(sel_ten),
.fast_clk(clk),
.clk(clk_date[3]),
.rst_n(rst_n),
.date_t_out(date_t),
.date_s_out(date_s),
.mon_t_out(mon_t),
.mon_s_out(mon_s)
    );
endmodule
