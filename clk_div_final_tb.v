module clk_div_final_tb;
reg clk_i,rstn,clk_en;
wire clk_o_div;

reg clk_temp;
initial begin
    clk_i = 1'b0;
    clk_en = 1'b0;
    //mode = 1'b0;
    rstn = 1'b1;
    #2
    rstn = 1'b0;
    #4
    rstn = 1'b1;
    clk_en = 1'b1;
    #20000
    $stop;
end
always #1 clk_i <= ~clk_i;

clk_div_final c0 (clk_i,rstn,clk_en,clk_o_div);

endmodule