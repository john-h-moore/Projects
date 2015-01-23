from math import sqrt, pow

def fib(n):
	phi = (1 + sqrt(5))/2
	fib = pow(phi, n) - pow(-phi, -n)
	return int(fib/sqrt(5))
