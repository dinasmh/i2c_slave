module deser#(
    parameter WIDTH = 8
)(
    input data_i,
    input deser_en,
          rst_n,
          clk_i,
    output reg [WIDTH-1:0] data_o,
    output reg rdy
);
reg [2:0] i;
always @(posedge clk_i or negedge rst_n) begin
    if(!rst_n)begin
        i <= WIDTH-1;
        data_o <= {WIDTH{1'b0}};
    end
    else begin
        if(deser_en)begin
            data_o [i] = data_i;
            i <= i-1;
            if(i == 3'd0)begin
                i<=WIDTH-1;
                rdy <= 1'b1;
            end
        end
        else begin
            data_o <= {WIDTH{1'b0}};
        end
    end
end
endmodule