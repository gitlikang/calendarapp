import 'package:calendarapp/screens/event.dart';
import 'package:calendarapp/screens/sputil.dart';
import 'package:calendarapp/screens/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
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
  static const selctFontSize = 12.0;

  final calendarStyle = const CalendarStyle();
  final style = const Style();

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

  String lunarMonthDayText(DateTime day) {
    Lunar lunarDate = Lunar.fromDate(day);
    if (lunarDate.getDay() == 1) {
      return '${lunarDate.getMonthInChinese()}月';
    }

    return lunarDate.getDayInChinese();
  }

  String jieriText(DateTime day) {
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
      return festivals.first;
    }

    return '';
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
                  maxLines: 3,
                  autofocus: true,
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

  Widget? cellBuilder(BuildContext context, DateTime day, DateTime focusedDay,
      {outsideFlag = false}) {
    var isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    var today = DateTime.now();

    var selectFlag = day.year == _selectedDay.year &&
        day.month == _selectedDay.month &&
        day.day == _selectedDay.day;
    var todayFlag = day.year == today.year &&
        day.month == today.month &&
        day.day == today.day;

    var jr = jieriText(day);
    var jrFlag = true;

    if (jr == '') {
      jr = lunarMonthDayText(day);
      jrFlag = false;
    }

    var holiday = HolidayUtil.getHolidayByYmd(day.year, day.month, day.day);

    var holidayText = '休';
    var holidayColor = Colors.green;

    if (holiday != null && holiday.isWork()) {
      holidayText = '班';
      holidayColor = Colors.red;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: calendarStyle.cellMargin,
      padding: calendarStyle.cellPadding,
      alignment: calendarStyle.cellAlignment,
      decoration: style.getDecoration(
          isWeekend: isWeekend,
          selectFlag: selectFlag,
          todayFlag: todayFlag,
          outsideFlag: outsideFlag),
      child: Stack(
        children: [
          Offstage(
            offstage: holiday == null,
            child: Container(
              margin: const EdgeInsets.only(left: 28),
              child: Text(holidayText,
                  style: TextStyle(fontSize: 10, color: holidayColor)),
            ),
          ),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: '${day.day}',
                  style: style.getTextStyle(
                      isWeekend: isWeekend,
                      selectFlag: selectFlag,
                      todayFlag: todayFlag,
                      outsideFlag: outsideFlag),
                  children: <TextSpan>[
                    TextSpan(
                      text: '\n$jr',
                      style: style.getTextStyle(
                          isWeekend: isWeekend,
                          selectFlag: selectFlag,
                          todayFlag: todayFlag,
                          outsideFlag: outsideFlag,
                          jiejiari: jrFlag),
                    ),
                  ]))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedEvents.value = _getEventsForDay(_selectedDay);

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
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  firstDay: DateTime.utc(1900, 1, 1),
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
                    return cellBuilder(context, day, focusedDay);
                  }, selectedBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return cellBuilder(context, day, focusedDay);
                  }, todayBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return cellBuilder(context, day, focusedDay);
                  }, outsideBuilder: (BuildContext context, DateTime day,
                      DateTime focusedDay) {
                    return cellBuilder(context, day, focusedDay,
                        outsideFlag: true);
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
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: value.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return SwipeActionCell(
                          key: ValueKey(value[index].title),
                          trailingActions: <SwipeAction>[
                            SwipeAction(
                              ///
                              /// This attr should be passed to first action
                              ///
                              nestedAction: SwipeNestedAction(title: "确认删除"),
                              title: "删除",
                              onTap: (CompletionHandler handler) async {
                                await handler(true);
                                _removeEventsForDay(
                                    _selectedDay, index, value[index].title);
                                setState(() {});
                              },
                              color: Colors.red,
                            ),
                          ],
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 1.0,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('${value[index]}'),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Divider(
                            color: Colors.grey,
                            height: 1,
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
                const Divider(height: 2),
              ],
            ),
          ],
        ));
  }
}
