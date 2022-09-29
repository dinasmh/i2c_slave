module slave_top_tb;

wire sda_w;
reg  sda,
     rstn,
     scl;
assign sda_w = sda;
slave_top slv(.SDA (sda_w),
              .rstn(rstn),
              .SCL (scl)
              );
always #2 scl = ~scl;
//test address checking + fill in slave fifo with one frame then send stop bit
//    _ _     _ _ 
//_ _/   \_ _/   \_ _ 
//addr = 1010101
initial begin
    rstn=1'b1;
    #1
    rstn=1'b0;
    #1
    rstn=1'b1;
    scl = 1'b0;
    sda = 1'b1;
    #7
    sda = 1'b0;
    #10
    sda = 1'b1;
    #4
    sda = 1'b0;
    #4
    sda = 1'b1;
    #4
    sda = 1'b0;
    #4
    sda = 1'b1;
    #4
    sda = 1'b0;
    #4
    sda = 1'b1;
    #4
    sda = 1'b0;
    #58
    sda = 1'b1;
    #20
    $stop;
end

endmodule