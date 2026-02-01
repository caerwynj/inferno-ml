implement Graph0;

include "sys.m";
	sys: Sys;
	print: import sys;

include "draw.m";
include "tk.m";
	tk: Tk;

include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;

include "gr.m";
	gr: GR;
	Plot: import gr;

Graph0: module{
	init:	fn(nil: ref Draw->Context, argv: list of string);
};


include "ndarray.m";
np: Ndarray;
ndarray: import np;


init(ctxt: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	tk = load Tk Tk->PATH;
	bufio = load Bufio Bufio->PATH;
	if((gr = load GR GR->PATH) == nil){
		sys->print("%s: Can't load gr\n",hd argv);
		exit;
	}

	np = load Ndarray Ndarray->PATH;
	np->init();

	argv = tl argv;
	if(argv == nil){
		print("no arg");
		exit;
	}

	(m, lda, n, a) := np->read_csv(hd argv);
	y := ndarray(m, lda, n, a);
	x := range(0, m);
	#y.print("y");
	#x.print("x");

	p := gr->open(ctxt,hd argv);
	p.graph(x.a,y.a);
	p.pen(GR->CIRCLE);
	p.graph(x.a,y.a);
	p.paint("iteration",nil,"cost",nil);
	p.bye();
}


range(start, end: int): ndarray
{
	a := array[end - start] of real;

	for(i:=0; i< len a; i++)
		a[i] = real (i+start);

	return ndarray(len a, len a, 1, a);
}

