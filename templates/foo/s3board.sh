#!/bin/bash

x=5
y=18
while [ $x -le 18 ]; do
	echo "ATTEMPT($x)"
	#y=$(($x + 2))
	cat s3board.ucf | sed "s/SETUP_TIME/$x/g;s/VALID_TIME/$y/g" > ../templates/fx2all/boards/s3board/board.ucf
	/home/chris/build/makestuff/libs/libfpgalink/hdl/bin/hdlmake.py -t ../templates/fx2all/vhdl -b s3board
	if [ "$?" == "0" ]; then
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p J:D0D2D3D4:top_level.xsvf
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080400000;w0 "random.dat"'
		/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040400000;r0 800000 "out.dat"'
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
		else
			if [ "$notFail" == "1" ]; then
				echo "RESULT($x, $y): PASS_BAD" >> run.log
			else
				echo "RESULT($x, $y): FAIL_BAD" >> run.log
			fi
		fi
		cat x >> run.log
		cat y >> run.log
		echo >> run.log
	fi
	x=$(($x + 1))
done
