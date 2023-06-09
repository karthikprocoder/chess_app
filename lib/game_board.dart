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

  // KING'S POSITION
  List<int> whiteKingPos = [7, 4];
  List<int> blackKingPos = [0, 4];

  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    board = initializeBoard();
  }

  // CALLED WHEN A square_tile IS TAPPED
  // UPDATES THE SELECETED VARIABLES
  void selectPiece(int rowNo, int colNo) {
    setState(() {
      // No piece has been selected, this is the first selection
      if (board[rowNo][colNo] != null && selectedPiece == null) {
        // select only if its his turn
        if (board[rowNo][colNo]!.isWhite == isWhiteTurn) {
          selectedRow = rowNo;
          selecetedCol = colNo;
          selectedPiece = board[rowNo][colNo];
        }
      }

      // this is the following selection
      else if (board[rowNo][colNo] != null &&
          board[rowNo][colNo]!.isWhite == selectedPiece!.isWhite) {
        selectedRow = rowNo;
        selecetedCol = colNo;
        selectedPiece = board[rowNo][colNo];
      }

      // select the end square to move the piece
      else if (selectedPiece != null && isValidMove(rowNo, colNo, validMoves)) {
        movePiece(rowNo, colNo);
      }
      // clear selection
      else {
        selectedPiece = null;
        selectedRow = -1;
        selecetedCol = -1;
        validMoves = [];
      }

      // valid moves for one of the above selected square(can be empty)
      validMoves = calculateRealValidMoves(rowNo, colNo, selectedPiece, true);
    });
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool simulate) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves =
        calculateRawValidMoves(row, col, piece, board);

    if (!simulate) return candidateMoves;

    // simulate the next move
    for (var move in candidateMoves) {
      int endRow = move[0];
      int endCol = move[1];

      if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
        realValidMoves.add(move);
      }
    }

    return realValidMoves;
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
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPos = [newRow, newCol];
      } else {
        blackKingPos = [newRow, newCol];
      }
    }

    //see if the opposite king is in under attack
    checkStatus = isKingInCheck(!isWhiteTurn);
    // clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selecetedCol = -1;
      validMoves = [];
    });

    // check if check mate
    if (isCheckMate(!isWhiteTurn)) {
      String winner = "White";
      if (!isWhiteTurn) {
        winner = "Black";
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Check Mate!, $winner wins'),
          actions: [
            // play again
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                return resetGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
    // change turn
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    // get the position of the king
    List<int> kingPos = (isWhiteKing) ? whiteKingPos : blackKingPos;

    // check if any of the enemy pieces are attacking the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip emtpy and friendly pieces
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        // opponent
        List<List<int>> validMoves =
            calculateRealValidMoves(i, j, board[i][j], false);
        if (validMoves
            .any((move) => move[0] == kingPos[0] && move[1] == kingPos[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    // save current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king, save its current position
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      // update the king's position
      if (piece.isWhite) {
        originalKingPosition = whiteKingPos;
        whiteKingPos = [endRow, endCol];
      } else {
        originalKingPosition = blackKingPos;
        blackKingPos = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool isSafeMove = !isKingInCheck(piece.isWhite);

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if piece was the king, restore its original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPos = originalKingPosition!;
      } else {
        blackKingPos = originalKingPosition!;
      }
    }

    return isSafeMove;
  }

  // IS IT CHECKMATE ?
  bool isCheckMate(bool isWhiteKing) {
    // if the king is not in check then no checkmate
    if (!isKingInCheck(isWhiteKing)) return false;

    // atleast one legal move for our king then no checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        if (calculateRealValidMoves(i, j, board[i][j], true).isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  // RESET GAME
  void resetGame() {
    board = initializeBoard();
    whiteDeadPieces.clear();
    blackDeadPieces.clear();
    whiteKingPos = [7, 4];
    blackKingPos = [0, 4];
    checkStatus = false;
    isWhiteTurn = true;
    setState(() {});
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

          Text(checkStatus ? 'CHECK' : ''),
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
