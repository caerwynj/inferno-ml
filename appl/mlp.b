implement MLP;

include "sys.m";
sys: Sys;
print: import sys;

include "draw.m";

include "math.m";
math: Math;
pow, exp, log: import math;

include "ndarray.m";
np: Ndarray;
ndarray: import np;

MLP: module {
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

# Hyperparameters
INPUT_SIZE: con 784;
HIDDEN1_SIZE: con 64;
HIDDEN2_SIZE: con 32;
OUTPUT_SIZE: con 10;
LEARNING_RATE: con 0.1;
EPOCHS: con 100;

init(ctxt: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	math = load Math Math->PATH;
	np = load Ndarray Ndarray->PATH;
	np->init();

	if(len argv < 2){
		print("usage: mlp mnist_train.csv\n");
		return;
	}
	train_file := hd tl argv;

	print("Loading data from %s...\n", train_file);
	(m, lda, n, data) := np->read_csv(train_file);
	raw_data := ndarray(m, lda, n, data);
	
	# Assuming CSV format: Label, Pixel1, Pixel2, ... Pixel784
	# Split into X and y
	# X: columns 1..785
	# y: column 0
	
	# Extract X and scale
	X := raw_data.col(1, n);
	X = X.scale(1.0/255.0);
	
	# Extract y
	y_raw := raw_data.col(0, 1);
	
	print("Data loaded. X: %dx%d, y: %dx%d\n", X.m, X.n, y_raw.m, y_raw.n);
	
	# Convert y to one-hot
	y := one_hot(y_raw, OUTPUT_SIZE);
	
	print("Training structure: %d -> %d -> %d -> %d\n", INPUT_SIZE, HIDDEN1_SIZE, HIDDEN2_SIZE, OUTPUT_SIZE);

	# Initialize weights
	W1 := np->randn(INPUT_SIZE, HIDDEN1_SIZE).scale(0.1);
	b1 := np->zeros(1, HIDDEN1_SIZE);
	
	W2 := np->randn(HIDDEN1_SIZE, HIDDEN2_SIZE).scale(0.1);
	b2 := np->zeros(1, HIDDEN2_SIZE);
	
	W3 := np->randn(HIDDEN2_SIZE, OUTPUT_SIZE).scale(0.1);
	b3 := np->zeros(1, OUTPUT_SIZE);
	
	# Training Loop
	for(epoch := 0; epoch < EPOCHS; epoch++){
		# Forward
		(z1, a1, z2, a2, z3, a3) := forward(X, W1, b1, W2, b2, W3, b3);
		
		# Loss (MSE)
		# Loss = mean((a3 - y)^2)
		diff := a3.subtract(y);
		sq_diff := diff.multiply(diff);
		loss := sq_diff.mean().a[0];
		
		# Accuracy
		acc := accuracy(a3, y_raw);
		
		print("Epoch %d: Loss = %.5f, Accuracy = %.2f%%\n", epoch, loss, acc * 100.0);
		
		# Backprop
		# dC/da3 = 2(a3 - y) / m
		# For Sigmoid + MSE: 
		# delta3 = (a3 - y) * sigma'(z3)
		# sigma'(z) = a * (1-a)
		
		m_samples := real X.m;
		
		# Output Layer Gradients
		# d_loss_a3 = 2 * (a3 - y) / m
		# da3_dz3 = a3 * (1 - a3)
		# delta3 = d_loss_a3 * da3_dz3 = 2/m * (a3 - y) * a3 * (1 - a3)
		
		d_a3 := diff.scale(2.0 / m_samples);
		sigma_prime_z3 := a3.multiply(np->ones(a3.m, a3.n).subtract(a3));
		delta3 := d_a3.multiply(sigma_prime_z3);
		
		dW3 := a2.transpose().dot(delta3);
		db3 := delta3.sum(); # Sum over batch
		
		# Hidden Layer 2 Gradients
		# delta2 = (delta3 . W3^T) * sigma'(z2)
		d_a2 := delta3.dot(W3.transpose());
		sigma_prime_z2 := a2.multiply(np->ones(a2.m, a2.n).subtract(a2));
		delta2 := d_a2.multiply(sigma_prime_z2);
		
		dW2 := a1.transpose().dot(delta2);
		db2 := delta2.sum();
		
		# Hidden Layer 1 Gradients
		d_a1 := delta2.dot(W2.transpose());
		sigma_prime_z1 := a1.multiply(np->ones(a1.m, a1.n).subtract(a1));
		delta1 := d_a1.multiply(sigma_prime_z1);
		
		dW1 := X.transpose().dot(delta1);
		db1 := delta1.sum();
		
		# Update Weights
		W1 = W1.subtract(dW1.scale(LEARNING_RATE));
		b1 = b1.subtract(db1.scale(LEARNING_RATE));
		
		W2 = W2.subtract(dW2.scale(LEARNING_RATE));
		b2 = b2.subtract(db2.scale(LEARNING_RATE));
		
		W3 = W3.subtract(dW3.scale(LEARNING_RATE));
		b3 = b3.subtract(db3.scale(LEARNING_RATE));
	}
	
	print("Training complete.\n");
}

forward(X, W1, b1, W2, b2, W3, b3: ndarray): (ndarray, ndarray, ndarray, ndarray, ndarray, ndarray)
{
	# Layer 1
	z1 := X.dot(W1).add(b1);
	a1 := z1.apply1(np->sigmoid);
	
	# Layer 2
	z2 := a1.dot(W2).add(b2);
	a2 := z2.apply1(np->sigmoid);
	
	# Output Layer
	z3 := a2.dot(W3).add(b3);
	a3 := z3.apply1(np->sigmoid);
	
	return (z1, a1, z2, a2, z3, a3);
}

one_hot(y: ndarray, num_classes: int): ndarray
{
	m := y.m;
	out := array[m * num_classes] of {* => 0.0};
	k := 0;
	for(i := 0; i < m; i++){
		label := int y.a[i]; # Stride L check? ndarray is likely contiguous logic unless strict L used.
							 # But to be safe: y.a[i*y.L] if col vector? 
							 # y is col(0,1) -> mx1. L=orig_LDA.
		label_idx := int y.a[i]; 
		if(label_idx >= 0 && label_idx < num_classes)
			out[i*num_classes + label_idx] = 1.0;
	}
	return ndarray(m, num_classes, num_classes, out);
}

accuracy(pred_probs, true_labels: ndarray): real
{
	correct := 0;
	m := pred_probs.m;
	for(i := 0; i < m; i++){
		# Find max in row i of pred_probs
		# Note: ndarray.argmax is global max. Need row-wise argmax?
		# Currently argmax is global. I implementation `argmax` as global.
		# I need to implement row-wise argmax logic here manually since API is global.
		
		best_class := -1;
		max_p := -1.0;
		for(j := 0; j < pred_probs.n; j++){
			# Access row i, col j
			val := pred_probs.a[i + pred_probs.L*j];
			if(val > max_p){
				max_p = val;
				best_class = j;
			}
		}
		
		actual_class := int true_labels.a[i]; 
		if(best_class == actual_class)
			correct++;
	}
	return real correct / real m;
}

