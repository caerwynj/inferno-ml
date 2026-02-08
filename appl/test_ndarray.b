implement TestNdarray;

include "sys.m";
sys: Sys;
print: import sys;

include "draw.m";

include "ndarray.m";
np: Ndarray;
ndarray: import np;

TestNdarray: module {
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

init(ctxt: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	# Load from current directory for testing purposes
	np = load Ndarray "ndarray.dis"; 
	if(np == nil) {
		print("Failed to load ndarray.dis from current path\n");
		# Fallback or strict fail
		exit;
	}
	np->init();

	print("Running ndarray tests...\n");
	test_broadcast_fix();
	test_arithmetic();
	test_comparison();
	test_reductions();
	test_shape();
	print("All tests passed (if no errors reported above).\n");
}

assert_eq_real(name: string, act, exp: real)
{
	if(act != exp)
		print("FAIL %s: expected %g, got %g\n", name, exp, act);
	else
		print("PASS %s\n", name);
}

assert_eq_int(name: string, act, exp: int)
{
	if(act != exp)
		print("FAIL %s: expected %d, got %d\n", name, exp, act);
	else
		print("PASS %s\n", name);
}

test_broadcast_fix()
{
	print("\n--- Test Broadcast Fix ---\n");
	# Create a 2x2 matrix
	# 1.0 2.0
	# 3.0 4.0
	m := np->from_list(1.0::2.0::3.0::4.0::nil).reshape(2, 2);
	
	# Extract a row: [1.0, 2.0]
	r := m.row(0, 1);
	
	# Broadcast row to 2x2
	b := np->zeros(2, 2).broadcast(r, np->add);
	
	assert_eq_real("Broadcast Row[0,0]", b.a[0], 1.0);
	assert_eq_real("Broadcast Row[0,1]", b.a[2], 2.0); # Index 2 is (0,1) in col-major? Wait.
	# Let's check memory layout again.
	# (0,0) -> 0. (1,0) -> 1. (0,1) -> L. (1,1) -> L+1.
	# m=2, L=2.
	# a[0] = (0,0). a[1] = (1,0). a[2] = (0,1). a[3] = (1,1).
	
	assert_eq_real("Broadcast Row(0,0)", b.a[0], 1.0);
	assert_eq_real("Broadcast Row(1,0)", b.a[1], 1.0);
	assert_eq_real("Broadcast Row(0,1)", b.a[2], 2.0);
	assert_eq_real("Broadcast Row(1,1)", b.a[3], 2.0);
}

test_arithmetic()
{
	print("\n--- Test Arithmetic ---\n");
	a := np->ones(2, 2);
	b := np->const(2.0);
	
	c := a.add(b); # Should be all 3.0
	assert_eq_real("Add Scalar", c.a[0], 3.0);
	
	d := a.multiply(b); # Should be all 2.0
	assert_eq_real("Mul Scalar", d.a[0], 2.0);
}

test_comparison()
{
	print("\n--- Test Comparisons ---\n");
	# 1 2
	a := np->range(1, 3).reshape(1, 2);
	# gt 1.5 -> 0 1
	
	mask := a.gt(np->const(1.5));
	assert_eq_real("gt 1.5 [0]", mask.a[0], 0.0);
	assert_eq_real("gt 1.5 [1]", mask.a[1], 1.0);
}

test_reductions()
{
	print("\n--- Test Reductions ---\n");
	a := np->from_list(1.0 :: 5.0 :: 2.0 :: nil);
	v_max := a.max();
	v_argmax := a.argmax();
	
	assert_eq_real("max", v_max, 5.0);
	assert_eq_int("argmax", v_argmax, 1);
}

test_shape()
{
	print("\n--- Test Shape ---\n");
	a := np->zeros(2, 3);
	b := a.reshape(3, 2);
	assert_eq_int("reshape m", b.m, 3);
	assert_eq_int("reshape n", b.n, 2);
	
	c := a.flatten();
	assert_eq_int("flatten m", c.m, 6);
	assert_eq_int("flatten n", c.n, 1);
}
