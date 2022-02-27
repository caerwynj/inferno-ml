implement Command;
include "cmd.m";


# Bug in exp() on Inferno running on Plan9 - Raspberry Pi Model 4B.
main(nil: list of string)
{
	print("%f  expecting 4.349\n", exp(1.47));
	print("%f\n", np->sigmoid(-1.47));
}

