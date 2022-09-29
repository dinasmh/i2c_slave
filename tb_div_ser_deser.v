module tb_div_ser_deser;

reg data_i;
wire [7:0] data_o_deser;
reg ser_en, deser_en, clk_i,rst_n, clk_en, mode;
wire data_o_ser,SCL;

serialiser#(.WIDTH(8))ser0(data_o_deser,ser_en,rst_n,SCL,data_o_ser);
deser#(.WIDTH(8)) deser0 (data_i,deser_en,rst_n,SCL,data_o_deser);


always @(negedge SCL) begin
    data_i <= ~data_i;
end
initial begin
    clk_i =1'b0;
    data_i = 1'b1;
    ser_en = 1'b0;
    clk_en = 1'b0;
    deser_en = 1'b0;
    mode = 1'b0;
    rst_n = 1'b1;
    #2 
    rst_n = 1'b0;
    #2
    rst_n = 1'b1;
    #2
    ser_en = 1'b1;
    deser_en = 1'b1;
    clk_en = 1'b1;
    #200000
    $stop;
end
always #2 clk_i = ~clk_i;

clk_div_final c0 (clk_i,rst_n,clk_en,mode,clk_o_div,SCL);

endmodule
