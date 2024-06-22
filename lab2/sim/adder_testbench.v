// upgrade to 

`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000

module adder_testbench();
    reg [13:0] a;
    reg [13:0] b;
    wire [14:0] sum;

    reg [13:0] a_ba;
    reg [13:0] b_ba;
    wire [14:0] sum_ba;

    structural_adder sa (
        .a(a),
        .b(b),
        .sum(sum)
    );
    behavioral_adder ba (
        .a(a_ba),
        .b(b_ba),
        .sum(sum_ba)
    );

    integer ai, bi;
    initial begin
        `ifdef IVERILOG
            $dumpfile("adder_testbench.fst");
            $dumpvars(0, adder_testbench);
        `endif
        `ifndef IVERILOG
            $vcdpluson;
        `endif

        // my simulation
        for (ai = 0; ai < 1024; ai = ai + 1) begin
            for (bi = 0; bi < 1024; bi = bi + 1) begin
                a = ai;
                b = bi;
                a_ba = ai;
                b_ba = bi;
                #(2);
                assert(sum == sum_ba) else $error("Expected sum to be 20, a: %d, b: %d, actual value: %d", a, b, sum);
            end
        end 

        // my sim - random
        // for (ai = 0; ai < 1024; ai = ai + 1) begin
        //     a = $urandom();
        //     b = $urandom();
        //     a_ba = a;
        //     b_ba = b;
        //     #(2);
        //         assert(sum == sum_ba) else $error("Expected sum to be 20, a: %d, b: %d, actual value: %d", a, b, sum);
        // end


        `ifndef IVERILOG
            $vcdplusoff;
        `endif
        $finish();
    end
endmodule
