
include "sys.m";
sys: Sys;
print, sprint: import sys;

include "draw.m";
include "tk.m";
	tk: Tk;


include "math.m";
math: Math;
ceil, fabs, floor, Infinity, log10, pow10, pow, sqrt: import math;
dot, gemm, iamax: import math;

include "linalg.m";
linalg: LinAlg;
printmat, dgefa, dgesl: import linalg;

include "string.m";
str: String;
tobig, toint, toreal, tolower, toupper: import str;

include "bufio.m";
bufio: Bufio;
Iobuf: import bufio;

include "csv.m";
csv: CSV;

include "rand.m";
randmod: Rand;
rand: import randmod;

include "gr.m";
	gr: GR;
	Plot: import gr;

include "ndarray.m";
np: Ndarray;
ndarray: import np;

false, true: con iota;
bool: type int;


Command:module
{ 
	init:fn(ctxt: ref Draw->Context, argv: list of string); 
};

ctxt: ref Draw->Context;

init(c: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	linalg = load LinAlg LinAlg->PATH;
	str = load String String->PATH;
	bufio = load Bufio Bufio->PATH;
	csv = load CSV CSV->PATH;
	randmod = load Rand Rand->PATH;
	np = load Ndarray Ndarray->PATH;
	tk = load Tk Tk->PATH;
	gr = load GR GR->PATH;

	ctxt = c;
	np->init();
	randmod->init(1337);
	csv->init(bufio);
	main(argv);
}

plotinit(title: string): ref Plot
{
	return gr->open(ctxt, title);
}