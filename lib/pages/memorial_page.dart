import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunar/lunar.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class MemorialDayPage extends StatefulWidget {
  const MemorialDayPage({super.key});

  static Future addMemorialDay(
    BuildContext context,
    GlobalKey<MemorialDayPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");

    DateTime? selectedDate;
    String calendarType = (editItem?["calendarType"] ?? "solar") as String;

    if (editItem != null && editItem["date"] != null) {
      if (calendarType == "solar") {
        selectedDate = DateTime.parse(editItem["date"]);
      } else {
        final lunarStr = editItem["date"] as String;
        final parts = lunarStr.split('-');
        if (parts.length == 3) {
          final lunar = Lunar.fromYmd(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final solar = lunar.getSolar();
          selectedDate = DateTime(
            solar.getYear(),
            solar.getMonth(),
            solar.getDay(),
          );
        }
      }
    }

    String? selectedRepeatType = editItem?["repeatType"] as String?;

    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFF8F9FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      editItem == null ? "创建纪念日" : "编辑纪念日",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      editItem == null ? "记录每一个重要时刻" : "修改纪念日信息",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        hintText: "纪念日名称",
                        labelText: "名称",
                        prefixIcon: Icon(
                          Icons.celebration,
                          color: Colors.blue[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 日期选择（内部自带公历/农历切换）
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.grey.shade50, Colors.white],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await _showLunarDatePicker(context, selectedDate, (
                              lunarDate,
                              pickedCalType,
                            ) {
                              setStateDialog(() {
                                selectedDate = lunarDate;
                                calendarType = pickedCalType;
                              });
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getDateDisplayText(
                                    selectedDate,
                                    calendarType,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selectedDate == null
                                        ? Colors.grey[700]
                                        : const Color(0xFF667EEA),
                                    fontWeight: selectedDate != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // 重复周期
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[50],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.repeat,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "重复周期",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SegmentedButton<String?>(
                              segments: const [
                                ButtonSegment(
                                  value: null,
                                  label: Text("不重复"),
                                  icon: Icon(Icons.close, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'week',
                                  label: Text("每周"),
                                  icon: Icon(
                                    Icons.calendar_view_week,
                                    size: 16,
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'month',
                                  label: Text("每月"),
                                  icon: Icon(Icons.calendar_month, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'year',
                                  label: Text("每年"),
                                  icon: Icon(Icons.calendar_today, size: 16),
                                ),
                              ],
                              selected: {selectedRepeatType},
                              onSelectionChanged: (newValue) => setStateDialog(
                                () => selectedRepeatType = newValue.first,
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                      (s) => s.contains(MaterialState.selected)
                                          ? const Color(
                                              0xFF667EEA,
                                            ).withOpacity(0.2)
                                          : null,
                                    ),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                      (s) => s.contains(MaterialState.selected)
                                          ? const Color(0xFF667EEA)
                                          : null,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(c),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              if (titleCtrl.text.isNotEmpty &&
                                  selectedDate != null) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                List<String> list =
                                    prefs.getStringList("memorialDays") ?? [];

                                String dateStr;
                                if (calendarType == "solar") {
                                  dateStr = selectedDate!.toIso8601String();
                                } else {
                                  final solar = Solar.fromDate(selectedDate!);
                                  final lunar = solar.getLunar();
                                  dateStr =
                                      "${lunar.getYear()}-${lunar.getMonth()}-${lunar.getDay()}";
                                }

                                final item = {
                                  "title": titleCtrl.text,
                                  "date": dateStr,
                                  "repeatType": selectedRepeatType,
                                  "calendarType": calendarType,
                                };

                                if (editIndex != null) {
                                  list[editIndex] = jsonEncode(item);
                                } else {
                                  list.add(jsonEncode(item));
                                }

                                await prefs.setStringList("memorialDays", list);
                                Navigator.pop(c);
                                key.currentState?.loadData();
                              }
                            },
                            child: const Text(
                              "保存",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _getDateDisplayText(DateTime? date, String calendarType) {
    if (date == null) return "选择日期";
    if (calendarType == "solar") {
      return "${date.year}年${date.month}月${date.day}日";
    } else {
      final solar = Solar.fromDate(date);
      final lunar = solar.getLunar();
      return "${lunar.getYear()}年${lunar.getMonth()}月${lunar.getDay()}日 (农历)";
    }
  }

  static Future<void> _showLunarDatePicker(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime, String) onConfirm,
  ) async {
    DateTime selectedDate = currentDate ?? DateTime.now();
    String calendarType = 'solar';

    int lunarYear = selectedDate.year;
    int lunarMonth = selectedDate.month;
    int lunarDay = selectedDate.day;

    int solarYear = selectedDate.year;
    int solarMonth = selectedDate.month;
    int solarDay = selectedDate.day;

    List<int> years = List.generate(201, (i) => 1949 + i);
    List<int> months = List.generate(12, (i) => i + 1);

    int getLunarDaysCount(int year, int month) {
      try {
        for (int day = 30; day >= 1; day--) {
          try {
            Lunar.fromYmd(year, month, day);
            return day;
          } catch (_) {}
        }
      } catch (_) {}
      return 29;
    }

    int getSolarDaysCount(int year, int month) =>
        DateTime(year, month + 1, 0).day;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "选择日期",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'solar', label: Text("公历")),
                          ButtonSegment(value: 'lunar', label: Text("农历")),
                        ],
                        selected: {calendarType},
                        onSelectionChanged: (newSel) {
                          setState(() {
                            calendarType = newSel.first;
                            if (calendarType == 'solar') {
                              solarYear = selectedDate.year;
                              solarMonth = selectedDate.month;
                              solarDay = selectedDate.day;
                            } else {
                              final lunar = Solar.fromDate(
                                selectedDate,
                              ).getLunar();
                              lunarYear = lunar.getYear();
                              lunarMonth = lunar.getMonth();
                              lunarDay = lunar.getDay();
                            }
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (s) => s.contains(MaterialState.selected)
                                ? const Color(0xFF667EEA).withOpacity(0.2)
                                : null,
                          ),
                          foregroundColor: MaterialStateProperty.resolveWith(
                            (s) => s.contains(MaterialState.selected)
                                ? const Color(0xFF667EEA)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: years.indexOf(
                                calendarType == 'solar' ? solarYear : lunarYear,
                              ),
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                if (calendarType == 'solar') {
                                  solarYear = years[index];
                                  int max = getSolarDaysCount(
                                    solarYear,
                                    solarMonth,
                                  );
                                  if (solarDay > max) solarDay = max;
                                  selectedDate = DateTime(
                                    solarYear,
                                    solarMonth,
                                    solarDay,
                                  );
                                } else {
                                  lunarYear = years[index];
                                  int max = getLunarDaysCount(
                                    lunarYear,
                                    lunarMonth,
                                  );
                                  if (lunarDay > max) lunarDay = max;
                                  try {
                                    final l = Lunar.fromYmd(
                                      lunarYear,
                                      lunarMonth,
                                      lunarDay,
                                    );
                                    final s = l.getSolar();
                                    selectedDate = DateTime(
                                      s.getYear(),
                                      s.getMonth(),
                                      s.getDay(),
                                    );
                                  } catch (_) {}
                                }
                              });
                            },
                            children: years
                                .map(
                                  (y) => Center(
                                    child: Text(
                                      "$y年",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem:
                                  (calendarType == 'solar'
                                      ? solarMonth
                                      : lunarMonth) -
                                  1,
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                if (calendarType == 'solar') {
                                  solarMonth = index + 1;
                                  int max = getSolarDaysCount(
                                    solarYear,
                                    solarMonth,
                                  );
                                  if (solarDay > max) solarDay = max;
                                  selectedDate = DateTime(
                                    solarYear,
                                    solarMonth,
                                    solarDay,
                                  );
                                } else {
                                  lunarMonth = index + 1;
                                  int max = getLunarDaysCount(
                                    lunarYear,
                                    lunarMonth,
                                  );
                                  if (lunarDay > max) lunarDay = max;
                                  try {
                                    final l = Lunar.fromYmd(
                                      lunarYear,
                                      lunarMonth,
                                      lunarDay,
                                    );
                                    final s = l.getSolar();
                                    selectedDate = DateTime(
                                      s.getYear(),
                                      s.getMonth(),
                                      s.getDay(),
                                    );
                                  } catch (_) {}
                                }
                              });
                            },
                            children: months
                                .map(
                                  (m) => Center(
                                    child: Text(
                                      "$m月",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem:
                                  (calendarType == 'solar'
                                      ? solarDay
                                      : lunarDay) -
                                  1,
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                if (calendarType == 'solar') {
                                  solarDay = index + 1;
                                  selectedDate = DateTime(
                                    solarYear,
                                    solarMonth,
                                    solarDay,
                                  );
                                } else {
                                  lunarDay = index + 1;
                                  try {
                                    final l = Lunar.fromYmd(
                                      lunarYear,
                                      lunarMonth,
                                      lunarDay,
                                    );
                                    final s = l.getSolar();
                                    selectedDate = DateTime(
                                      s.getYear(),
                                      s.getMonth(),
                                      s.getDay(),
                                    );
                                  } catch (_) {}
                                }
                              });
                            },
                            children: List.generate(
                              calendarType == 'solar'
                                  ? getSolarDaysCount(solarYear, solarMonth)
                                  : getLunarDaysCount(lunarYear, lunarMonth),
                              (i) => Center(
                                child: Text(
                                  "${i + 1}日",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("取消"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onConfirm(selectedDate, calendarType);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("确定"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  MemorialDayPageState createState() => MemorialDayPageState();
}

class MemorialDayPageState extends State<MemorialDayPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> days = [];
  int? selectedIndex;
  Set<int> fadingItems = {};
  int _totalCount = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList("memorialDays") ?? [];
    setState(() {
      days = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _totalCount = days.length;
    });
  }

  Future<void> saveList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "memorialDays",
      days.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> deleteItem(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      days.removeAt(index);
      fadingItems.remove(index);
      _totalCount = days.length;
    });
    await saveList();
  }

  void _editMemorialDay(int index) {
    MemorialDayPage.addMemorialDay(
      context,
      widget.key as GlobalKey<MemorialDayPageState>,
      editItem: days[index],
      editIndex: index,
    );
  }

  void _showDeleteConfirm(int index) {
    String title = days[index]["title"] ?? "";
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFFEF5F5)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade50, Colors.red.shade100],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade400,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "确认删除",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "是否删除 \"$title\"？",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "删除后无法恢复",
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("取消", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          deleteItem(index);
                        },
                        child: const Text("删除", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLongPressMenu(int index) {
    if (_isDragging) return;
    setState(() => selectedIndex = index);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF8F9FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667EEA).withOpacity(0.1),
                            const Color(0xFF764BA2).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.celebration,
                        color: Color(0xFF667EEA),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "纪念日操作",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              _buildMenuItem(
                icon: Icons.edit,
                iconColor: const Color(0xFF667EEA),
                title: "编辑纪念日",
                subtitle: "修改名称或日期",
                onTap: () {
                  Navigator.pop(context);
                  _editMemorialDay(index);
                  setState(() => selectedIndex = null);
                },
              ),
              _buildMenuItem(
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                title: "删除纪念日",
                subtitle: "永久删除",
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirm(index);
                },
                isDestructive: true,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() => selectedIndex = null);
                  },
                  child: const Text(
                    "取消",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getActualDate(Map<String, dynamic> item) {
    final calendarType = item["calendarType"] as String? ?? "solar";
    final dateStr = item["date"] as String;
    if (calendarType == "solar") return DateTime.parse(dateStr);
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      final lunar = Lunar.fromYmd(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final solar = lunar.getSolar();
      return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
    }
    return DateTime.now();
  }

  DateTime? _getNextRepeatDate(Map<String, dynamic> item) {
    final repeatType = item["repeatType"] as String?;
    if (repeatType == null) return null;
    final calendarType = item["calendarType"] as String? ?? "solar";
    final dateStr = item["date"] as String;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (calendarType == "solar") {
      final baseDate = DateTime.parse(dateStr);
      final base = DateTime(baseDate.year, baseDate.month, baseDate.day);
      switch (repeatType) {
        case 'week':
          var d = base;
          while (d.isBefore(today)) d = d.add(const Duration(days: 7));
          return d;
        case 'month':
          var d = base;
          while (d.isBefore(today)) {
            int y = d.year, m = d.month + 1;
            if (m > 12) {
              m = 1;
              y++;
            }
            int day = base.day;
            int max = DateTime(y, m + 1, 0).day;
            if (day > max) day = max;
            d = DateTime(y, m, day);
          }
          return d;
        case 'year':
          var d = base;
          while (d.isBefore(today))
            d = DateTime(d.year + 1, base.month, base.day);
          return d;
        default:
          return null;
      }
    } else {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;
      final lunar = Lunar.fromYmd(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final solar = lunar.getSolar();
      DateTime base = DateTime(
        solar.getYear(),
        solar.getMonth(),
        solar.getDay(),
      );
      switch (repeatType) {
        case 'week':
          var d = base;
          while (d.isBefore(today)) d = d.add(const Duration(days: 7));
          return d;
        case 'month':
          var d = base;
          while (d.isBefore(today)) {
            final l = Solar.fromDate(d).getLunar();
            int y = l.getYear(), m = l.getMonth() + 1;
            if (m > 12) {
              m = 1;
              y++;
            }
            DateTime? t = _getLunarDaySafe(y, m, int.parse(parts[2]));
            if (t != null)
              d = t;
            else
              d = d.add(const Duration(days: 1));
          }
          return d;
        case 'year':
          var d = base;
          while (d.isBefore(today)) {
            final l = Solar.fromDate(d).getLunar();
            int y = l.getYear() + 1;
            DateTime? t = _getLunarDaySafe(
              y,
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            if (t != null)
              d = t;
            else
              d = d.add(const Duration(days: 1));
          }
          return d;
        default:
          return null;
      }
    }
  }

  DateTime? _getLunarDaySafe(int y, int m, int d) {
    try {
      final l = Lunar.fromYmd(y, m, d);
      final s = l.getSolar();
      return DateTime(s.getYear(), s.getMonth(), s.getDay());
    } catch (_) {
      for (int day = d; day >= 1; day--) {
        try {
          final l = Lunar.fromYmd(y, m, day);
          final s = l.getSolar();
          return DateTime(s.getYear(), s.getMonth(), s.getDay());
        } catch (_) {}
      }
    }
    return null;
  }

  String _getDisplayText(Map<String, dynamic> item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repeat = item["repeatType"];
    if (repeat != null) {
      final next = _getNextRepeatDate(item);
      if (next == null) return "计算错误";
      final n = DateTime(next.year, next.month, next.day);
      final diff = n.difference(today).inDays;
      if (diff == 0) return "今天";
      if (diff == 1) return "明天";
      if (diff > 0) return "还有$diff天";
      return "已过${-diff}天";
    } else {
      final t = _getActualDate(item);
      final dt = DateTime(t.year, t.month, t.day);
      final diff = dt.difference(today).inDays;
      if (diff == 0) return "今天";
      if (diff == 1) return "明天";
      if (diff > 0) return "还有$diff天";
      if (diff == -1) return "昨天";
      return "${-diff}天";
    }
  }

  String _getDateDisplayText(Map<String, dynamic> item) {
    final cal = item["calendarType"] ?? "solar";
    final date = item["date"];
    if (cal == "solar") {
      final d = DateTime.parse(date);
      return "${d.year}年${d.month}月${d.day}日";
    } else {
      final p = date.split('-');
      if (p.length == 3) return "${p[0]}年${p[1]}月${p[2]}日 (农历)";
      return date;
    }
  }

  (IconData, Color) _getRepeatIcon(String? t) {
    switch (t) {
      case 'week':
        return (Icons.calendar_view_week, Colors.green);
      case 'month':
        return (Icons.calendar_month, Colors.orange);
      case 'year':
        return (Icons.calendar_today, Colors.purple);
      default:
        return (Icons.celebration, Colors.purple.shade400);
    }
  }

  String _getRepeatText(String? t) {
    switch (t) {
      case 'week':
        return "每周";
      case 'month':
        return "每月";
      case 'year':
        return "每年";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F9FF),
              const Color(0xFFF0F2F8),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "纪念日 $_totalCount",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: days.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.celebration_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "暂无纪念日",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "点击 + 按钮添加纪念日",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[350],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: days.length,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) =>
                          AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              final v = CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ).value;
                              return Transform.scale(
                                scale: 0.95 + v * 0.05,
                                child: Material(
                                  elevation: 8,
                                  color: Colors.transparent,
                                  child: child,
                                ),
                              );
                            },
                            child: child,
                          ),
                      onReorderStart: (i) => _isDragging = true,
                      onReorder: (o, n) {
                        if (n > o) n--;
                        final item = days.removeAt(o);
                        days.insert(n, item);
                        setState(() {});
                      },
                      onReorderEnd: (i) async {
                        await saveList();
                        _isDragging = false;
                      },
                      itemBuilder: (c, i) {
                        final item = days[i];
                        final text = _getDisplayText(item);
                        final repeat = item["repeatType"];
                        final selected = selectedIndex == i;
                        final fading = fadingItems.contains(i);
                        final today = text == "今天";
                        final tomorrow = text == "明天";
                        final past =
                            text.contains("天") &&
                            !text.contains("还有") &&
                            text != "今天" &&
                            text != "明天" &&
                            text != "昨天";
                        final isRepeat = repeat != null;
                        final (icon, iconColor) = _getRepeatIcon(repeat);

                        Color badgeColor;
                        Color badgeBg;
                        if (today) {
                          badgeColor = Colors.pink.shade700;
                          badgeBg = Colors.pink.shade100;
                        } else if (tomorrow) {
                          badgeColor = Colors.orange.shade700;
                          badgeBg = Colors.orange.shade100;
                        } else if (text.contains("还有")) {
                          badgeColor = Colors.orange.shade700;
                          badgeBg = Colors.orange.shade100;
                        } else if (past) {
                          badgeColor = Colors.blue.shade700;
                          badgeBg = Colors.blue.shade100;
                        } else {
                          badgeColor = Colors.grey.shade600;
                          badgeBg = Colors.grey.shade100;
                        }

                        return Container(
                          key: ValueKey(
                            "${item["title"]}$i${item["date"]}${repeat ?? ""}${item["calendarType"] ?? ""}",
                          ),
                          child: ReorderableDragStartListener(
                            index: i,
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (ctx, val, child) => Transform.translate(
                                offset: Offset(0, 20 * (1 - val)),
                                child: Opacity(opacity: val, child: child),
                              ),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: fading ? 0 : 1,
                                child: GestureDetector(
                                  onDoubleTap: () => _showLongPressMenu(i),
                                  onTap: () =>
                                      setState(() => selectedIndex = null),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(selected ? 1.02 : 1.0),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              selected
                                                  ? Colors.pink.shade50
                                                  : Colors.grey.shade50,
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: today
                                                        ? [
                                                            Colors
                                                                .pink
                                                                .shade100,
                                                            Colors
                                                                .pink
                                                                .shade200,
                                                          ]
                                                        : [
                                                            Colors
                                                                .purple
                                                                .shade50,
                                                            Colors
                                                                .purple
                                                                .shade100,
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  isRepeat
                                                      ? Icons.repeat
                                                      : icon,
                                                  color: isRepeat
                                                      ? iconColor
                                                      : (today
                                                            ? Colors
                                                                  .pink
                                                                  .shade700
                                                            : iconColor),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            item["title"] ?? "",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey[800],
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        if (isRepeat) ...[
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: iconColor
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              _getRepeatText(
                                                                repeat,
                                                              ),
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    iconColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      _getDateDisplayText(item),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: badgeBg,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  text,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: badgeColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MemorialDayPage.addMemorialDay(
          context,
          widget.key as GlobalKey<MemorialDayPageState>,
        ),
        child: const Icon(Icons.add),
        elevation: 4,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
    );
  }
}
