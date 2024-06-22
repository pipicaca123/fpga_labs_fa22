module structural_adder (
    input [13:0] a,
    input [13:0] b,
    output [14:0] sum
);
    parameter ADDER_BITWIDE = 14;
    // LINT Hint:make lint may give you a false warning about a combinational path (%Warning-UNOPTFLAT) and might fail
    wire [ADDER_BITWIDE:0] carrier;
    assign carrier[0] = 1'b0;
    genvar i;
    generate
        for(i=0;i<ADDER_BITWIDE;i=i+1)begin:adder_block
            full_adder adder(.a(a[i]),
                            .b(b[i]),
                            .carry_in(carrier[i]),
                            .sum(sum[i]),
                            .carry_out(carrier[i+1])
            );
        end
    endgenerate
    assign sum[ADDER_BITWIDE] = carrier[ADDER_BITWIDE];
endmodule
