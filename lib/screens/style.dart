import 'package:flutter/material.dart';

class Style {
  final Decoration selectedDecoration;
  final Decoration weekendDecoration;
  final Decoration defaultDecoration;
  final Decoration todayDecoration;
  final Decoration outsideDecoration;

  final TextStyle weekendTextStyleDay;
  final TextStyle defaultTextStyleDay;
  final TextStyle todayTextStyleDay;
  final TextStyle outsideTextStyleDay;
  final TextStyle festivalTextStyleDay;

  final TextStyle weekendTextStyle;
  final TextStyle defaultTextStyle;
  final TextStyle todayTextStyle;
  final TextStyle outsideTextStyle;
  final TextStyle festivalTextStyle;


  static const double fontSizeDay = 16;
  static const double fontSize = 12;

  const Style(
      {this.selectedDecoration = const BoxDecoration(
        color: Color.fromARGB(0xFF, 0xD0, 0xD0, 0xD0),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        shape: BoxShape.rectangle,
      ),
      this.weekendDecoration = const BoxDecoration(shape: BoxShape.rectangle),
      this.defaultDecoration = const BoxDecoration(shape: BoxShape.rectangle),
      this.todayDecoration = const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        shape: BoxShape.rectangle,
      ),
      this.outsideDecoration = const BoxDecoration(shape: BoxShape.rectangle),
      this.weekendTextStyleDay =
          const TextStyle(color: Colors.black, fontSize: fontSizeDay, fontWeight: FontWeight.bold),
      this.defaultTextStyleDay =
          const TextStyle(color: Colors.black, fontSize: fontSizeDay, fontWeight: FontWeight.bold),
      this.todayTextStyleDay =
          const TextStyle(color: Colors.white, fontSize: fontSizeDay, fontWeight: FontWeight.bold),
      this.outsideTextStyleDay =
          const TextStyle(color: Color(0xFFAEAEAE), fontSize: fontSizeDay, fontWeight: FontWeight.bold),
      this.festivalTextStyleDay =
          const TextStyle(color: Colors.blue, fontSize: fontSizeDay, fontWeight: FontWeight.bold),
      this.weekendTextStyle =
          const TextStyle(color: Colors.black, fontSize: fontSize),
      this.defaultTextStyle =
          const TextStyle(color: Color(0xFF909090), fontSize: fontSize),
      this.todayTextStyle =
          const TextStyle(color: Colors.white, fontSize: fontSize),
      this.outsideTextStyle =
          const TextStyle(color: Colors.grey, fontSize: fontSize),
      this.festivalTextStyle =
          const TextStyle(color: Colors.blue, fontSize: fontSize)});

  Decoration getDecoration(
      {bool selectFlag = false,
      todayFlag = false,
      outsideFlag = false,
      isWeekend = false}) {
    return selectFlag
        ? todayFlag
            ? todayDecoration
            : selectedDecoration
        : outsideFlag
            ? outsideDecoration
            : isWeekend
                ? weekendDecoration
                : defaultDecoration;
  }

    TextStyle getDayTextStyle(
      {bool selectFlag = false,
      todayFlag = false,
      outsideFlag = false,
      isWeekend = false,
      jiejiari = false}) {
    return outsideFlag
        ? outsideTextStyleDay
        : todayFlag
            ? selectFlag
                ? todayTextStyleDay
                : defaultTextStyleDay
            : jiejiari
                ? festivalTextStyleDay
                : isWeekend
                    ? weekendTextStyleDay
                    : defaultTextStyleDay;
  }

  TextStyle getTextStyle(
      {bool selectFlag = false,
      todayFlag = false,
      outsideFlag = false,
      isWeekend = false,
      jiejiari = false}) {
    return outsideFlag
        ? outsideTextStyle
        : todayFlag
            ? selectFlag
                ? todayTextStyle
                : defaultTextStyle
            : jiejiari
                ? festivalTextStyle
                : isWeekend
                    ? weekendTextStyle
                    : defaultTextStyle;
  }
}
