implement Command;
include "cmd.m";

main(nil: list of string)
{
	print("hello, world!\n");
	t1();
}

t1() 
{
	print("t1\n");
	a := array[3] of {1.0, 2.0, 3.0};
	printvec(a);

	a1 := array[3] of { * => 1.0};
	printvec(a1);

	a2 := array[3] of {* => 0.0};
	printvec(a2);

}

printvec(a: array of real)
{
	print("%d\n [", len a);
	for (i :=0; i < len a; i++) {
		print("%f, ", a[i]);
	}
	print("]\n");

}
