#create finite field
F = GF(53)

#define a1,...,an
eval_points = [F(x) for x in 1, 2, 3, 4]

def p(message,x):
    ret = 0;
    i = 0;
    for m in message:
        num = F(ord(m))
        ret += (num*(x**i))
        i += 1
    return ret

def encode(message):
    ret = []
    for a in eval_points:
        ret.append(p(message, a))
    return ret

#encode message
res = encode('test')
print(res)
