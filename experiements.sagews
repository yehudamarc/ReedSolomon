import math
import random

#create finite field
F = GF(53)

# Create polynomial ring
R.<x,y> = F[]
T.<x> = F[]


# Encoder

def encode(message, n):
    convertedMessage = stringToIntArray(message)
    poly = makePoly(convertedMessage)
    encoded = [poly(a) for a in range(n)]
    return encoded

def makePoly(convertedMessage):
    poly = T([i for i in convertedMessage])
    return poly

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
            ret = ret + chr(num + 96)
        else:
            print('numbersToChars: invalid number')
    return ret

def experiment(n, message, numOfErrors):
    # Check parameters
    if numOfErrors > len(message) :
        print ('number of errors cannot be greater that length of meesage')
        return
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
            l.remove(i)
            errorArr.append(i)
        for j in range(0, len(errorArr)):
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
    experiment(10 , 'test', 1)

main()
