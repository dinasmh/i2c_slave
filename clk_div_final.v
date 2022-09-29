module clk_div_final(
    input clk_i,
          rstn,
          clk_en,
    output reg clk_s,
               clk_t,scl
    );
wire [31:0] div_ratio1,div_ratio2;
reg [31:0] i,j;

//input clock = 100MHz
//SCL frequency will be 100 KHz only
//I will sample the SDA 10 times each clock cycle of the SCL --> sampling frequency = 1MHz

assign div_ratio1 = 32'd100; //for sampling clock --> 10 times the SCL frequency -->outputs frequency of 1MHz (1000KHz)
assign div_ratio2 = 32'd500;   //for transition clock --> 2 times the SCL frequency --> outputs frequency of 200KHz (100000/200=500)

always @(posedge clk_i or negedge rstn) begin
    if(!rstn) begin
        clk_s <= 1'b1;
        clk_t <= 1'b1;
        i <= 32'd0;
        j<= 32'd0;
    end
    else if(clk_en) begin
        i <= i+ 1;
        j <= j+1;
        if(i == ((div_ratio1/2)-1))begin
            clk_s <= ~clk_s;
            i <= 32'd0;
        end
        if(j==((div_ratio2/2)-1))begin
            clk_t <= ~clk_t;
            j <= 32'd0;
        end
    end
end
always @(posedge clk_t or negedge rstn)begin
    if(!rstn)begin
        scl <= 1'b1;
    end
    else begin
        scl <= ~scl;
    end
end
endmodule