module slave_fsm(
    input sda_i,
    input clk_t,
          SCL,
          FIFO_FULL,
          FIFO_EMPTY,
          start_det,
          stop_det,
          rstn,
    input [7:0] rd_data,
    input [6:0] slave_addr_reg,
    output reg sda_o,
               sda_in_en,
               wr_en_fifo,
               rd_en_fifo,
   output reg [7:0] wr_data
);
/*
reg SCL;
always @(negedge clk_t)begin
    SCL <= SCL_i;
end*/

localparam [2:0] IDLE     = 3'd0,
                 ADDR_RW  = 3'd1,
                 //CHECK    = 3'd2,

                 ADDR_ACK   = 3'd3,

                 RECEIVE_DATA = 3'd4,
                 RX_ACK = 3'd5,

                 SEND_DATA= 3'd6,
                 WAIT_ACK = 3'd7;

reg [2:0] state;
reg [3:0] bit;
reg [3:0] count_ack;
reg [6:0] addr_mask = 8'b11111110;
reg [7:0] addr_rw_reg;
reg rw_mask = 1'b1;
reg [7:0] data;

wire [7:0] addr_reg,checker;
assign addr_reg = slave_addr_reg;
assign checker = addr_reg<<1'b1;

always @(negedge clk_t or negedge rstn)begin
    if(!rstn)begin
        state <= IDLE;
        wr_en_fifo <= 1'b0;
        rd_en_fifo <= 1'b0;
        sda_in_en <= 1'b1;
        sda_o <= 1'b1;
    end
    else begin
        case(state)
        IDLE:begin
            sda_in_en <= 1'b1;
            sda_o <= 1'b1;
            if(start_det && SCL == 1'b0)begin
                state<=ADDR_RW;
                sda_in_en <= 1'b1;
                sda_o <= 1'b1;
            end
            else begin
                state<=IDLE;
            end
        end

        ADDR_RW:begin 
            if(bit != 4'd1 ) begin 
                if (SCL == 1'b1)begin
                addr_rw_reg[bit-1]<=sda_i;
                state <= ADDR_RW;
                sda_in_en <= 1'b1;
                sda_o <= 1'b1;
                end
                else begin
                    addr_rw_reg[bit-1]<=addr_rw_reg[bit-1];
                state <= ADDR_RW;
                sda_in_en <= 1'b1;
                sda_o <= 1'b1;
                end
            end
            else if (bit == 4'd1)begin
                addr_rw_reg[bit-1]<=sda_i;
                if({addr_rw_reg[7:1],1'b0} == checker ) begin
                    state <= ADDR_ACK;
                    sda_in_en <= 1'b0;
                end
                else begin
                    state<=IDLE;
                    sda_in_en <= 1'b1;
                end
            end
        end

        ADDR_ACK:begin

            if (SCL == 1'b0 && sda_o != 1'b0)begin
                sda_o <= 1'b0;
                sda_in_en <= 1'b0;
                state <= ADDR_ACK;
            end
            else if(SCL == 1'b0 && sda_o == 1'b0)begin
                if(!count_ack)begin
                    if(addr_rw_reg[0] == 1'b1) begin //////R/!W = 1 --> master reads --> TX SLAVE
                        sda_in_en <= 1'b0;
                        rd_en_fifo <= 1'b1;
                        data <= 8'b10101010;
                        state <= SEND_DATA;
                    end
                    else begin
                        sda_in_en <= 1'b0;
                        sda_o <= 1'b1;
                        state <= RECEIVE_DATA;
                    end
                end
            end
            else if(SCL == 1'b1)begin
                state <= ADDR_ACK;
                sda_in_en <= 1'b0;
            end
        end

/*
            if (SCL == 1'b0)begin
                sda_o <= 1'b0;
                if(sda_o ==1'b0)begin
                    if(!count_ack)begin
                    if(addr_rw_reg[0] == 1'b1) begin //////R/!W = 1 --> master reads --> TX SLAVE
                        sda_in_en <= 1'b0;
                        state <= SEND_DATA;
                    end
                    else begin
                        sda_in_en <= 1'b0;
                        sda_o <= 1'b1;
                        state <= RECEIVE_DATA;
                    end
                    end
                end
                else if (sda_o != 1'b0)begin
                    state <= ADDR_ACK;
                    sda_o <= 1'b0;
                    sda_in_en <= 1'b0;
                end
            end
            else if(SCL ==1'b1)begin
                state <= ADDR_ACK;
            end
        end
*/
        RECEIVE_DATA:begin
            if(!stop_det && !start_det)begin
                if(bit != 4'd1 && SCL == 1'b1)begin
                    data[bit-1] <= sda_i;
                    state <= RECEIVE_DATA;
                end
                else if(bit != 4'd1 && SCL == 1'b1)begin
                    data [bit-1] <= data [bit-1];
                    state <= RECEIVE_DATA;
                end
                else if (bit == 4'd1)begin
                    data[bit-1] <= sda_i;
                    state <= RX_ACK;
                    sda_in_en <= 1'b0;
                end
            end
            else begin
                if(start_det)begin
                    state <= ADDR_RW;
                    sda_in_en<=1'b1;
                end
                else if(stop_det)begin
                    state <= IDLE;
                    sda_in_en<= 1'b1;
                end
            end
        end
    

        RX_ACK:begin
            wr_data <= data;
            wr_en_fifo <= 1'b1;

            if(SCL == 1'b0 && sda_o != 1'b0)begin
                sda_o <= 1'b0;
                sda_in_en <= 1'b0;
                state <= RX_ACK;
            end
            else if(SCL == 1'b0 && sda_o == 1'b0)begin
                if(!count_ack)begin
                    sda_in_en <= 1'b1;
                    sda_o <= 1'b1;
                    wr_en_fifo <= 1'b0;
                    state <= RECEIVE_DATA;
                end
            end
            else if(SCL == 1'b1)begin
                state <= RX_ACK;
                sda_in_en <= 1'b0;
            end
        end
/*
            if (SCL == 1'b0)begin
                sda_o <= 1'b0;
                if(sda_o ==1'b0)begin
                    if(!count_ack)begin
                    sda_in_en <= 1'b1;
                    sda_o <= 1'b1;
                    wr_en_fifo <= 1'b0;
                    state <= RECEIVE_DATA;
                    end
                end
                else if (sda_o != 1'b0)begin
                    state <= RX_ACK;
                    sda_o <= 1'b0;
                    sda_in_en <= 1'b0;
                end
            end
            else if(SCL ==1'b1)begin
                state <= RX_ACK;
            end
        end
*/
        SEND_DATA:begin
            if(bit != 4'd0)begin
                if(SCL == 1'b0)begin
                    sda_o <= data[bit-1];
                    sda_in_en <= 1'b0;
                    state<= SEND_DATA;
                end
                else begin
                    sda_o <= sda_o;
                    sda_in_en <= 1'b0;
                    state<= SEND_DATA;
                end
            end
            else begin
                if(SCL == 1'b1)begin
                    sda_in_en <= 1'b0;
                    sda_o <= sda_o;
                    state <= SEND_DATA;
                end
                else begin
                    sda_in_en <= 1'b1;
                    sda_o <= 1'b1;
                    state <= WAIT_ACK;

                end
            end
        end

        WAIT_ACK:begin
            if(SCL == 1'b1)begin
                if(!count_ack)begin
                if(sda_i == 1'b0)begin
                    state <= SEND_DATA;
                    sda_in_en <= 1'b0;
                end
                else begin
                    state <= IDLE;
                    sda_in_en <= 1'b1;
                end
            end
            else begin
                sda_in_en <= 1'b1;
                state <= WAIT_ACK;
            end
            end
        end
        endcase
    end
end

//we will decrement the bit count every one clock cycle --> two times per one cycle of the SCL
//we might need to set the bit count to 16 instead of 8, and only take in the values of bit[15,13,11,9,7,5,3,1]
//but we only take in sda bits when scl is high --> so we might just take in 4 of the actual bits? needs debugging

always @ (negedge SCL or negedge rstn)begin
	if (!rstn)
		bit <= 4'd8;
	else begin
		if ((state == ADDR_RW || state == RECEIVE_DATA || state == SEND_DATA) /*&& (SCL == 1'b1) /*&& (sda_in_en==1'b1)*/)begin
			bit <= bit - 1'b1;
            if(bit == 4'd0)begin
                bit<=4'd8;
            end 
		end
        
        else begin
            bit <= 4'd8;	
		end
    end
end

always @ (negedge clk_t or negedge rstn)begin
	if (!rstn)
		count_ack <= 4'd2;
	else begin
		if ((state == ADDR_ACK || state == RX_ACK || state == WAIT_ACK ) /*&& (SCL == 1'b1) /*&& (sda_in_en==1'b1)*/)begin
			count_ack <= count_ack - 4'd1; 
		end
        
        else begin
            count_ack <= 4'd2;	
		end
    end
end

endmodule