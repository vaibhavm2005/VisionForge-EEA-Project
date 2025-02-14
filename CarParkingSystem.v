module CarParkingSystem(
    input clk,
    input reset,
    input entrance_sensor,
    input exit_sensor,
    input [3:0] password,
    input enter_pass,
    output reg gate_open,
    output reg [2:0] state
);

// Define states
parameter IDLE = 3'b000;
parameter PASSWORD_CHECK = 3'b001;
parameter GATE_OPEN = 3'b010;
parameter PARKING = 3'b011;
parameter GATE_CLOSE = 3'b100;
parameter WRONG_PASSWORD = 3'b101;

reg [3:0] correct_password = 4'b1010; // Predefined password
reg [1:0] attempt_counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        gate_open <= 0;
        attempt_counter <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (entrance_sensor) begin
                    state <= PASSWORD_CHECK;
                end
            end
            
            PASSWORD_CHECK: begin
                if (enter_pass) begin
                    if (password == correct_password) begin
                        state <= GATE_OPEN;
                        attempt_counter <= 0;
                    end else begin
                        attempt_counter <= attempt_counter + 1;
                        if (attempt_counter < 2) begin
                            state <= WRONG_PASSWORD;
                        end else begin
                            state <= IDLE;
                            attempt_counter <= 0;
                        end
                    end
                end
            end
            
            WRONG_PASSWORD: begin
                state <= PASSWORD_CHECK;
            end
            
            GATE_OPEN: begin
                gate_open <= 1;
                if (exit_sensor) begin
                    state <= PARKING;
                end
            end
            
            PARKING: begin
                state <= GATE_CLOSE;
            end
            
            GATE_CLOSE: begin
                gate_open <= 0;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

endmodule