
int main() {
  // new/delete not defined for built-in types
  int a = new int(1, 2, 3);
  delete a;
}
