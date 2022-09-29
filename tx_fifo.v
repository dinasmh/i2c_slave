module tx_fifo

(
 input          wire                     clk,rst,         
 input          wire                     wr_en_tx,rd_en_tx,
 input          wire   [7:0]             data_in,

 output         reg                     full,empty,
 output         reg    [7:0]            data_out
);


// internal Wires
reg           [1:0]          w_ptr,r_ptr;
integer i ;
reg  [7:0]  F_MEM  [3:0];   



always @(posedge clk or negedge rst)
begin
  if (!rst) 
    begin
       w_ptr <=  4'b0 ;
       r_ptr <=  4'b0 ;
       full  <=  1'b0 ;
       empty <=  1'b1 ;

         for (i =0 ; i<4'd4 ;i=i+1'b1 ) 
            begin
              F_MEM[i] <= 'b0 ;
            end
    end 

  else if (wr_en_tx && !rd_en_tx)   
    begin
       F_MEM[w_ptr] <= data_in ;
       w_ptr        <= w_ptr+1;
       empty        <= 1'b0 ;

           if (w_ptr+1'b1 == r_ptr)
               full  <= 1'b1 ;
    end


  else if (!wr_en_tx && rd_en_tx)
     begin
       data_out     <= F_MEM[r_ptr];
       r_ptr        <= r_ptr+1;
       full         <= 1'b0;

           if (w_ptr == r_ptr && !full)
               empty <= 1'b1 ;
     end
end


 endmodule