all: com sim fsdb

com:
	vcs -full64 -sverilog -timescale=1ns/1ps -debug_access+all +vpi              \
        -f ../rtl/rtl_list.f -f ../bench_sv/bench_list.f +lint=all -l compile.log

sim:
	./simv -l sim.log

fsdb:
	vcd2fsdb dump_sha256

verdi:
	cat ../rtl/rtl_list.f         > debug_list.f
	cat ./bench_list.f >> debug_list.f
	verdi -sverilog -f debug_list.f -nologo -ssf dump_sha256.fsdb &

clean:
	@rm -rf *.log simv* csrc *.fsdb *.vpd ucli.key vcd2fsdbLog verdiLog *.rc novas.*
