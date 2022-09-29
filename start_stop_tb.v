module start_stop_tb;
reg clk,sda,clk_en,rstn;
wire start_det,stop_det,clk_s,clk_t,scl;

initial begin
    rstn = 1'b1;
    clk = 1'b1;
    sda = 1'b1;
    #1
    rstn = 1'b0;
    #1
    rstn = 1'b1;
    clk_en = 1'b1;
    #500
    sda = 1'b0;
    #1600
    sda = 1'b1;
    #12000
    $stop;
end

always #1 clk = ~clk;

clk_div_final div0(.clk_i(clk),
                   .rstn(rstn),
                   .clk_en(clk_en),
                   .clk_s(clk_s),
                   .clk_t(clk_t),
                   .scl(scl)
    );
start_stop_det f0 (clk_s,sda,scl,rstn,start_det,stop_det);

endmodule

