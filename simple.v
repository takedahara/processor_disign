





module simple(clk,rst,exec,in,out,out2,out3,out4,seg_out,seg_sel, phase);
	input clk;
	input rst;
	input exec;

	input[15:0]in;
	output[15:0]out;
	output[15:0]out2;
	output[15:0]out3;
	output[31:0]out4;
	output[31:0]seg_out;
	output seg_sel;
	
	
	wire aluc_e, ar_e,br_e,dr_e,mdr_e,ir_e,S,Z,C,V,jump,
	mem_e,mem_w,m2_s,m3_s,m4_s,m5_s,m6_s,m7_s,m8_s,out_s,hlt,reg_write,reg_read;
	wire [3:0] ALU_Cnt; //alu opcode
	wire[5:0] instruction_six;
	wire [15:0] ar; //AR content
	wire[15:0] br; //BR content
	wire[15:0] dr; //DR content
	wire[15:0] mdr; //MDR content
	wire[15:0] ir; //ir content
	wire[15:0] pc; //
	wire[15:0] pc_inc; //pc+1
	wire[15:0] m2;
	wire[15:0] m3;
	wire[15:0] m4;
	wire[15:0] m5;
	wire[15:0] m6;
	wire[15:0] m7;
	wire[15:0] m8;
	wire[15:0] mem_out1; //meireifech
	wire[15:0] mem_out2; //roadmeirei P4
	wire[15:0] exd;
	wire[15:0] re0;
	wire[15:0] re1;
	wire[15:0] pc_out;
	wire [15:0] address;
	wire [15:0] alu_out;
	wire seg_sel;
	wire rst_n;
	wire exec_n;
	assign rst_n=~rst;
	assign exec_n=~exec;
	
	

	reg pc_e;
	wire[15:0]out;
	assign seg_sel=1'b1;

	output reg[2:0]phase=3'b000;
	reg executing = 0; // 実行中・停止中を表す
	reg stop_flag = 0; // if stop_flag == 1, then stop after this instruction


	// 3'b000: 初期状態, 3'b001: Phase１, 3'b010: Phase 2, ...
	always@(posedge clk or negedge rst)begin
		if(rst==0)begin
			phase <= 3'b000;
			executing <=0;  //
			
		end else begin
			
			if (phase == 3'b000) begin // if Phase 0
				
				if ( (executing==0 & exec==0) || (executing==1 & exec==1) ) begin
					 // tamesinikuwaeta
					phase <= phase + 3'b001;
					executing <= 1;
				end else begin
					phase <= 3'b000; //stay in 初期状態
				end
			end
			
			
			
			else if(phase == 3'b101)begin // if Phase 5
				if(stop_flag ||(executing==1 & exec==0)) begin  // ||executing&exec  wo kuwaeta
					phase <= 3'b000;
					executing <= 0;
				end else begin
				phase <= 3'b001;
				
			
				end
			end
			else begin
				phase <= phase + 3'b001;
			end
			
		//	if(hlt==1'b1)begin
		//		stop_flag<=1;
		//	end
			//stop_flag<=hlt;
			
			
			
			 //kokoniarunoha exec tekini mazui
			
			
		end
	end	
	control controls(.rst(rst),.phase(phase),.S(S),.Z(Z),.C(C),
	.V(V),.instruction(ir),.aluc_e(aluc_e),.ar_e(ar_e)
	,.br_e(br_e),.dr_e(dr_e),.mdr_e(mdr_e),.ir_e(ir_e),.reg_e(reg_e),.genr_w(genr_w)
	,.mem_e(mem_e)
	,.mem_w(mem_w),.jump(jump) ,.m2_s(m2_s),.m3_s(m3_s),.m4_s(m4_s)
	,.m5_s(m5_s),.m6_s(m6_s),.m7_s(m7_s),.m8_s(m8_s),.out_s(out_s),.hlt(hlt),.alu_instruction(alu_instruction));
	//MEI wo ir nikaeta
	
	seven sev(.in(mem_out1),.signal(1'b1),.out(seg_out));  //out_s wo 1'b1   ar wo re0
	 //re0 wo kaeta
	
	register_16 IR(.reg_e(clk), .reg_write_en(ir_e), .reg_in(mem_out1) //MEI wo mem_out1
	, .reg_out(ir)); //ir_e wo 1'b1
	
	register_16 AR(.reg_e(clk), .reg_write_en(ar_e), .reg_in(m2)
	, .reg_out(ar));
	
	register_16 BR(.reg_e(clk), .reg_write_en(br_e), .reg_in(m3)
	, .reg_out(br));
	
	register_16 DR(.reg_e(clk), .reg_write_en(dr_e), .reg_in(alu_out)
	, .reg_out(dr));
	
	register_16 MDR(.reg_e(clk),.reg_write_en(mdr_e),.reg_in(m7)
	,.reg_out(mdr));
	
	register_general registerfile(.clk(clk),.rst(rst),
	.reg_write_en(genr_w)   //reg_e wo genr_w nisita
	,.reg_write_dest(m5),.reg_write_data(m8),.reg_read_addr_1(ir[13:11])
	,.reg_read_data_1(re0),.reg_read_addr_2(ir[10:8]),.reg_read_data_2  //MEI wo ir nisita
	(re1)); 
	
	alu_control_unit aluconu(.alu_control_unit_e(aluc_e)
	,.instruction_six(alu_instruction),.ALU_Cnt(ALU_Cnt));
	
	alu alu_0( .opcode(ALU_Cnt),.d(ir[3:0])
	,. alu_in_a(ar), .alu_in_b(br), .alu_out(alu_out), .S(S),.Z(Z)
	,.C(C),.V(V));
	
	ram01 inst_memory(.data(16'b0),.wren(1'b0),.address(pc_out)  
	,.clock(clk),.q(mem_out1));  
	
	//ram01 inst_memory(.data(16'b0),.wren(1'b0),.address(pc_out),.clock(clk),.q(mem_out1));  
	
	ram02 data_memory(.data(re0),.wren(mem_w),.
	address(alu_out),.clock(clk),.q(mem_out2));
	
	
	
	
	program_counter pc_0(.clock(clk),.rst(rst),.j_flag(jump)
	,.j_addr(dr),.phase(phase),.pc_out(pc_out));   
	
	sign_extension siex(.d(ir[7:0]),.result(exd)); //ir[7:0] wo 8'b00001111
	
	
	
	multiplexer_16 m2_0(.mux_s(m2_s),.mux_in_a(re0),.mux_in_b(exd)
	,.mux_out(m2));
	
	multiplexer_16 m3_0(.mux_s(m3_s),.mux_in_a(re1),.mux_in_b(pc_out)
	,.mux_out(m3));
	
	multiplexer_16 m4_0(.mux_s(m4_s),.mux_in_a(dr),.mux_in_b(mdr)
	,.mux_out(m4));
	
	multiplexer_16 m5_0(.mux_s(m5_s),.mux_in_a(ir[13:11]),.mux_in_b(ir[10:8]) //MEI wo ir nisita
	,.mux_out(m5));
	
	multiplexer_16 m6_0(.mux_s(m6_s),.mux_in_a(pc),.mux_in_b(dr)
	,.mux_out(m6));
	
	multiplexer_16 m7_0(.mux_s(m7_s),.mux_in_a(mem_out2),.mux_in_b(in)
	,.mux_out(m7));
	
	multiplexer_16 m8_0(.mux_s(m8_s),.mux_in_a(m4),.mux_in_b(exd)
	,.mux_out(m8));  //m8_s ga 1 ni nattenai

	assign out=mem_out1;
	assign out2=pc_out; //br wo re1
	assign out3=mem_w;
	assign out4=seg_out;
	
	endmodule






