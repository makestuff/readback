#!/bin/bash

/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p XS:D0D5D1D6A7:[D3/,B1+,B5+,B3+]:working.bin
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080800000;w0 "cafe.dat"'
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040800000;r0 1000000 "foo.dat"'
cmp cafe.dat foo.dat

x=5
y=19
while [ $x -le 18 ]; do
	echo "ATTEMPT($x)"
	#y=$(($x + 2))
	cat aes220.ucf | sed "s/SETUP_TIME/$x/g;s/VALID_TIME/$y/g" > ../templates/fx2all-ex/boards/aes220/board.ucf
	../../../../bin/hdlmake.py -t ../templates/fx2all-ex/vhdl -b aes220
	if [ "$?" == "0" ]; then
		trce -v 12 -fastpaths -o timing$x top_level.ncd top_level.pcf
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p XS:D0D5D1D6A7:[D3/,B1+,B5+,B3+]:working.bin
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080800000;w0 "cafe.dat"'
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p XS:D0D5D1D6A7:[D3/,B1+,B5+,B3+]:top_level.bin
		rm -f random.dat out.dat random.txt out.txt
		dd if=/dev/urandom of=random.dat bs=1024 count=16384
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080800000;w0 "random.dat"'
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040800000;r0 1000000 "out.dat"'
		grep -A2 "OFFSET = IN" top_level.par | perl -ane 'print "  $_";' > x
		grep -q '*' x
		notFail=$?
		grep -A1 "OFFSET = OUT" top_level.par | perl -ane 'print "  $_";' > y
		cmp random.dat out.dat
		if [ "$?" == "0" ]; then
			if [ "$notFail" == "1" ]; then
				echo "RESULT($x, $y): PASS_GOOD" >> run.log
			else
				echo "RESULT($x, $y): FAIL_GOOD" >> run.log
			fi
			cat x >> run.log
			cat y >> run.log
		else
			if [ "$notFail" == "1" ]; then
				echo "RESULT($x, $y): PASS_BAD" >> run.log
			else
				echo "RESULT($x, $y): FAIL_BAD" >> run.log
			fi
			cat x >> run.log
			cat y >> run.log
			hxd random.dat | head -1000 > random.txt
			hxd out.dat | head -1000 > out.txt
			diff random.txt out.txt | head -64 >> run.log
		fi
		echo >> run.log
	fi
	x=$(($x + 1))
done
