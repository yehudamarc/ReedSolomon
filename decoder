#create finite field
F = GF(53)

k = 4
n = 4

a_array = [0,1,2,3]
y_array = [24, 10, 28, 32]

deg_a = sqrt(k*n)
deg_y = sqrt(n/k)

matrix_size = (deg_y+1)*(deg_a+1)

m = matrix(F, n, matrix_size)

for row in range(n):
    m[row] = [(a_array[row]^i)*(y_array[row]^j) for i in range(deg_a +1) for j in range(deg_y+1)]

kernel_vectors = m.right_kernel_matrix()
