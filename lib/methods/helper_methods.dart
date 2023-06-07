

bool isWhite(int index) {
  int rowNo = index ~/ 8;
  int colNo = index % 8;
  return (rowNo + colNo) % 2 == 0;
}