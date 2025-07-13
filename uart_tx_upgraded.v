module uart_tx_upgraded (
    input wire clk,
    input wire reset,
    input wire start_tx,
    input wire [7:0] data_in,
    output reg tx,
    output reg busy,
    output reg tx_done
);

    // === Parameters ===
    parameter BAUD_DIV = 4;

    // FSM States
    parameter IDLE  = 2'b00,
              LOAD  = 2'b01,
              SHIFT = 2'b10,
              DONE  = 2'b11;

    // === Registers ===
    reg [1:0] state, next_state;
    reg [3:0] bit_index;
    reg [9:0] shift_reg;
    reg [3:0] baud_count;

    // === FSM Sequential ===
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx <= 1'b1;
            busy <= 0;
            tx_done <= 0;
            baud_count <= 0;
            bit_index <= 0;
            shift_reg <= 10'b1111111111;
        end else begin
            state <= next_state;
            tx_done <= 0;

            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 0;
                end

                LOAD: begin
                    shift_reg <= {1'b1, data_in, 1'b0}; // stop + data + start
                    bit_index <= 0;
                    baud_count <= 0;
                    busy <= 1;
                end

                SHIFT: begin
                    if (baud_count == BAUD_DIV - 1) begin
                        tx <= shift_reg[bit_index];
                        bit_index <= bit_index + 1;
                        baud_count <= 0;
                    end else begin
                        baud_count <= baud_count + 1;
                    end
                end

                DONE: begin
                    tx <= 1'b1;
                    busy <= 0;
                    tx_done <= 1;
                end
            endcase
        end
    end

    // === FSM Combinational ===
    always @(*) begin
        case (state)
            IDLE:  next_state = (start_tx) ? LOAD : IDLE;
            LOAD:  next_state = SHIFT;
            SHIFT: next_state = (bit_index == 10 && baud_count == BAUD_DIV - 1) ? DONE : SHIFT;
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

endmodule
