implement Command;
include "cmd.m";

main(nil: list of string)
{
	s := sprint("%f", 8311045120.000000);
	print("%s\n", s);
	(r, w) := toreal(s, 10);
	print("%f", r);

}
