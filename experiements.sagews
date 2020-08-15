#create finite field
F = GF(53)

# Create polynomial ring
R.<x,y> = F[]
T.<x> = F[]


# Encoder

def encode(message, n):
    poly = makePoly(message)
    encoded = [poly(a) for a in range(n)]
    return encoded

def makePoly(message):
    poly = T([char_to_int(i) for i in list(message)])
    return poly

def char_to_int(c):
    if(ord('a') <= ord(c) & ord(c) <= ord('z')):
        return ord(c) - ord('a') + 1                # a = 1, z = 26
    if(ord('A') <= ord(c) & ord(c) <= ord('Z')):
        return ord(c) - ord('A') + 27               # A = 27, Z = 52

# Decoder

def decode(encoded_message, k, n):
    eval_points = [i for i in range(0,n)]
    Interpolation_polynomails = interpolate(n, k, eval_points, encoded_message)
    message_polynoms = selectiveFactoring(Interpolation_polynomails)
    decoded_message = wordsFromPolynoms(message_polynoms)
    return decoded_message

def interpolate(n , k, eval_points, y_array):
    # Define the matrix representing the linear progeam
    deg_a = int(math.ceil(sqrt(k*n)))
    deg_y = int(math.ceil(sqrt(n/k)))
    matrix_size = (deg_y+1)*(deg_a+1)
    m = matrix(F, n, matrix_size)
    for row in range(n):
        m[row] = [(eval_points[row]^i)*(y_array[row]^j) for i in range(deg_a +1) for j in range(deg_y+1)]

    # get kernel vectors - solutions for the linear program
    #kernel_vectors = m.right_kernel_matrix()
    kernel_vectors = m.right_kernel_matrix(basis='computed')

    number_of_rows = len(kernel_vectors.rows())
    bivariant_polinomyals_array = [x+y for i in range(number_of_rows + 1)]

    # Create the corresponding bivariant polynomials
    for num in range(number_of_rows):
        vector = kernel_vectors[num]
        f = R(0)
        min_pol = R(0)
        index_counter = 0
        for i in range(deg_a+1):
            for j in range(deg_y+1):
                f += vector[index_counter]*(x^i)*(y^j)
                index_counter += 1
        bivariant_polinomyals_array[num] = f
        if (index_counter == 1):
            min_pol = f
        min_pol = f.gcd(min_pol)
    bivariant_polinomyals_array[number_of_rows] = min_pol
    return bivariant_polinomyals_array


def selectiveFactoring(Interpolation_polynomails):
    filtered_pols = []
    pols_number = len(Interpolation_polynomails)
    for i in range(pols_number):
        g = factor(Interpolation_polynomails[i])
        roots = [pol[0] for pol in list(g)]
        for pol in roots:
            if (y-pol in T):
                filtered_pols.append([y-pol])
    return filtered_pols

def wordsFromPolynoms(pols):
    words_list = []
    for pol in pols:
        coef = list(pol)[0].coefficients()
        # keep the original order of coefficients
        coef.reverse()
        word = numbersToChars(coef)
        words_list.append([word])
    return words_list

def numbersToChars(word):
    ret = ""
    for num in word:
        ret = ret + intToChar(num)
    return ret

def intToChar(num):
    num = int(num)
    return chr(num + 96)

def experiment(n, message, numOfErrors):
    # call the encoder
    print "Encoder is called with n=",n, ", message=",message
    resultEncoder = encode(message, n)
    print "Num of errors=",numOfErrors
    resultWithErrors = resultEncoder
    print (resultWithErrors)
    # insert numOfErrors errors (only if numOfErrors > 0)
    if numOfErrors > 0 :
        errorArr = []
        while len(errorArr) < numOfErrors :
            l = range(0,len(message))
            i = random.choice(l)
            if i not in errorArr:
                errorArr.append(i)
                print (errorArr)
        for j in range(0, numOfErrors):
            curr = errorArr[j]
            resultWithErrors[curr] = random.choice(range(0,52))
    print(resultWithErrors)
    # call the decoder
    resultDecoder = decode(resultWithErrors, len(message), n)
    print ("Results of Decoder = ",resultDecoder)
    # check if the original message is inside the list that was returned by the decoder
    resultDecoder = flatten(resultDecoder)
    if message in resultDecoder :
        print "The message is found in the output of the decoder"
    else:
        print "The message is not found in the output of the decoder"

# Experiements
def main():
    experiment(10 , 'test', 0)

main()
