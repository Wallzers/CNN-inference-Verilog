`timescale 1ns / 1ps

module relu #(
    parameter DATA_WIDTH = 8,
    parameter LENGTH = 676  // e.g., 26x26 output from conv layer
)(
    input clk,
    input rst,
    input valid_in,
    input signed [DATA_WIDTH-1:0] data_in [0:LENGTH-1],
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] data_out [0:LENGTH-1]
);

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out <= 0;
        end else if (valid_in) begin
            for (i = 0; i < LENGTH; i = i + 1) begin
                data_out[i] <= (data_in[i][DATA_WIDTH-1] == 1'b1) ? 0 : data_in[i];
            end
            valid_out <= 1;
        end
    end

endmodule
