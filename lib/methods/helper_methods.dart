bool isWhite(int index) {
  int rowNo = index ~/ 8;
  int colNo = index % 8;
  return (rowNo + colNo) % 2 == 0;
}

bool isInBoard(int row, int col) {
  return row < 8 && col < 8 && row >= 0 && col >= 0;
}

bool isValidMove(int row, int col, List<List<int>> moves) {
  for (var pos in moves) {
    if (pos[0] == row && pos[1] == col) {
      return true;
    }
  }
  return false;
}
