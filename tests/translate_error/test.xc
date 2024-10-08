#include <stdlib.h>

int main() {
  // new/delete not defined for built-in types
  size_t a = new size_t(1, 2, 3);
  delete a;
}
