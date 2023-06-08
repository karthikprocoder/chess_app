import 'package:chess_app/methods/helper_methods.dart';
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

  void selectSquare(int rowNo, int colNo) {
    setState(() {
      selectedRow = rowNo;
      selecetedCol = colNo;
      selectedPiece = board[rowNo][colNo];
      validMoves = calculateRawValidMoves(rowNo, colNo, selectedPiece);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    // direction based on color
    int dir = (piece!.isWhite) ? -1 : 1;

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
            board[row + dir][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + dir, col - 1]);
        }
        if (isInBoard(row + dir, col + 1) &&
            board[row + dir][col + 1] != null &&
            board[row + dir][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + dir, col + 1]);
        }

        break;
      case ChessPieceType.rook:
        break;
      case ChessPieceType.knight:
        break;
      case ChessPieceType.bishop:
        break;
      case ChessPieceType.queen:
        break;
      case ChessPieceType.king:
        break;
      default:
    }

    return candidateMoves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          Expanded(
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: Container(
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
                      onTap: () => selectSquare(rowNo, colNo),
                    );
                  }),
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
