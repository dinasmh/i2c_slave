module serialiser#(
    parameter WIDTH = 8
)(
    input [WIDTH-1:0] data_i,
    input ser_en,
          rst_n,
          clk_i,
    output reg data_o
);
reg [2:0] i;
always @(posedge clk_i or negedge rst_n) begin
    if(!rst_n)begin
        data_o <= {WIDTH{1'b0}};
        i<=WIDTH-1;
    end
    else begin
        if(ser_en)begin
            data_o <= data_i[i];
            i <= i-1;
            if(i==3'd0)begin
                i <= WIDTH-1;
            end
        end
        else begin
            data_o <= {WIDTH{1'b0}};
        end
    end
end

endmodule
