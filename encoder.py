#define a1,...,an
arr = [1, 2, 3, 4]

def p(message,x):
    ret = 0;
    i = 0;
    for m in message:
        ret += (int(m)*(x**i))
        i += 1
    return ret

def e(message):
    ret = []
    for a in arr:
        ret.append(p(message, a))
    return ret

#encode message
res = e('012')
print(res)
