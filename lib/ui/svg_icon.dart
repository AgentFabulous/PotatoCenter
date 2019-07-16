import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget svgIcon(String path, {Color color, double size = 24.0}) => SizedBox(
  width: size,
  height: size,
  child: SvgPicture.asset(
    path,
    color: color,
  ),
);
