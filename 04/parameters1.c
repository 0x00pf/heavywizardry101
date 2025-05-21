int func4 (int a, int b) {
  int sum;
  sum = a +b;
  a = a + 10;
  return sum;
}

int main () {
  int   x, y;
  int   sum;

  x = 11;
  y = 22;
  sum = func4 (x, y);
}
  
 
