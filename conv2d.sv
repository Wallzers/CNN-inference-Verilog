`timescale 1ns / 1ps

module model #(
    parameter IMG_SIZE = 28,
    parameter KERNEL_SIZE = 3,
    parameter IN_CHANNELS = 1,
    parameter OUT_CHANNELS = 1,  // Single output channel for simplicity
    parameter DATA_WIDTH = 8,
    parameter WEIGHT_FILE = "weights_0.mem",
    parameter BIAS_FILE = "bias_0.mem"
)(
    input clk,
    input rst,
    input valid_in,
    input [DATA_WIDTH-1:0] image[0:IMG_SIZE*IMG_SIZE-1],
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] result[0:(IMG_SIZE-KERNEL_SIZE+1)*(IMG_SIZE-KERNEL_SIZE+1)-1]
);

    // Memory for weights and bias (1 output channel, 1 input channel)
    reg signed [DATA_WIDTH-1:0] weights[0:KERNEL_SIZE*KERNEL_SIZE-1];
    reg signed [DATA_WIDTH-1:0] biases[0:0];
    reg signed [DATA_WIDTH-1:0] bias;

    // Internal counters for FSM
    reg [5:0] row, col, ki, kj;
    reg signed [15:0] sum;
    reg [3:0] state;

    localparam IDLE = 0, LOAD = 1, CALC = 2, STORE = 3, DONE = 4;

    // Load weights and bias
    initial begin
        $readmemh(WEIGHT_FILE, weights);
        $readmemh(BIAS_FILE, biases);
        bias = biases[0];
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 0;
            col <= 0;
            ki <= 0;
            kj <= 0;
            sum <= 0;
            valid_out <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        sum <= 0;
                        ki <= 0;
                        kj <= 0;
                        state <= CALC;
                    end
                end
                CALC: begin
                    if (ki < KERNEL_SIZE && kj < KERNEL_SIZE) begin
                        integer img_idx, weight_idx;
                        img_idx = (row + ki) * IMG_SIZE + (col + kj);
                        weight_idx = ki * KERNEL_SIZE + kj;
                        sum <= sum + $signed(image[img_idx]) * $signed(weights[weight_idx]);
                        if (kj == KERNEL_SIZE - 1) begin
                            kj <= 0;
                            ki <= ki + 1;
                        end else begin
                            kj <= kj + 1;
                        end
                    end else begin
                        state <= STORE;
                    end
                end
                STORE: begin
                    integer result_idx;
                    sum <= sum + bias;
                    if (sum > 127) sum <= 127;
                    if (sum < -128) sum <= -128;
                    result_idx = row * (IMG_SIZE - KERNEL_SIZE + 1) + col;
                    result[result_idx] <= sum[7:0];
                    state <= LOAD;
                end
                LOAD: begin
                    if (col < IMG_SIZE - KERNEL_SIZE) begin
                        col <= col + 1;
                    end else begin
                        col <= 0;
                        if (row < IMG_SIZE - KERNEL_SIZE) begin
                            row <= row + 1;
                        end else begin
                            valid_out <= 1;
                            state <= DONE;
                        end
                    end
                    ki <= 0;
                    kj <= 0;
                    sum <= 0;
                    state <= CALC;
                end
                DONE: begin
                    valid_out <= 1;
                end
            endcase
        end
    end

endmodule
