#create finite field
F = GF(53)

k = 4
n = 4

a_array = [0,1,2,3]
y_array = [10, 24, 10, 28]

deg_a = sqrt(k*n)
deg_y = sqrt(n/k)

matrix_size = (deg_y+1)*(deg_a+1)

m = matrix(F, n, matrix_size)

for row in range(n):
    m[row] = [(a_array[row]^i)*(y_array[row]^j) for i in range(deg_a +1) for j in range(deg_y+1)]

kernel_vectors = m.right_kernel_matrix()

number_of_rows = len(kernel_vectors.rows())

R.<x,y> = F[]
T.<x> = F[]

bivariant_polinomyals_array = [x+y for i in range(number_of_rows)]

for num in range(number_of_rows):
    vector = kernel_vectors[num]
    f = 0
    index_counter = 0
    for i in range(deg_a+1):
        for j in range(deg_y+1):
            f += vector[index_counter]*(x^i)*(y^j)
            index_counter += 1
    bivariant_polinomyals_array[num] = f

filtered_pols = []

for i in range(number_of_rows):
    g = factor(bivariant_polinomyals_array[i])
    roots = [pol[0] for pol in list(g)]
    for pol in roots:
        if (y-pol in T):
            filtered_pols.append([y-pol])

filtered_pols
