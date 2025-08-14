`timescale 1ns / 1ps

module top_cnn(
    input clk,
    input rst,
    input valid_in,
    input [7:0] image_in [0:783], // 28x28 grayscale image
    output wire valid_out,
    output wire [7:0] class_out [0:1] // 2 output logits
);

    // Intermediate buffers
    wire [7:0] conv_out [0:675];     // 26x26
    wire [7:0] relu_out [0:675];
    wire [7:0] pool_out [0:168];     // 13x13
    wire [7:0] dense1_out [0:15];    // hidden layer
    wire [7:0] dense2_out [0:1];     // output logits

    wire valid_conv, valid_relu, valid_pool, valid_dense1, valid_dense2;

    // Convolution Layer
    model #(
        .IMG_SIZE(28),
        .KERNEL_SIZE(3),
        .IN_CHANNELS(1),
        .OUT_CHANNELS(1),
        .DATA_WIDTH(8),
        .WEIGHT_FILE("weights_0.mem"),
        .BIAS_FILE("bias_0.mem")
    ) conv_layer (
        .clk(clk), .rst(rst), .valid_in(valid_in),
        .image(image_in),
        .valid_out(valid_conv),
        .result(conv_out)
    );

    // ReLU Layer
    relu #(
        .DATA_WIDTH(8),
        .LENGTH(676)
    ) relu_layer (
        .clk(clk), .rst(rst), .valid_in(valid_conv),
        .data_in(conv_out),
        .valid_out(valid_relu),
        .data_out(relu_out)
    );

    // MaxPooling Layer
    maxpool #(
        .IMG_SIZE(26),
        .DATA_WIDTH(8)
    ) pool_layer (
        .clk(clk), .rst(rst), .valid_in(valid_relu),
        .data_in(relu_out),
        .valid_out(valid_pool),
        .data_out(pool_out)
    );

    // Dense Layer 1 (169 -> 16)
    dense #(
        .INPUT_LEN(169), .OUTPUT_LEN(16), .DATA_WIDTH(8),
        .WEIGHT_FILE("weights_2.mem"), .BIAS_FILE("bias_2.mem")
    ) dense1 (
        .clk(clk), .rst(rst), .valid_in(valid_pool),
        .data_in(pool_out),
        .valid_out(valid_dense1),
        .data_out(dense1_out)
    );

    // Dense Layer 2 (16 -> 2)
    dense #(
        .INPUT_LEN(16), .OUTPUT_LEN(2), .DATA_WIDTH(8),
        .WEIGHT_FILE("weights_3.mem"), .BIAS_FILE("bias_3.mem")
    ) dense2 (
        .clk(clk), .rst(rst), .valid_in(valid_dense1),
        .data_in(dense1_out),
        .valid_out(valid_out),
        .data_out(class_out)
    );

endmodule
