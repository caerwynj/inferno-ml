implement Command;
include "cmd.m";

main(argv: list of string)
{
	print("%s\n", hd argv);
	argv = tl argv;
	if(argv != nil){
		print("%s\n", hd argv);
		(m, lda, n, a) := read_csv(hd argv);
	
		printmat("a", a, lda, 30, n);

		sums := sum(m, lda, n, a);
		means := mean(m, lda, n, a);
		stds := std(m, lda, n, a);
		for(i := 0; i < len sums; i++) 
			print("%f\n", sums[i] / real m);
		for(i = 0; i < len means; i++)
			print("%f\n", means[i]);
		for(i = 0; i < len stds; i++)
			print("%f\n", stds[i]);
	}
}

sum(m, lda, n: int, a: array of real): array of real
{
	sums := array[n] of { * => 0.0};

	for(i := 0; i < m; i++){
		for(j := 0; j < n; j++) {
			sums[j] += a[i+lda*j];
		}
	}
	return sums;
}

mean(m, lda, n: int, a: array of real): array of real
{
	means := sum(m, lda, n, a);
	for (i := 0; i < len means; i++)
		means[i] = means[i] / real m;
	return means;
}

std(m, lda, n: int, a: array of real): array of real
{
	means := mean(m, lda, n, a);
	stds := array[n] of {* => 0.0};

	for(i := 0; i < m; i++) {
		for(j := 0; j < n; j++) {
			stds[j] += (a[i+lda*j] - means[j]) ** 2;
		}
	}
	for(i = 0; i < n; i++) {
		stds[i] = sqrt(stds[i] / real m);
	}
	return stds;
}


read_csv(name: string): (int, int, int, array of real)
{
	fd := bufio->open(name, bufio->OREAD);
	header := csv->getline(fd);
	s : list of string = nil;
	lines : list of list of string;
	while((s = csv->getline(fd)) != nil){
		lines = s :: lines;
	}

	m, n : int = 0;
	m = len lines;
	n = len header;
	lda := m;
	v := array[m * n] of {* => 0.0};

	print("m %d n %d\n", m, n);
	for (i := 0; i < m; i++) {
		row := hd lines;
		for (j := 0; j < n; j++) {
			rr: real;
			w: string;
			(rr, w) = toreal(hd row, 10);
			v[i+lda*j] = rr;
			row = tl row;
		}
		lines = tl lines;
	}
	for (h := header; h != nil; h = tl h)
		print("%s ", hd h);
	print("\n");

	#printmat("a", v, lda, 30, n);

	return (m, lda, n, v);
}
