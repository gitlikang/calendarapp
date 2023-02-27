import 'package:calendarapp/screens/event.dart';
import 'package:calendarapp/screens/sputil.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lunar/lunar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  static const selctFontSize = 10.0;

  final calendarStyle = const CalendarStyle();

  final _eventInputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    _eventInputController.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  String cellText(DateTime day) {
    var text = '${day.day}';

    Lunar lunarDate = Lunar.fromDate(day);
    var festivals = lunarDate.getFestivals();
    if (festivals.isEmpty) {
      Solar solarDate = Solar.fromDate(day);
      festivals = solarDate.getFestivals();
    }
    if (festivals.isEmpty) {
      var s = lunarDate.getJieQi();
      if (s != '') {
        festivals = <String>[s];
      }
    }
    if (festivals.isEmpty) {
      var shujiu = lunarDate.getShuJiu();
      if (shujiu != null && shujiu.getIndex() == 1) {
        festivals = <String>[shujiu.getName()];
      }
    }
    if (festivals.isEmpty) {
      var fu = lunarDate.getFu();
      if (fu != null && fu.getIndex() == 1) {
        festivals = <String>[fu.getName()];
      }
    }
    if (festivals.isNotEmpty) {
      text += '\n${festivals.first}';
    } else if (lunarDate.getDay() == 1) {
      text += '\n${lunarDate.getMonthInChinese()}月';
    } else {
      text += '\n${lunarDate.getDayInChinese()}';
    }

    return text;
  }

  String daySPKey(DateTime day) {
    return '${day.year}_${day.month}_${day.day}';
  }

  List<Event> _getEventsForDay(DateTime day) {
    var events = SpUtils.getStringList(daySPKey(day));
    if (events == null) {
      return [];
    }
    return events.map((e) => Event(e)).toList();
  }

  void _removeEventsForDay(DateTime day, int index, String text) {
    var events = SpUtils.getStringList(daySPKey(day));
    if (events == null) {
      return;
    }
    if (events.length <= index) {
      return;
    }

    if (events[index] != text) {
      return;
    }

    events.removeAt(index);

    SpUtils.putStringList(daySPKey(day), events);

    setState(() {});
  }

  void __addEvensForDay(DateTime day, String event) {
    showModalBottomSheet(
        isScrollControlled: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                child: TextFormField(
                  maxLines: 1,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: '输入笔记内容',
                  ),
                  controller: _eventInputController,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_eventInputController.text == '') {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              // Retrieve the text the that user has entered by using the
                              // TextEditingController.
                              content: Text('请输入事件内容'),
                            );
                          },
                        );
                        return;
                      }
                      var events = SpUtils.getStringList(daySPKey(day));
                      events ??= [];
                      events.add(_eventInputController.text);
                      SpUtils.putStringList(daySPKey(day), events);
                      _eventInputController.text = '';
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('提交'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),
                ],
              )
            ],
          );
        });
/*
    var events = SpUtils.getStringList(daySPKey(day));
    events ??= [];
    events.add(event);
    SpUtils.putStringList(daySPKey(day), events);
*/
  }

  @override
  Widget build(BuildContext context) {
    _selectedEvents.value = _getEventsForDay(_selectedDay);

    final margin = calendarStyle.cellMargin;
    final padding = calendarStyle.cellPadding;
    final alignment = calendarStyle.cellAlignment;
    const duration = Duration(milliseconds: 250);

    var lunarDate = Lunar.fromDate(_selectedDay);
    var lunarYearMonth =
        '农历${lunarDate.getMonthInChinese()}月${lunarDate.getDayInChinese()}';
    var yi = lunarDate.getDayYi().join(',');
    var ji = lunarDate.getDayJi().join(',');

    return Scaffold(
        appBar: AppBar(
          title: const Text('日历'),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Visibility(
                visible: _selectedDay.year != DateTime.now().year ||
                    _selectedDay.month != DateTime.now().month ||
                    _selectedDay.day != DateTime.now().day,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _selectedDay = DateTime.now();
                      _focusedDay = _selectedDay;
                    });
                  },
                  child: const Text(
                    '今',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () {
                  __addEvensForDay(_selectedDay, '哈哈哈');
                },
                child: const Icon(Icons.add_box),
              )
            ],
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableCalendar<Event>(
                  locale: 'zh_CN',
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(3000, 11, 21),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  selectedDayPredicate: (day) {
                    // Use `selectedDayPredicate` to determine which day is currently selected.
                    // If this returns true, then `day` will be marked as selected.

                    // Using `isSameDay` is recommended to disregard
                    // the time-part of compared DateTime objects.
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      // Call `setState()` when updating the selected day
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      // Call `setState()` when updating calendar format
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    var day = _selectedDay.day;
                    if (day >
                        SolarUtil.getDaysOfMonth(
                            focusedDay.year, focusedDay.month)) {
                      day = SolarUtil.getDaysOfMonth(
                          focusedDay.year, focusedDay.month);
                    }
                    setState(() {
                      _focusedDay =
                          DateTime(focusedDay.year, focusedDay.month, day);
                      _selectedDay = _focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(defaultBuilder:
                      (BuildContext context, DateTime day,
                          DateTime focusedDay) {
                    var isWeekend = day.weekday == DateTime.saturday ||
                        day.weekday == DateTime.sunday;
                    return AnimatedContainer(
                      duration: duration,
                      margin: margin,
                      padding: padding,
                      decoration: isWeekend
                          ? calendarStyle.weekendDecoration
                          : calendarStyle.defaultDecoration,
                      alignment: alignment,
                      child: Text(
                        cellText(day),
                        textAlign: TextAlign.center,
                        style: isWeekend
                            ? calendarStyle.weekendTextStyle
                            : calendarStyle.defaultTextStyle,
                      ),
                    );
                  }, selectedBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return AnimatedContainer(
                      duration: duration,
                      margin: margin,
                      padding: padding,
                      decoration: calendarStyle.selectedDecoration,
                      alignment: alignment,
                      child: Text(cellText(day),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: selctFontSize,
                          )),
                    );
                  }, todayBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return AnimatedContainer(
                      duration: duration,
                      margin: margin,
                      padding: padding,
                      decoration: calendarStyle.todayDecoration,
                      alignment: alignment,
                      child: Text(cellText(day),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFFAFAFA),
                            fontSize: selctFontSize,
                          )),
                    );
                  }, outsideBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return AnimatedContainer(
                      duration: duration,
                      margin: margin,
                      padding: padding,
                      decoration: calendarStyle.outsideDecoration,
                      alignment: alignment,
                      child: Text(cellText(day),
                          textAlign: TextAlign.center,
                          style: calendarStyle.outsideTextStyle),
                    );
                  }, singleMarkerBuilder:
                      (BuildContext context, DateTime day, Event event) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 6,
                        height: 2,
                        margin: calendarStyle.markerMargin,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8.0),
                ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 1.0,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey,
                                  style: BorderStyle.solid,
                                  strokeAlign: BorderSide.strokeAlignInside),
                            ),
                          ),
                          child: ListTile(
                            onTap: () => print('${value[index]}'),
                            title: Text('${value[index]}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _removeEventsForDay(
                                    _selectedDay, index, value[index].title);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            lunarYearMonth,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '第${SolarWeek.fromDate(_selectedDay, 0).getIndexInYear()}周',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lunarDate.getYearInGanZhi()}${lunarDate.getYearShengXiao()}年 ${lunarDate.getMonthInGanZhi()}月 ${lunarDate.getDayInGanZhi()}日',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                            color: Colors.green,
                          ),
                          child: const Center(
                              child: Text(
                            '宜',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(yi)),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                            color: Colors.red,
                          ),
                          child: const Center(
                              child: Text(
                            '忌',
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                        const SizedBox(width: 4),
                        Expanded(child: Text(ji)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
