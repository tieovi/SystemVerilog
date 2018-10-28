#all: com sim fsdb
all: com sim

com:
	vcs -full64 -sverilog -timescale=1ns/1ps -debug_access+all +vpi ../bench_dpi/sha256.c \
        -f ../rtl/rtl_list.f -f ../bench_dpi/bench_list.f +lint=all -l compile.log

sim:
	./simv -l sim.log | tee sim_dpi.log

fsdb:
	vcd2fsdb dump_sha256

verdi:
	cat ../rtl/rtl_list.f         > debug_list.f
	cat ./bench_list.f >> debug_list.f
	verdi -sverilog -f debug_list.f -nologo -ssf dump_sha256.fsdb &

clean:
	@rm -rf *.log simv* csrc *.fsdb *.vpd dump_sha256 novas.conf ucli.key vc_hdrs.h vcd2fsdbLog verdiLog
