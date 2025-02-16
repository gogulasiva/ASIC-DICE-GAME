module dice(
    input clock, rst, roll, 
    input [3:0] dice1, dice2,
    output reg win, lose,
    output reg [3:0] point
);

parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;

reg [3:0] sum;
reg [1:0] ps, ns;

// *Sequential Block for State Transition & Output Storage*
always @(posedge clock or posedge rst) begin
    if (rst) begin
        ps <= s0;
        sum <= 0;
        point <= 0;
        win <= 0;
        lose <= 0;
    end else begin
        ps <= ns;

        if (ps == s0 && roll) 
            sum <= dice1 + dice2;
        else if (ps == s2 && roll) 
            sum <= dice1 + dice2;

        if (ps == s1) begin
            if (sum == 4'b0111 || sum == 4'b1011) begin
                win <= 1;
                lose <= 0;
                point <= 0;
            end else if (sum == 4'b0010 || sum == 4'b0011 || sum == 4'b1100) begin
                win <= 0;
                lose <= 1;
                point <= 0;
            end else begin
                win <= 0;
                lose <= 0;
                point <= sum;
            end
        end

        if (ps == s2 && roll) begin
            if (sum == point) begin
                win <= 1;
                lose <= 0;
                point <= 0;
            end else if (sum == 4'b0111) begin
                win <= 0;
                lose <= 1;
                point <= 0;
            end
        end
    end
end

// *Combinational Block for Next-State Logic Only*
always @(*) begin
    ns = ps; // Default next state

    case (ps)
        s0: begin
            if (roll) 
                ns = s1;
        end

        s1: begin
            if (sum == 4'b0111 || sum == 4'b1011 || sum == 4'b0010 || sum == 4'b0011 || sum == 4'b1100)
                ns = s0;
            else 
                ns = s2;
        end

        s2: begin
            if (roll) begin
                if (sum == point || sum == 4'b0111) 
                    ns = s0;
            end
        end
    endcase
end

endmodule