import 'package:flutter/material.dart';

class RArrowLogo extends StatelessWidget {
  final double size;

  const RArrowLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/icon.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.local_parking_rounded,
            size: size * 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
