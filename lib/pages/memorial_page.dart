import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunar/lunar.dart';
import 'dart:convert';

class MemorialDayPage extends StatefulWidget {
  const MemorialDayPage({super.key});

  static Future addMemorialDay(
    BuildContext context,
    GlobalKey<MemorialDayPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");

    // 解析日期和历法类型
    DateTime? selectedDate;
    String calendarType =
        (editItem?["calendarType"] ?? "solar")
            as String; // solar: 阳历, lunar: 农历

    if (editItem != null && editItem["date"] != null) {
      if (calendarType == "solar") {
        selectedDate = DateTime.parse(editItem["date"]);
      } else {
        // 农历日期需要从存储的字符串解析
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
                    // 历法选择
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
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF667EEA),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "历法类型",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'solar',
                                  label: Text("阳历"),
                                  icon: Icon(Icons.wb_sunny, size: 16),
                                ),
                                ButtonSegment(
                                  value: 'lunar',
                                  label: Text("农历"),
                                  icon: Icon(Icons.nightlight_round, size: 16),
                                ),
                              ],
                              selected: {calendarType},
                              onSelectionChanged: (Set<String> newSelection) {
                                setStateDialog(() {
                                  calendarType = newSelection.first;
                                  selectedDate = null; // 切换历法时清空日期
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      Set<MaterialState> states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      )) {
                                        return const Color(
                                          0xFF667EEA,
                                        ).withOpacity(0.2);
                                      }
                                      return null;
                                    }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      Set<MaterialState> states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      )) {
                                        return const Color(0xFF667EEA);
                                      }
                                      return null;
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 日期选择
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
                            if (calendarType == "solar") {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                setStateDialog(() => selectedDate = date);
                              }
                            } else {
                              // 农历日期选择器
                              await _showLunarDatePicker(
                                context,
                                selectedDate,
                                (lunarDate) {
                                  setStateDialog(
                                    () => selectedDate = lunarDate,
                                  );
                                },
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  calendarType == "solar"
                                      ? Icons.calendar_today
                                      : Icons.nightlight_round,
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
                    // 重复选择
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
                              onSelectionChanged: (Set<String?> newSelection) {
                                setStateDialog(() {
                                  selectedRepeatType = newSelection.first;
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      Set<MaterialState> states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      )) {
                                        return const Color(
                                          0xFF667EEA,
                                        ).withOpacity(0.2);
                                      }
                                      return null;
                                    }),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color?>((
                                      Set<MaterialState> states,
                                    ) {
                                      if (states.contains(
                                        MaterialState.selected,
                                      )) {
                                        return const Color(0xFF667EEA);
                                      }
                                      return null;
                                    }),
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
    Function(DateTime) onConfirm,
  ) async {
    int year = currentDate?.year ?? DateTime.now().year;
    int month = currentDate?.month ?? DateTime.now().month;
    int day = currentDate?.day ?? DateTime.now().day;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("选择农历日期"),
            content: SizedBox(
              width: 300,
              height: 350,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            year--;
                          });
                        },
                      ),
                      Text("$year年", style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            year++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "选择月份",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 1,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final lunarMonth = index + 1;
                        final isSelected = month == lunarMonth;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              month = lunarMonth;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                "${lunarMonth}月",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "选择日期",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: 30,
                      itemBuilder: (context, index) {
                        final lunarDay = index + 1;
                        final isSelected = day == lunarDay;
                        // 检查该农历日期是否有效
                        bool isValid = true;
                        try {
                          final lunar = Lunar.fromYmd(year, month, lunarDay);
                          lunar.getSolar();
                        } catch (e) {
                          isValid = false;
                        }

                        return InkWell(
                          onTap: isValid
                              ? () {
                                  setState(() {
                                    day = lunarDay;
                                  });
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF667EEA)
                                  : (isValid
                                        ? Colors.grey[200]
                                        : Colors.grey[100]),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                "$lunarDay",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isValid
                                            ? Colors.black87
                                            : Colors.grey[400]),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("取消"),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    final lunar = Lunar.fromYmd(year, month, day);
                    final solar = lunar.getSolar();
                    onConfirm(
                      DateTime(
                        solar.getYear(),
                        solar.getMonth(),
                        solar.getDay(),
                      ),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("无效的农历日期")));
                  }
                },
                child: const Text("确定"),
              ),
            ],
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
    List<String> result = days.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList("memorialDays", result);
  }

  Future<void> deleteItem(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 300));

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      days.removeAt(index);
      fadingItems.remove(index);
      _totalCount = days.length;
    });
    await prefs.setStringList(
      "memorialDays",
      days.map((e) => jsonEncode(e)).toList(),
    );
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
              Container(
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

  // 获取实际的日期对象（根据历法转换）
  DateTime _getActualDate(Map<String, dynamic> item) {
    final calendarType = item["calendarType"] as String? ?? "solar";
    final dateStr = item["date"] as String;

    if (calendarType == "solar") {
      return DateTime.parse(dateStr);
    } else {
      // 农历日期
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
  }

  // 获取下次重复的日期
  DateTime? _getNextRepeatDate(Map<String, dynamic> item) {
    final repeatType = item["repeatType"] as String?;
    if (repeatType == null) return null;

    final calendarType = item["calendarType"] as String? ?? "solar";
    final dateStr = item["date"] as String;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // --------------------------
    // 公历（不变）
    // --------------------------
    if (calendarType == "solar") {
      final baseDate = DateTime.parse(dateStr);
      final baseDateOnly = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
      );

      switch (repeatType) {
        case 'week':
          DateTime nextDate = baseDateOnly;
          while (nextDate.isBefore(today)) {
            nextDate = nextDate.add(const Duration(days: 7));
          }
          return nextDate;

        case 'month':
          DateTime nextDate = baseDateOnly;
          while (nextDate.isBefore(today)) {
            int nextMonth = nextDate.month + 1;
            int nextYear = nextDate.year;
            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear++;
            }
            int targetDay = baseDateOnly.day;
            int daysInMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            if (targetDay > daysInMonth) {
              targetDay = daysInMonth;
            }
            nextDate = DateTime(nextYear, nextMonth, targetDay);
          }
          return nextDate;

        case 'year':
          DateTime nextDate = baseDateOnly;
          while (nextDate.isBefore(today)) {
            nextDate = DateTime(
              nextDate.year + 1,
              baseDateOnly.month,
              baseDateOnly.day,
            );
          }
          return nextDate;
      }
    }
    // --------------------------
    // 农历（已修复 API 版本）
    // --------------------------
    else {
      final parts = dateStr.split('-');
      if (parts.length != 3) return null;

      final ly = int.parse(parts[0]);
      final lm = int.parse(parts[1]);
      final ld = int.parse(parts[2]);

      // 农历转公历（正确API）
      final baseLunar = Lunar.fromYmd(ly, lm, ld);
      final baseSolar = baseLunar.getSolar(); // ✅ 修复
      DateTime baseDate = DateTime(
        baseSolar.getYear(),
        baseSolar.getMonth(),
        baseSolar.getDay(),
      );

      switch (repeatType) {
        case 'week':
          DateTime nextDate = baseDate;
          while (nextDate.isBefore(today)) {
            nextDate = nextDate.add(const Duration(days: 7));
          }
          return nextDate;

        case 'month':
          DateTime nextDate = baseDate;
          while (nextDate.isBefore(today)) {
            // 公历转农历（正确API）
            final currentLunar = Solar.fromDate(nextDate).getLunar(); // ✅ 修复
            int nextYear = currentLunar.getYear();
            int nextMonth = currentLunar.getMonth() + 1;

            if (nextMonth > 12) {
              nextMonth = 1;
              nextYear += 1;
            }

            DateTime? target = _getLunarDaySafe(nextYear, nextMonth, ld);
            if (target != null) {
              nextDate = target;
            } else {
              nextDate = nextDate.add(const Duration(days: 1));
            }
          }
          return nextDate;

        case 'year':
          DateTime nextDate = baseDate;
          while (nextDate.isBefore(today)) {
            final currentLunar = Solar.fromDate(nextDate).getLunar(); // ✅ 修复
            int nextYear = currentLunar.getYear() + 1;

            DateTime? target = _getLunarDaySafe(nextYear, lm, ld);
            if (target != null) {
              nextDate = target;
            } else {
              nextDate = nextDate.add(const Duration(days: 1));
            }
          }
          return nextDate;
      }
    }

    return null;
  }

  // 工具函数
  DateTime? _getLunarDaySafe(int year, int month, int day) {
    try {
      final lunar = Lunar.fromYmd(year, month, day);
      final solar = lunar.getSolar(); // ✅ 修复
      return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
    } catch (e) {
      try {
        for (int d = day; d >= 1; d--) {
          try {
            final lunar = Lunar.fromYmd(year, month, d);
            final solar = lunar.getSolar(); // ✅ 修复
            return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
          } catch (_) {}
        }
      } catch (_) {}
    }
    return null;
  }

  // 获取显示文本
  String _getDisplayText(Map<String, dynamic> item) {
    final repeatType = item["repeatType"] as String?;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 重复类型：显示距离下一个重复日期的天数
    if (repeatType != null) {
      final nextDate = _getNextRepeatDate(item);
      if (nextDate != null) {
        final nextDateOnly = DateTime(
          nextDate.year,
          nextDate.month,
          nextDate.day,
        );
        final daysLeft = nextDateOnly.difference(today).inDays;

        if (daysLeft == 0) return "今天";
        if (daysLeft == 1) return "明天";
        if (daysLeft > 0) return "还有$daysLeft天";
        return "已过${-daysLeft}天";
      }
      return "计算错误";
    }

    // 不重复：显示距离目标日期的天数
    final targetDate = _getActualDate(item);
    final targetDateOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final difference = targetDateOnly.difference(today).inDays;

    if (difference == 0) return "今天";
    if (difference == 1) return "明天";
    if (difference > 0) return "还有$difference天";
    if (difference == -1) return "昨天";
    return "${-difference}天";
  }

  String _getDateDisplayText(Map<String, dynamic> item) {
    final calendarType = item["calendarType"] as String? ?? "solar";
    final dateStr = item["date"] as String;

    if (calendarType == "solar") {
      final date = DateTime.parse(dateStr);
      return "${date.year}年${date.month}月${date.day}日";
    } else {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return "${parts[0]}年${parts[1]}月${parts[2]}日 (农历)";
      }
      return dateStr;
    }
  }

  // 获取重复类型的图标和颜色
  (IconData, Color) _getRepeatIcon(String? repeatType) {
    switch (repeatType) {
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

  // 获取重复周期的显示文本
  String _getRepeatText(String? repeatType) {
    switch (repeatType) {
      case 'week':
        return '每周';
      case 'month':
        return '每月';
      case 'year':
        return '每年';
      default:
        return '';
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
              child: Container(
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
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 20,
                    ),
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
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final value = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ).value;
                            return Transform.scale(
                              scale: 0.95 + (value * 0.05),
                              child: Material(
                                elevation: 8,
                                color: Colors.transparent,
                                child: child,
                              ),
                            );
                          },
                          child: child,
                        );
                      },
                      onReorderStart: (index) {
                        _isDragging = true;
                      },
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        final item = days.removeAt(oldIndex);
                        days.insert(newIndex, item);
                        setState(() {});
                      },
                      onReorderEnd: (index) async {
                        await saveList();
                        _isDragging = false;
                      },
                      itemBuilder: (c, i) {
                        final item = days[i];
                        final displayText = _getDisplayText(item);
                        final repeatType = item["repeatType"] as String?;
                        final isSelected = selectedIndex == i;
                        final isFading = fadingItems.contains(i);
                        final isToday = displayText == "今天";
                        final isTomorrow = displayText == "明天";
                        final isPast =
                            displayText.contains("天") &&
                            !displayText.contains("还有") &&
                            displayText != "今天" &&
                            displayText != "明天" &&
                            displayText != "昨天";
                        final isRepeat = repeatType != null;

                        // 获取图标
                        final (iconData, iconColor) = _getRepeatIcon(
                          repeatType,
                        );

                        // 判断显示样式
                        Color badgeColor;
                        if (isToday) {
                          badgeColor = Colors.pink.shade700;
                        } else if (isTomorrow) {
                          badgeColor = Colors.orange.shade700;
                        } else if (displayText.contains("还有")) {
                          badgeColor = Colors.orange.shade700;
                        } else if (isPast) {
                          badgeColor = Colors.blue.shade700;
                        } else {
                          badgeColor = Colors.grey.shade600;
                        }

                        Color badgeBgColor;
                        if (isToday) {
                          badgeBgColor = Colors.pink.shade100;
                        } else if (isTomorrow) {
                          badgeBgColor = Colors.orange.shade100;
                        } else if (displayText.contains("还有")) {
                          badgeBgColor = Colors.orange.shade100;
                        } else if (isPast) {
                          badgeBgColor = Colors.blue.shade100;
                        } else {
                          badgeBgColor = Colors.grey.shade100;
                        }

                        return Container(
                          key: ValueKey(
                            item["title"] +
                                i.toString() +
                                item["date"] +
                                (repeatType ?? "") +
                                (item["calendarType"] ?? ""),
                          ),
                          child: ReorderableDragStartListener(
                            index: i,
                            child: TweenAnimationBuilder(
                              duration: const Duration(milliseconds: 300),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: isFading ? 0.0 : 1.0,
                                child: GestureDetector(
                                  onDoubleTap: () => _showLongPressMenu(i),
                                  onTap: () =>
                                      setState(() => selectedIndex = null),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    transform: Matrix4.identity()
                                      ..scale(isSelected ? 1.02 : 1.0),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                                isSelected
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
                                                      colors: isToday
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
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    isRepeat
                                                        ? Icons.repeat
                                                        : iconData,
                                                    color: isRepeat
                                                        ? iconColor
                                                        : (isToday
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              item["title"] ??
                                                                  "",
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
                                                                    horizontal:
                                                                        6,
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
                                                                  repeatType,
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
                                                        _getDateDisplayText(
                                                          item,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[500],
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
                                                    color: badgeBgColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    displayText,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
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
