import 'package:chess_app/global_variables.dart';
import 'package:chess_app/widgets/piece.dart';
import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  void Function()? onTap;
  SquareTile(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = selectedSquareColor;
    } else {
      squareColor = isWhite ? whiteSquare : blackSquare;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null ? Image.asset(piece!.imagePath) : null,
      ),
    );
  }
}
