import 'package:chess_app/global_variables.dart';
import 'package:chess_app/widgets/piece.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SquareTile extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  void Function()? onTap;
  SquareTile(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.isValidMove,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = selectedSquareColor;
    } else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? whiteSquare : blackSquare;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 2 : 0),
        child: piece != null ? Image.asset(piece!.imagePath) : null,
      ),
    );
  }
}
