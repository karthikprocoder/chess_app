import '../widgets/piece.dart';

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

// INITIALIZE THE BOARD (CALLED IN THE initstate OF THE game_board)
List<List<ChessPiece?>> initializeBoard() {
  List<List<ChessPiece?>> board =
      List.generate(8, (index) => List.generate(8, (index) => null));

  // pawns
  for (int i = 0; i < 8; i++) {
    board[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/images/black-pawn.png');
  }

  for (int i = 0; i < 8; i++) {
    board[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/images/white-pawn.png');
  }

  // rooks
  board[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/black-rook.png');
  board[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/images/black-rook.png');
  board[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/white-rook.png');
  board[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/images/white-rook.png');

  // knights
  board[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/black-knight.png');
  board[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/images/black-knight.png');
  board[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/white-knight.png');
  board[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/images/white-knight.png');

  // bishops
  board[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/black-bishop.png');
  board[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/images/black-bishop.png');
  board[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/white-bishop.png');
  board[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/images/white-bishop.png');

  // queens
  board[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/images/black-queen.png');
  board[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/images/white-queen.png');

  // kings
  board[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/images/black-king.png');
  board[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/images/white-king.png');

  return board;
}

// RETURNS A LIST OF CANDIDATE MOVES FOR ALL THE PIECES (USED TO CALCULATE REAL VALID MOVES)
List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece, List<List<ChessPiece?>> board) {
    List<List<int>> candidateMoves = [];
    if (piece == null) return [];
    // direction based on color
    int dir = (piece.isWhite) ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:

        // two steps ahead if it is its first move
        if ((piece.isWhite && row == 6 || !piece.isWhite && row == 1) &&
            board[row + 2 * dir][col] == null) {
          candidateMoves.add([row + 2 * dir, col]);
        }

        // pawns can move forward if the square is unoccupied
        if (isInBoard(row + dir, col) && board[row + dir][col] == null) {
          candidateMoves.add([row + dir, col]);
        }

        // capture opposite color piece diagnolly left or right
        if (isInBoard(row + dir, col - 1) &&
            board[row + dir][col - 1] != null &&
            board[row + dir][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + dir, col - 1]);
        }
        if (isInBoard(row + dir, col + 1) &&
            board[row + dir][col + 1] != null &&
            board[row + dir][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + dir, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        var dirs = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var dir in dirs) {
          int i = 1;
          while (true) {
            int newRow = row + dir[0] * i;
            int newCol = col + dir[1] * i;
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var dirs = [
          [-1, -2], // 1 up 2 left
          [-1, 2], // 1 up 2 right
          [-2, -1], // 2 up 1 left
          [-2, 1], // 2 up 1 right
          [1, -2], // 1 down 2 left
          [1, 2], // 1 down 2 right
          [2, -1], // 2 down 1 left
          [2, 1], // 2 down 1 right
        ];

        for (var dir in dirs) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];

          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        var dirs = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1] // down right
        ];

        for (var dir in dirs) {
          int i = 1;
          while (true) {
            int newRow = row + dir[0] * i;
            int newCol = col + dir[1] * i;
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        var dirs = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1] // down right
        ];

        for (var dir in dirs) {
          int i = 1;
          while (true) {
            int newRow = row + dir[0] * i;
            int newCol = col + dir[1] * i;
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
        var dirs = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1] // down right
        ];
        for (var dir in dirs) {
          int newRow = row + dir[0];
          int newCol = col + dir[1];

          if (!isInBoard(newRow, newCol)) continue;
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }

    return candidateMoves;
  }