`timescale 1ns / 1ps

module maxpool #(
    parameter IMG_SIZE = 26, // width/height of input feature map
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input valid_in,
    input [DATA_WIDTH-1:0] data_in [0:IMG_SIZE*IMG_SIZE-1],
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] data_out [0:(IMG_SIZE/2)*(IMG_SIZE/2)-1]
);

    integer row, col, idx_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out <= 0;
        end else if (valid_in) begin
            idx_out = 0;
            for (row = 0; row < IMG_SIZE; row = row + 2) begin
                for (col = 0; col < IMG_SIZE; col = col + 2) begin
                    integer i0, i1, i2, i3;
                    reg [DATA_WIDTH-1:0] max_val;

                    i0 = row * IMG_SIZE + col;
                    i1 = i0 + 1;
                    i2 = (row + 1) * IMG_SIZE + col;
                    i3 = i2 + 1;

                    max_val = data_in[i0];
                    if (data_in[i1] > max_val) max_val = data_in[i1];
                    if (data_in[i2] > max_val) max_val = data_in[i2];
                    if (data_in[i3] > max_val) max_val = data_in[i3];

                    data_out[idx_out] <= max_val;
                    idx_out = idx_out + 1;
                end
            end
            valid_out <= 1;
        end
    end

endmodule
