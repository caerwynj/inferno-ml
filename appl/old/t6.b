implement Command;
include "cmd.m";

main(nil: list of string)
{
	for(i := 0; i < 10; i++) 
		print("%d\n", rand(10));

	for( i = 0; i < 10; i++)
		print("%f\n", real rand(1<<30) / real (1<<30));
}