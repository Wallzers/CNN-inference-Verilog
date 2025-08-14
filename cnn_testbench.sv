`timescale 1ns / 1ps

module cnn_testbench;
    reg clk;
    reg rst;
    reg valid_in;
    reg [7:0] image_in [0:783];  // 28x28 image
    wire valid_out;
    wire [7:0] class_out [0:1];

    // Instantiate top-level CNN
    top_cnn uut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .image_in(image_in),
        .valid_out(valid_out),
        .class_out(class_out)
    );

    // Load image from .mem
    initial begin
        $readmemh("image.mem", image_in); // You must provide image.mem with 784 pixels
    end

    // Clock generator
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $display("--- Starting CNN Inference Simulation ---");
        clk = 0;
        rst = 1;
        valid_in = 0;
        #20;

        rst = 0;
        valid_in = 1;
        #10;
        valid_in = 0;

        wait (valid_out);

        $display("Prediction Output:");
        $display("Logit 0 (Class 0): %d", class_out[0]);
        $display("Logit 1 (Class 1): %d", class_out[1]);
        if (class_out[0] > class_out[1])
            $display("Predicted Class: 0(Normal)");
        else
            $display("Predicted Class: 1(u have PNEUMONIA die already)");

        $stop;
    end
endmodule
