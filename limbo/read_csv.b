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
