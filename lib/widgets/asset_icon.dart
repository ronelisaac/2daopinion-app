import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetIcon extends StatelessWidget {
  const AssetIcon(this.name, {super.key, this.size = 24});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/images/$name.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}
