
def fact(n):
	return fact_inter(n, 1)

def fact_inter(num, product):
	if num == 1:
		return product;
	return fact_inter(num - 1, num * product)

# print fact_inter(120, 1)


g = (x * x for x in range(10))

# for n in g: print(n)

############################
def  fib(max):
	n, a, b = 0, 0, 1
	while n < max:
		print(b)
		a, b = b, a + b
		n = n + 1 
	# return 'done'

# fib(6)

############################

def add(x, y , f):
	return f(x) + f(y)


# print add(5, 120, abs)

############################

def double(x):
	return x * x;

r = list( map(double, [1, 2, 3, 4, 5, 6]) )

# print r

############################

def lazy_sum(*args):
	def sum():
		ax = 0
		for n in args:
			ax = ax + n;
		return ax
	return sum

f = lazy_sum(1, 3, 4, 5, 6, 7)

# print f()

