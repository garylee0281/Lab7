`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:20 09/01/2015 
// Design Name: 
// Module Name:    Lab7_1 
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
`define zero 4'b1111
module Lab7_1(
mode,start_count,clk,rst_n,display_ctl,display,pressed,row_out,col_out,col_n,row_n//,scanf_in3
    );
input mode; 
input start_count; 
input clk,rst_n;
input	[3:0] col_n;
output [14:0] display;
output [3:0] display_ctl; 
output pressed;
output [3:0] row_out,col_out,row_n;
//output [3:0] scanf_in3;
wire clk_out;//1s
wire [1:0]clk_ctl;//for scan
wire clk_150;
wire  [3:0] bcd;
//new
wire [3:0]scanf_in;
wire one_pluse_in;

wire fsm_count;
wire pb_mode;
wire fsm_modein;
wire sel_mode;
wire [3:0]in1,in0,in3,in2;
//¿ï¾Üten¦ì¼Æ
wire fsm_ten;

assign col_out=~col_n;
assign row_out=~row_n;

wire [3:0]tmp_s,tmp_t;
wire[3:0]hr_ss,hr_tt;

//reg[3:0]hr_s,hr_t;
wire sel_t;
//reg [4:0] hr;


/*always@(*)
begin
hr<=tmp_t*10+tmp_s;
end

always@(posedge clk or negedge rst_n)
begin
if(~rst_n)
begin
	hr_s<=4'd0;
	hr_t<=4'd0;
end
	else
	begin
		if(sel_mode==0)
		begin
		hr_s<=tmp_s;
	   hr_t<=tmp_t;
		in0<=4'd0;
		in1<=4'd0;
		end
		else
		begin
			if(hr>12)
			begin
				hr_t<=(hr-12)/10;
				hr_s<=(hr-12)%10;
				in0<=4'd11;
				in1<=4'd12;
			end
			else
			begin
				hr_t<=hr/10;
				hr_s<=hr%10;
				in0<=4'd10;
				in1<=4'd12;
			end
		end
	end
end*/

freq_divider fl(
   .clk_out(clk_out), // divided clock output
	.clk_ctl(clk_ctl), // divided clock output for scan freq
	.clk_150(clk_150),
	.clk(clk), // global clock input
	.rst_n(rst_n) // active low reset
	); 

scanf sl(
   .ftsd_ctl(display_ctl), // ftsd display control signal 
	.ftsd_in(bcd), // output to ftsd display
	.in0(in0), // 1st input
	.in1(in1), // 2nd input
	.in2(in2), // 3rd input
	.in3(in3), // 4th input
	.ftsd_ctl_en(clk_ctl) // divided clock for scan control
	);
bcd_d dl(
   .display(display), // 14-segment display output
	.bcd(bcd) // BCD input
	);
	
keypad_scan ks(
.clk(clk_150), // scan clock
.rst_n(rst_n), // active low reset
.col_n(col_n), // pressed column index
.row_n(row_n), // scanned row index
.key(scanf_in), // returned pressed key
.pressed(pressed) // whether key pressed (1) or not (0)
);	

one_pause_ten opt(
.clk(clk), // clock input
.rst_n(rst_n), //active low reset
.in_trig(pressed), // input trigger
.out_pulse(fsm_ten) // output one pulse
);

fsm_ten ft(
.rst(rst_n),
.clk(clk),
.sel_out(sel_t),
.in(fsm_ten)
    );
debounce debounce_startcounter(
.clk(clk_150), // clock control
.rst_n(rst_n), // reset
.pb_in(start_count), //push button input
.pb_debounced(one_pluse_in) // debounced push button output
);
one_pluse opcount(
.clk(clk), // clock input
.rst_n(rst_n), //active low reset
.in_trig(one_pluse_in), // input trigger
.out_pulse(fsm_count) // output one pulse
);
 fsm_count(
   .rst(rst_n),
	.clk(clk),
	.sel_out(sel_in),
	.in(fsm_count)
    );
count( 
.clk(clk_out), //1s
.sel_in(sel_in), 
.in0(0), 
.in1(0),
.in2(hr_tt), 
.in3(hr_ss),
//.out0(),
//.out1(),
.out2(tmp_t),
.out3(tmp_s),
.rst(rst_n)
);
debounce_mode dml(
.clk(clk_150), // clock control
.rst_n(rst_n), // reset
.pb_in(mode), //push button input
.pb_debounced(pb_mode) // debounced push button output
);
pluse_mode(
.clk(clk), // clock input
.rst_n(rst_n), //active low reset
.in_trig(pb_mode), // input trigger
.out_pulse(fsm_modein) // output one pulse
);
fsm_mode(
    .rst(rst_n),
	 .clk(clk),
	 .sel_out(sel_mode),
	 .in(fsm_modein)
    );
 clock_24( 
 .fast_clk(clk),
 .clk(clk_150),
 .rst_n(rst_n),
 .hr_s(hr_ss),
 .hr_t(hr_tt),
 .sel_in(sel_in),
 .sel_t(sel_t),
 .scanf_in(scanf_in)
    ); 
display_pm_am(
.sel_mode(sel_mode), 
.clk(clk),
.rst_n(rst_n),
.hr_s(in3),
.hr_t(in2),
.in0(in0),
.in1(in1),
.tmp_t(tmp_t),
.tmp_s(tmp_s)
    ); 
endmodule


