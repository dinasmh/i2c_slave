module acH_TSB(
    input IN,
    input EN,
    output OUT
    );
assign OUT = EN? IN: 1'bz;
endmodule
