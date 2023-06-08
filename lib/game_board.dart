import 'package:chess_app/methods/helper_methods.dart';
import 'package:chess_app/widgets/dead_piece.dart';
import 'package:chess_app/widgets/piece.dart';
import 'package:chess_app/widgets/square_tile.dart';
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // 2d matrix representing a board
  late List<List<ChessPiece?>> board;

  // SELECTION OF A PIECE / SQUARE
  int selectedRow = -1;
  int selecetedCol = -1;
  ChessPiece? selectedPiece;

  // A LIST OF VALID MOVES FOR THE SELECTED PIECE
  List<List<int>> validMoves = [];

  // A LIST OF BLACK AND WHITE KILLED PIECES
  List<ChessPiece> whiteDeadPieces = [];
  List<ChessPiece> blackDeadPieces = [];

  // TURN
  bool isWhiteTurn = true;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  // INITALIZE THE BOARD
  void initializeBoard() {
    board = List.generate(8, (index) => List.generate(8, (index) => null));

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
  }

  void selectPiece(int rowNo, int colNo) {
    setState(() {
      // No piece has been selected, this is the first selection
      if (board[rowNo][colNo] != null && selectedPiece == null) {
        if (board[rowNo][colNo]!.isWhite == isWhiteTurn) {
          selectedRow = rowNo;
          selecetedCol = colNo;
          selectedPiece = board[rowNo][colNo];
          validMoves = calculateRawValidMoves(rowNo, colNo, selectedPiece);
        }
      }

      // this is the following selection
      else if (board[rowNo][colNo] != null &&
          board[rowNo][colNo]!.isWhite == selectedPiece!.isWhite) {
        selectedRow = rowNo;
        selecetedCol = colNo;
        selectedPiece = board[rowNo][colNo];
      } else if (selectedPiece != null &&
          isValidMove(rowNo, colNo, validMoves)) {
        movePiece(rowNo, colNo);
        validMoves = calculateRawValidMoves(rowNo, colNo, selectedPiece);
      } else {
        selectedPiece = null;
        selectedRow = -1;
        selecetedCol = -1;
        validMoves = [];
      }
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
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

  // MOVE THE PIECE
  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy
    if (board[newRow][newCol] != null) {
      // add the captured piece to the dead list
      if (board[newRow][newCol]!.isWhite) {
        whiteDeadPieces.add(board[newRow][newCol]!);
      } else {
        blackDeadPieces.add(board[newRow][newCol]!);
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selecetedCol] = null;

    // clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selecetedCol = -1;
      validMoves = [];
    });

    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Column(
        children: [
          // WHITE DEAD PIECES
          Expanded(
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemCount: whiteDeadPieces.length,
                itemBuilder: (context, index) {
                  return DeadPiece(
                      imagePath: whiteDeadPieces[index].imagePath,
                      isWhite: true);
                }),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 64,
                itemBuilder: (context, index) {
                  int rowNo = index ~/ 8;
                  int colNo = index % 8;

                  return SquareTile(
                    isWhite: isWhite(index),
                    piece: board[rowNo][colNo],
                    isSelected: selectedRow == rowNo && selecetedCol == colNo,
                    isValidMove: isValidMove(rowNo, colNo, validMoves),
                    onTap: () => selectPiece(rowNo, colNo),
                  );
                }),
          ),

          // BLACK DEAD PIECES
          Expanded(
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemCount: blackDeadPieces.length,
                itemBuilder: (context, index) {
                  return DeadPiece(
                      imagePath: blackDeadPieces[index].imagePath,
                      isWhite: false);
                }),
          ),
        ],
      ),
    );
  }
}
