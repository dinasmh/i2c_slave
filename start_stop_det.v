module start_stop_det (
    input sample_clk,
          sda_i,
          det_en,
          rstn,
    output reg start_det,
    output reg stop_det
);

// det_en ======= SCL == 1 
reg [2:0] count,det_count;
reg sda_pos, sda_pos_prev;
reg sda_neg, sda_neg_prev;
reg start_det_int,stop_det_int;
reg reg1,reg1_prev;
reg [1:0] state;
localparam [1:0] IDLE =2'd0,
                 out_start = 2'd1,
                 out_stop = 2'd2;

always @(posedge sample_clk or negedge rstn)begin
    if(!rstn)begin
        start_det<=1'b0;
        stop_det<= 1'b0;
        state <= IDLE;
    end
    else begin
        case (state)

        IDLE: begin
            if(det_en)begin
                reg1 <= sda_i;
                reg1_prev <= reg1;
                if(det_count >= 3'd1 && det_count <= 3'd3)begin
                    if(reg1_prev != reg1)begin
                        if(reg1_prev == 1'b1 && reg1 == 1'b0)begin
                            start_det <= 1'b1;
                            stop_det <= 1'b0;
                            reg1 <= 1'b0;
                            reg1_prev <= 1'b0;
                            state <= out_start;
                        end
                        else if (reg1_prev == 1'b0 && reg1 == 1'b1)begin
                            start_det<=1'b0;
                            stop_det <= 1'b1;
                            reg1 <= 1'b0;
                            reg1_prev <= 1'b0;
                            state <= out_stop;
                        end
                    end
                    else begin
                        start_det <= 1'b0;
                        stop_det <= 1'b0;
                        //reg1_prev <= reg1;
                        state <= IDLE;
                    end
                end
                else begin
                    start_det <= 1'b0;
                    stop_det <= 1'b0;
                    //reg1_prev <= reg1;
                    state <= IDLE;
                end
            end
            else begin
                start_det <= 1'b0;
                stop_det <= 1'b0;
                state <= IDLE;
                //reg1 <= 1'b0;
                //reg1_prev <= 1'b0;
            end
        end
        out_start:begin
            if (count != 3'd0)begin
                state <= out_start;
                start_det <= 1'b1;
                stop_det <= 1'b0;
            end
            else begin
                state <= IDLE;
                start_det <= 1'b0;
                stop_det <= 1'b0;
            end
        end
        out_stop:begin
            if(count != 3'd0)begin
                state <= out_stop;
                start_det <= 1'b0;
                stop_det <= 1'b1;
            end
            else begin
                state <= IDLE;
                start_det <= 1'b0;
                stop_det <= 1'b0;
            end
        end
        default : begin
            state<= IDLE;
        end
        endcase

    end

end

always @ (posedge sample_clk or negedge rstn)begin
    if(!rstn)
        det_count <= 3'd5;
    else begin
        if ((state == IDLE) && det_en)begin
            det_count <= det_count - 1'b1;
            if(det_count == 3'd0)
                det_count <= 3'd5;
        end
        else
            det_count <= 3'd5;
    end
end

always @ (posedge sample_clk or negedge rstn)
	begin
		if (!rstn)
			count <= 3'd5;
		else 
			begin
				if (state == out_start || state == out_stop )
					begin
							count <= count - 1'b1; 
					end
                    else 
                        count <= 3'd5;	
			end
	end

endmodule
