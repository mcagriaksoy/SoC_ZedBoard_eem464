#Mehmet Cagri Aksoy#

def xgcd(a,b):
  """Extended GCD:
  Returns (gcd, x, y) where gcd is the greatest common divisor of a and b
  with the sign of b if b is nonzero, and with the sign of a if b is 0.
  The numbers x,y are such that gcd = ax+by."""
  prevx, x = 1, 0; prevy, y = 0, 1
  while b:
    q, r = divmod(a,b)
    x, prevx = prevx - q*x, x
    y, prevy = prevy - q*y, y
    a, b = b, r
  return a, prevx, prevy

r=2**(16) # This is always fixed number for your code
n=121 # You can change this value, but when you changed it then you also need to use the n_prime in your vhdl code as a constant.

a=9
b=5

g,r_inv,n_prime=xgcd(r,n)



def ModMul(a,b,n):
  a_mon=(a*r) % n
  b_mon=(b*r) % n
  print ("a_mon:",a_mon)
  print ("b_mon:",b_mon)
  x_mon=MonPro(a_mon,b_mon)
  print ("x_mon:",x_mon)
  x=MonPro(x_mon,1)
  print(x)


def MonPro(a_mon,b_mon):
  t=(a_mon*b_mon) % r
  m=(t*n_prime) % r
  print ("t:",t)
  print ("m:",m)
  u=(a_mon*b_mon + m*n) // r
  print("u:",u)
  if (u >= n):
    return (u-n)
  else:
    return u

print(g,r_inv,n_prime)

ModMul(a,b,n) # This the algorithm you implemented
print("n_prime:", n_prime)

print(a*b % n) # This is given to compare the result
