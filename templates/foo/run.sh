#!/bin/bash
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p XS:D0D5D1D6A7:[D3/,B1+,B5+,B3+]:working.bin
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080800000;w0 "cafe.dat"'
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040800000;r0 1000000 "foo.dat"'
cmp cafe.dat foo.dat
dd if=/dev/urandom of=random.dat bs=1024 count=16384
#cat aes220.ucf | sed 's/SETUP_TIME/10/g;s/VALID_TIME/19/g' > ../templates/fx2all-ex/boards/aes220/board.ucf
../../../../bin/hdlmake.py -t ../templates/fx2all-ex/vhdl -b aes220
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -i 04b4:8613 -v 1d50:602b -p XS:D0D5D1D6A7:[D3/,B1+,B5+,B3+]:top_level.bin
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040800000;r0 1000000 "bar.dat"'
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000080800000;w0 "random.dat"'
/home/chris/build/makestuff/apps/flcli/lin.x64/rel/flcli -v 1d50:602b -a 'w0 0000000040800000;r0 1000000 "out.dat"'
cmp random.dat out.dat
hxd random.dat | head -1000 > random.txt; hxd out.dat | head -1000 > out.txt; diff random.txt out.txt | head -64
