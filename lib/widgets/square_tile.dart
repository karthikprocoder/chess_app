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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: !isSelected
            ? isWhite
                ? whiteSquare
                : blackSquare
            : selectedSquareColor,
        child: piece != null
            ? Container(
                decoration: !isValidMove
                    ? null
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade400, width: 2),
                      ),
                child: Image.asset(
                  piece!.imagePath,
                ),
              )
            : isValidMove
                ? Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
      ),
    );
  }
}
