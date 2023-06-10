import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chess_app/global_variables.dart';
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
  // audio player
  final audioPlayer = AudioPlayer();

  // timer
  Timer? whiteTimer;
  Timer? blackTimer;
  Duration whiteDuration = gameDuration;
  Duration blackDuration = gameDuration;

  // game timeout
  bool isTimeOut = false;

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
    playAudio("game-start");
    startTimer(true);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  // PLAY AUDIO
  Future playAudio(String audioType) async {
    await audioPlayer.setSource(AssetSource('sounds/$audioType.mp3'));
    // debugPrint(audioPlayer.source.toString());
    audioPlayer.play(audioPlayer.source!, volume: 100.0);
  }

  // start the timer
  void startTimer(bool isWhiteTurn) {
    if (isWhiteTurn) {
      whiteTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          final sec = whiteDuration.inSeconds - 1;
          if (sec < 0) {
            isTimeOut = true;
            showWinner("Black", "Timeout");
            whiteTimer!.cancel();
          } else {
            whiteDuration = Duration(seconds: sec);
          }
        });
      });
    } else {
      blackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          final sec = blackDuration.inSeconds - 1;
          if (sec < 0) {
            showWinner("White", "Timeout");
            blackTimer!.cancel();
          } else {
            blackDuration = Duration(seconds: sec);
          }
        });
      });
    }
  }

  // pause the timer
  void stopTimer(bool isWhiteTurn) {
    setState(() {
      if (isWhiteTurn) {
        whiteTimer!.cancel();
      } else {
        blackTimer!.cancel();
      }
    });
  }

  // reset both the timers
  void resetTimers({bool restart = true}) {
    stopTimer(true);
    stopTimer(false);
    setState(() {
      whiteDuration = gameDuration;
      blackDuration = gameDuration;
      if (restart) {
        startTimer(true);
      }
    });
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
    bool captured = false;
    // if the new spot has an enemy
    if (board[newRow][newCol] != null) {
      captured = true;
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
    // clear the selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selecetedCol = -1;
      validMoves = [];
    });

    //see if the opposite king is in under attack
    checkStatus = isKingInCheck(!isWhiteTurn);

    // check if check mate
    if (isCheckMate(!isWhiteTurn)) {
      String winner = "White";
      if (!isWhiteTurn) {
        winner = "Black";
      }
      playAudio("game-end");
      showWinner(winner, "Checkmate!");
    }

    // play move audio
    if (checkStatus) {
      playAudio("move-check");
    } else if (captured) {
      playAudio("capture");
    } else {
      playAudio("move-self");
    }

    // stop timer for current player
    stopTimer(isWhiteTurn);

    // start timer for other player
    startTimer(!isWhiteTurn);

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
    setState(() {
      // variables
      board = initializeBoard();
      selectedPiece = null;
      selectedRow = -1;
      selecetedCol = -1;
      validMoves.clear();
      whiteDeadPieces.clear();
      blackDeadPieces.clear();
      whiteKingPos = [7, 4];
      blackKingPos = [0, 4];
      checkStatus = false;
      isWhiteTurn = true;
      playAudio("game-start");
      resetTimers();
    });
  }

  // show winner dialog box

  void showWinner(String winner, String winType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$winType, $winner wins'),
        actions: [
          // play again
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              return resetGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text('Chess App'),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text(
                'New Game',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // WHITE DEAD PIECES
            Container(
              height: screenHeight * 0.10,
              color: Colors.red,
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 16),
                  itemCount: whiteDeadPieces.length,
                  itemBuilder: (context, index) {
                    return DeadPiece(
                        imagePath: whiteDeadPieces[index].imagePath,
                        isWhite: true);
                  }),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    // color: Colors.purple,
                    // height: screenHeight * 0.05,
                    child: Text(checkStatus ? 'CHECK!' : 'player 2'),
                  ),
                  Container(
                    // color: Colors.pink,
                    child: Text(formatDuration(blackDuration)),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.amber,
              height: screenHeight * 0.50,
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

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text('player 1'),
                  ),
                  Container(
                    child: Text(formatDuration(whiteDuration)),
                  ),
                ],
              ),
            ),

            // BLACK DEAD PIECES
            Container(
              color: Colors.blue,
              height: screenHeight * 0.10,
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 16),
                  itemCount: blackDeadPieces.length,
                  itemBuilder: (context, index) {
                    return DeadPiece(
                        imagePath: blackDeadPieces[index].imagePath,
                        isWhite: false);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
