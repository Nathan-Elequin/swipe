import sys, numpy as np
from hifi import *
def dump(a):
    cols = {}; keys = 'kabcdefghijlmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@$%&*+=?'
    cols[(16, 14, 12)] = 'k'
    rows = []
    for y in range(a.shape[0]):
        r = ''
        for x in range(a.shape[1]):
            p = a[y, x]
            if p[3] == 0: r += '.'; continue
            t = tuple(int(v) for v in p[:3])
            if t not in cols: cols[t] = keys[len(cols)]
            r += cols[t]
        rows.append(r)
    return rows, {v: '#%02x%02x%02x' % k for k, v in cols.items()}
if __name__ == '__main__':
    a = eval(sys.argv[1])
    rows, pal = dump(a)
    for i, r in enumerate(rows): print('%2d %s' % (i, r))
    print(pal)
