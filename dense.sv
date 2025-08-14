`timescale 1ns / 1ps

module dense #(
    parameter INPUT_LEN = 169,    // e.g., 13x13 maxpool output
    parameter OUTPUT_LEN = 16,    // number of neurons in dense layer
    parameter DATA_WIDTH = 8,
    parameter WEIGHT_FILE = "weights_2.mem",
    parameter BIAS_FILE = "bias_2.mem"
)(
    input clk,
    input rst,
    input valid_in,
    input signed [DATA_WIDTH-1:0] data_in [0:INPUT_LEN-1],
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] data_out [0:OUTPUT_LEN-1]
);

    reg signed [DATA_WIDTH-1:0] weights[0:INPUT_LEN*OUTPUT_LEN-1];
    reg signed [DATA_WIDTH-1:0] biases[0:OUTPUT_LEN-1];

    integer i, j;
    integer sum;

    // Load weights and biases
    initial begin
        $readmemh(WEIGHT_FILE, weights);
        $readmemh(BIAS_FILE, biases);
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_out <= 0;
        end else if (valid_in) begin
            for (i = 0; i < OUTPUT_LEN; i = i + 1) begin
                sum = 0;
                for (j = 0; j < INPUT_LEN; j = j + 1) begin
                    sum = sum + $signed(data_in[j]) * $signed(weights[i*INPUT_LEN + j]);
                end
                sum = sum + biases[i];
                // Clamp output to 8-bit signed range
                if (sum > 127) sum = 127;
                if (sum < -128) sum = -128;
                data_out[i] <= sum[7:0];
            end
            valid_out <= 1;
        end
    end

endmodule
