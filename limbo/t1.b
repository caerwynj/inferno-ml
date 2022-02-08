implement t1;
include "sys.m";
include "draw.m";
sys: Sys;

t1:module
{ 
	init:fn(nil: ref Draw->Context, nil: list of string); 
};

init(nil: ref Draw->Context , nil: list of string)
{
	sys = load Sys Sys->PATH;
	sys->print("hello, world!\n");
}
