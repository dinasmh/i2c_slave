module fsm_tb;
reg sda_i,
    clk_t,
    clk_s,
    SCL_i,
    FIFO_FULL,
    FIFO_EMPTY;
wire start_det,
     stop_det;
reg rstn;
reg [7:0] rd_data;
reg [6:0] slave_addr_reg;
wire sda_o,
     sda_in_en,
     wr_en_fifo,
     rd_en_fifo;
wire [7:0] wr_data;

initial begin
    slave_addr_reg = 7'b1010101;
    clk_t = 1'b0;
    clk_s =1'b0;
    sda_i = 1'b1;
    SCL_i = 1'b1;
    rstn = 1'b1;
    #10
    rstn = 1'b0;
    #10
    rstn = 1'b1;
    #204
    sda_i = 1'b0; //start condition
    #10
    sda_i = 1'b1;
    #20
    sda_i = 1'b0;
    
    #20 
    sda_i = 1'b1;
    #20
    sda_i = 1'b0;
    #20
    sda_i = 1'b1;
    #20
    sda_i = 1'b0;
    #20
    sda_i = 1'b1;
    #20
    sda_i = 1'b1;
    //#46
    //sda_i = 1'b1;
    //force start_det = 1'b0;
    force stop_det = 1'b0;
    #46
    sda_i = 1'b1;
    #20 
    sda_i = 1'b0;
    #23
    sda_i = 1'b1;
    #500
    $stop;
end

slave_fsm slv(sda_i,
          clk_t,
          SCL_i,
          FIFO_FULL,
          FIFO_EMPTY,
          start_det,
          stop_det,
          rstn,
          rd_data,
          slave_addr_reg,
          sda_o,
          sda_in_en,
          wr_en_fifo,
          rd_en_fifo,
          wr_data
);

start_stop_det det0(clk_s,
                    sda_i,
                    SCL_i,
                    rstn,
                    start_det,
                    stop_det
);

always #1 clk_s = ~clk_s;
always #5 clk_t = ~clk_t;
always #10 SCL_i = ~SCL_i;

endmodule