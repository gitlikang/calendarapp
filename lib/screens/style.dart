import 'package:flutter/material.dart';

class Style {
  final Decoration selectedDecoration;
  final Decoration weekendDecoration;
  final Decoration defaultDecoration;
  final Decoration todayDecoration;
  final Decoration outsideDecoration;

  final TextStyle weekendTextStyle;
  final TextStyle defaultTextStyle;
  final TextStyle todayTextStyle;
  final TextStyle outsideTextStyle;

  final TextStyle festivalTextStyle;

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
      this.weekendTextStyle = const TextStyle(color: Colors.black),
      this.defaultTextStyle = const TextStyle(color: Colors.black),
      this.todayTextStyle = const TextStyle(
        color: Colors.white,
      ),
      this.outsideTextStyle = const TextStyle(color: Color(0xFFAEAEAE)),
      this.festivalTextStyle = const TextStyle(
        color: Colors.blue,
      )});

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
