%.dis: %.b
	limbo -gw $stem.b


DIS=\
	ndarray.dis\
	linreg.dis\
	t1.dis\
	t2.dis\
	t3.dis\
	t4.dis\
	t5.dis\
	t6.dis\
	t7.dis\
	t8.dis\
	t9.dis\
	t10.dis\
	t11.dis\
#	t12.dis\
	t13.dis\
	t14.dis\
	t15.dis\
	t16.dis

all:V: $DIS

clean:
	rm -f *.sbl

nuke:
	rm -f *.sbl *.dis

test:
	mash run -x mashfile
