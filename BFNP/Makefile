SHELL := bash
TOPSOURCE = top.sv
FLAGS = -DPROGRAM=\"${BENCH}\" -DTEST_NAME=\"${NAME}\" -DLOG_FILE=\"${LOG}\" -DVERIFY_FILE=\"${VERIFY}\" -DTEST_LENGTH1=${TL1} -DTEST_LENGTH2=${TL2}
.PHONY: all clean
####################################################################
all : aha-mont64 crc32 cubic edn huffbench matmult-int minver nbody nettle-aes nettle-sha256 nsichneu picojpeg qrduino sglib-combined slre statemate st ud wikisort 
run :
	echo "### VERILATING ###"
	verilator -Wall --trace -cc top.sv --exe tb_top.cpp ${FLAGS}
	echo "### BUILDING SIM ###"
	make -C obj_dir -f Vtop.mk Vtop
	echo "### SIMULATING ###"
	./obj_dir/Vtop
###################################################################
aha-mont64:
	make run BENCH="../embench/aha-mont64.mem" NAME="aha-mont64" LOG="Test_result/aha-mont64.txt" VERIFY="Verify/aha-mont64.txt"
crc32:
	make run BENCH="../embench/crc32.mem" NAME="crc32" LOG="Test_result/crc32.txt" VERIFY="Verify/crc32.txt"
cubic: 
	make run BENCH="../embench/cubic.mem" NAME="cubic" LOG="Test_result/cubic.txt" VERIFY="Verify/cubic.txt"
edn: 
	make run BENCH="../embench/edn.mem" NAME="edn" LOG="Test_result/edn.txt" VERIFY="Verify/edn.txt"
huffbench:
	make run BENCH="../embench/huffbench.mem" NAME="huffbench" LOG="Test_result/huffbench.txt" VERIFY="Verify/huffbench.txt"
matmult-int: 
	make run BENCH="../embench/matmult-int.mem" NAME="matmult-int" LOG="Test_result/matmult-int.txt" VERIFY="Verify/matmult-int.txt"
minver: 
	make run BENCH="../embench/minver.mem" NAME="minver" LOG="Test_result/minver.txt" VERIFY="Verify/minver.txt"
nbody: 
	make run BENCH="../embench/nbody.mem" NAME="nbody" LOG="Test_result/nbody.txt" VERIFY="Verify/nbody.txt"
nettle-aes: 
	make run BENCH="../embench/nettle-aes.mem" NAME="nettle-aes" LOG="Test_result/nettle-aes.txt" VERIFY="Verify/nettle-aes.txt"
nettle-sha256: 
	make run BENCH="../embench/nettle-sha256.mem" NAME="nettle-sha256" LOG="Test_result/nettle-sha256.txt" VERIFY="Verify/nettle-sha256.txt"
nsichneu: 
	make run BENCH="../embench/nsichneu.mem" NAME="nsichneu" LOG="Test_result/nsichneu.txt" VERIFY="Verify/nsichneu.txt"
picojpeg: 
	make run BENCH="../embench/picojpeg.mem" NAME="picojpeg" LOG="Test_result/picojpeg.txt" VERIFY="Verify/picojpeg.txt"
qrduino: 
	make run BENCH="../embench/qrduino.mem" NAME="qrduino" LOG="Test_result/qrduino.txt" VERIFY="Verify/qrduino.txt"
sglib-combined: 
	make run BENCH="../embench/sglib-combined.mem" NAME="sglib-combined" LOG="Test_result/sglib-combined.txt" VERIFY="Verify/sglib-combined.txt"
slre: 
	make run BENCH="../embench/slre.mem" NAME="slre" LOG="Test_result/slre.txt" VERIFY="Verify/slre.txt"
statemate: 
	make run BENCH="../embench/statemate.mem" NAME="statemate" LOG="Test_result/statemate.txt" VERIFY="Verify/statemate.txt"
st: 
	make run BENCH="../embench/st.mem" NAME="st" LOG="Test_result/st.txt" VERIFY="Verify/st.txt"
ud: 
	make run BENCH="../embench/ud.mem" NAME="ud" LOG="Test_result/ud.txt" VERIFY="Verify/ud.txt"
wikisort: 
	make run BENCH="../embench/wikisort.mem" NAME="wikisort" LOG="Test_result/wikisort.txt" VERIFY="Verify/wikisort.txt"

###################################################################
benchmark = aha-mont64 crc32 cubic edn huffbench matmult-int minver nbody nettle-aes nettle-sha256 nsichneu picojpeg qrduino sglib-combined slre st statemate ud wikisort
vall:
	for bench in ${benchmark} ; do \
		if [ "${TL2}" == "10001" ] ; then \
	      		diff -ur Verify/$${bench}.txt ../../Code_verilator/embench_ver_10k/$${bench}.txt > diff.txt; \
		elif [ "${TL2}" == "100001" ] ;  then \
	      		diff -ur Verify/$${bench}.txt ../../Code_verilator/embench_ver_100k/$${bench}.txt > diff.txt; \
		elif [ "${TL2}" == "1000001" ] ; then \
	      		diff -ur Verify/$${bench}.txt ../../Code_verilator/embench_ver_1m/$${bench}.txt > diff.txt; \
		fi ; \
		if grep -q "+" diff.txt; then \
			echo "$${bench} : Test Failed"; \
		else \
			echo "$${bench} : Test Passed"; \
		fi ;  \
	done ;

.PHONY: clean
clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd
	rm -rf Verify/*.txt
	rm -rf Test_result/*.txt
	rm *.txt
cleanbench:
	rm -rf ../embench_ver_1m/*.txt
	rm -rf ../embench_ver_100k/*.txt
	rm -rf ../embench_ver_10k/*.txt
	rm -rf ../embench_ver_1k/*.txt
crbench:
	cd ~/Documents/Reference_core/rvcorep_ver053
	./run.sh 1000 1k
	./run.sh 10000 10k
	./run.sh 100000 100k
	./run.sh 1000000 1m
	cd -
	
