`define PROGRAM_MEMORY CPU.IMEM.IMEM
`define DATA_MEMORY CPU.dmem.MEMO
`define REGISTER_FILE CPU.Register.Register
`define CURRENT_PC CPU.PC.pc
`define TEST_LENGTH 140000
`define ANALYSIS_FILE "ana_file.txt"
`ifndef TEST_LENGTH1
	`define TEST_LENGTH1 1000
`endif
`ifndef TEST_LENGTH2
	`define TEST_LENGTH2 10001
`endif
`ifndef PROGRAM
    `define PROGRAM "test/test.mem"
`endif
`ifndef TEST_NAME
    `define TEST_NAME "TEST"
`endif
`ifndef LOG_FILE
    `define LOG_FILE "test/test.mem"
`endif
`ifndef VERIFY_FILE
    `define VERIFY_FILE "test/test.mem"
`endif
`define L1 3
`define L2 255
`define TB 0
