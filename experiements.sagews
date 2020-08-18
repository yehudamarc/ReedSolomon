import math
import random

# Create finite field
def createField(n):
    if (n < 53):
        return GF(53)
    P = Primes()
    next_prime = P.next(n)
    return GF(next_prime)

# Encoder

def encode(message, n):
    # Create finite field
    F = createField(n)
    T.<x> = F[]
    convertedMessage = stringToIntArray(message)
    poly = T([i for i in convertedMessage])
    encoded = [poly(a) for a in range(n)]
    return encoded

def stringToIntArray(word):
    convertedWord = []
    for c in list(word):
        if(ord('a') <= ord(c) & ord(c) <= ord('z')):
            convertedWord.append(ord(c) - ord('a') + 1)
        elif(ord('A') <= ord(c) & ord(c) <= ord('Z')):
            convertedWord.append(ord(c) - ord('A') + 27)
        else:
            print('Invalid char in message!')
            print('message can contain only letters')
            return []
    return convertedWord

# Decoder

def decode(encoded_message, k, n):
    # Create finite field
    F = createField(n)
    eval_points = [i for i in range(0,n)]
    Interpolation_polynomails = interpolate(n, k, eval_points, encoded_message, F)
    message_polynoms = selectiveFactoring(Interpolation_polynomails, F)
    decoded_message = wordsFromPolynoms(message_polynoms)
    return decoded_message

def interpolate(n , k, eval_points, y_array, F):
    # Create polynomial ring
    R.<x,y> = F[]
    T.<x> = F[]
    # Define the matrix representing the linear progeam
    deg_a = int(math.ceil(sqrt(n)))
    deg_y = int(math.ceil(sqrt(n)))
    matrix_size = (deg_y+1)*(deg_a+1)
    m = matrix(F, n, matrix_size)
    for row in range(n):
        m[row] = [(eval_points[row]^i)*(y_array[row]^j) for i in range(deg_a +1) for j in range(deg_y+1)]

    # get kernel vectors - solutions for the linear program
    kernel_vectors = m.right_kernel_matrix(basis='computed')

    number_of_rows = len(kernel_vectors.rows())
    bivariant_polinomyals_array = []

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
        bivariant_polinomyals_array.append(f)
    return bivariant_polinomyals_array


def selectiveFactoring(Interpolation_polynomails, F):
    # Create polynomial ring
    R.<x,y> = F[]
    T.<x> = F[]
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
        word = intArrayToString(coef)
        words_list.append([word])
    return words_list

def intArrayToString(word):
    ret = ""
    for num in word:
        num = int(num)
        if(1 <= num & num <= 26 ):
            ret = ret + chr(num + 96)
        elif(27 <= num & num <= 52 ):
            ret = ret + chr(num + 38)
    return ret

def runExperiment(n, message, numOfErrors):
    # call the encoder
    print "Encoder is called with n=",n, ", message=",message
    resultEncoder = encode(message, n)
    print "Num of errors=",numOfErrors
    resultWithErrors = resultEncoder
    #print (resultWithErrors)
    # insert numOfErrors errors (only if numOfErrors > 0)
    if numOfErrors > 0 :
        errorArr = []
        while len(errorArr) < numOfErrors :
            l = range(0,n)
            i = random.choice(l)
            l.remove(i)
            errorArr.append(i)
        for j in range(0, len(errorArr)):
            curr = errorArr[j]
            resultWithErrors[curr] = random.choice(range(0,52))
    #print(resultWithErrors)
    # call the decoder
    resultDecoder = decode(resultWithErrors, len(message), n)
    resultDecoder = flatten(resultDecoder)
    resultDecoder = set(resultDecoder)
    #to remove:
    resultDecoder
    print "Results of Decoder = ",resultDecoder
    # check if the original message is inside the list that was returned by the decoder
    if message in resultDecoder :
        print "Success: The message is found in the output of the decoder"
    else:
        print "Failure: The message is not found in the output of the decoder"
    R = sqrt((len(message)/n))
    print 'Error Correction Rate: ', round(float(1-R), 2)
    print 'errors/n rate: ', round(float(numOfErrors/n), 2)
    print 'k/n rate: ', round(float(len(message)/n), 2)
    print(' ')

# Experiements
def main():
    # Experiment 6:
    runExperiment(1 , 'g', 0)
    runExperiment(5 , 'g', 4)

    runExperiment(10 , 'test', 0)
    runExperiment(15 , 'test', 0)

    runExperiment(9 , 'guruswani', 0)
    runExperiment(20 , 'guruswani', 0)
    runExperiment(25 , 'guruswani', 0)
    runExperiment(25 , 'guruswani', 1)
    runExperiment(30 , 'guruswani', 5)
    runExperiment(30 , 'guruswani', 10)
    runExperiment(50 , 'guruswani', 15)

    runExperiment(1 , 't', 0)
    runExperiment(2 , 'te', 0)
    runExperiment(3 , 'tes', 0)
    runExperiment(6 , 'test', 0)
    runExperiment(7 , 'test', 0)
    runExperiment(20 , 'testing', 0)
    runExperiment(27 , 'testing', 0)
    runExperiment(60 , 'guruswaniSudanAlgorithm', 0)
    runExperiment(90 , 'guruswaniSudanAlgorithm', 0)

    runExperiment(10 , 'word', 1)
    runExperiment(25 , 'word', 14)
    runExperiment(50 , 'word', 40)
    runExperiment(100 , 'word', 95)
    runExperiment(100 , 'word', 99)

main()
