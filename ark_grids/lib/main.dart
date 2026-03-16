import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '计划&纪念日',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _currentPlanType = "collect";
  final _planKey = GlobalKey<_PlanPageState>();
  final _memorialKey = GlobalKey<_MemorialDayPageState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [PlanPage(key: _planKey), MemorialDayPage(key: _memorialKey)];
  }

  void _updatePlanType(String type) {
    setState(() {
      _currentPlanType = type;
    });
    _planKey.currentState?.changePlanType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            if (_currentIndex == 0) {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text("收集箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("collect");
                        },
                      ),
                      ListTile(
                        title: const Text("收货箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("done");
                        },
                      ),
                      ListTile(
                        title: const Text("垃圾箱"),
                        onTap: () {
                          Navigator.pop(context);
                          _updatePlanType("deleted");
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        title: _currentIndex == 0
            ? GestureDetector(
                onTap: () {
                  if (_currentPlanType == "collect") {
                    _updatePlanType("done");
                  } else if (_currentPlanType == "done") {
                    _updatePlanType("collect");
                  } else if (_currentPlanType == "deleted") {
                    _updatePlanType("collect");
                  }
                },
                child: Text(
                  _currentPlanType == "collect"
                      ? "收集箱"
                      : _currentPlanType == "done"
                      ? "收货箱"
                      : "垃圾箱",
                ),
              )
            : const Text("纪念日"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            PlanPage.addPlan(context, _planKey);
          } else {
            MemorialDayPage.addMemorialDay(context, _memorialKey);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 0) {
            _updatePlanType("collect");
          }
          setState(() {
            _currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "计划"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "纪念日",
          ),
        ],
      ),
    );
  }
}

// ====================== 计划页面 ======================
class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  static Future addPlan(
    BuildContext context,
    GlobalKey<_PlanPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");
    final descCtrl = TextEditingController(text: editItem?["desc"] ?? "");

    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    int priority = 2;

    if (editItem != null &&
        editItem["date"] != null &&
        editItem["date"].isNotEmpty) {
      DateTime date = DateTime.parse(editItem["date"]);
      selectedDate = date;
      selectedTime = TimeOfDay(hour: date.hour, minute: date.minute);
    }

    priority = editItem?["priority"] ?? 2;

    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(editItem == null ? "添加计划" : "编辑计划"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: "标题",
                      labelText: "计划标题",
                    ),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      hintText: "详细描述",
                      labelText: "计划描述（选填）",
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setStateDialog(() => selectedDate = date);
                            }
                          },
                          child: Text(
                            selectedDate == null
                                ? "选择日期（选填）"
                                : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setStateDialog(() => selectedTime = time);
                            }
                          },
                          child: Text(
                            selectedTime == null
                                ? "选择时间（选填）"
                                : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("优先级"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priority == 0
                              ? Colors.red
                              : Colors.grey[200],
                        ),
                        onPressed: () {
                          setStateDialog(() => priority = 0);
                        },
                        child: const Text(
                          "紧急",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priority == 1
                              ? Colors.yellow
                              : Colors.grey[200],
                        ),
                        onPressed: () {
                          setStateDialog(() => priority = 1);
                        },
                        child: const Text("一般"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priority == 2
                              ? Colors.black
                              : Colors.grey[200],
                        ),
                        onPressed: () {
                          setStateDialog(() => priority = 2);
                        },
                        child: const Text(
                          "不急",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("取消"),
              ),
              TextButton(
                onPressed: () async {
                  if (titleCtrl.text.isNotEmpty) {
                    String? dateString;
                    if (selectedDate != null) {
                      DateTime temp = selectedDate!;
                      if (selectedTime != null) {
                        temp = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );
                      }
                      dateString = temp.toIso8601String();
                    }

                    final prefs = await SharedPreferences.getInstance();

                    if (editItem != null && editIndex != null) {
                      List<String> list = [];
                      String type = editItem["type"] ?? "collect";
                      if (type == "collect")
                        list = prefs.getStringList("plans_collect") ?? [];
                      if (type == "done")
                        list = prefs.getStringList("plans_done") ?? [];
                      if (type == "deleted")
                        list = prefs.getStringList("plans_deleted") ?? [];

                      list[editIndex] = jsonEncode({
                        "title": titleCtrl.text,
                        "desc": descCtrl.text,
                        "date": dateString ?? "",
                        "priority": priority,
                        "done": false,
                        "type": type,
                      });
                      if (type == "collect")
                        await prefs.setStringList("plans_collect", list);
                      if (type == "done")
                        await prefs.setStringList("plans_done", list);
                      if (type == "deleted")
                        await prefs.setStringList("plans_deleted", list);
                    } else {
                      List<String> list =
                          prefs.getStringList("plans_collect") ?? [];
                      list.add(
                        jsonEncode({
                          "title": titleCtrl.text,
                          "desc": descCtrl.text,
                          "date": dateString ?? "",
                          "priority": priority,
                          "done": false,
                          "type": "collect",
                        }),
                      );
                      await prefs.setStringList("plans_collect", list);
                    }

                    Navigator.pop(c);
                    key.currentState?.loadData();
                  }
                },
                child: const Text("保存"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  List<Map<String, dynamic>> showList = [];
  String currentPlanType = "collect";
  int? selectedIndex;
  // 动画控制：存储正在执行消失动画的索引
  Set<int> fadingItems = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = [];
    if (currentPlanType == "collect")
      list = prefs.getStringList("plans_collect") ?? [];
    if (currentPlanType == "done")
      list = prefs.getStringList("plans_done") ?? [];
    if (currentPlanType == "deleted")
      list = prefs.getStringList("plans_deleted") ?? [];

    if (mounted) {
      setState(() {
        showList = list
            .map((e) => jsonDecode(e) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  void changePlanType(String type) {
    if (mounted) {
      setState(() {
        currentPlanType = type;
        selectedIndex = null;
        fadingItems.clear();
      });
      loadData();
    }
  }

  // 带动画的完成计划
  Future<void> finishPlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];

    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    collect.removeAt(index);
    await prefs.setStringList("plans_collect", collect);

    List<String> done = prefs.getStringList("plans_done") ?? [];
    item["type"] = "done";
    done.add(jsonEncode(item));
    await prefs.setStringList("plans_done", done);

    setState(() => fadingItems.remove(index));
    loadData();
  }

  // 带动画的取消完成
  Future<void> unFinishPlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];

    List<String> done = prefs.getStringList("plans_done") ?? [];
    done.removeAt(index);
    await prefs.setStringList("plans_done", done);

    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    item["type"] = "collect";
    collect.add(jsonEncode(item));
    await prefs.setStringList("plans_collect", collect);

    setState(() => fadingItems.remove(index));
    loadData();
  }

  // 带动画的删除到垃圾箱
  Future<void> deletePlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];

    if (currentPlanType == "collect") {
      List<String> collect = prefs.getStringList("plans_collect") ?? [];
      collect.removeAt(index);
      await prefs.setStringList("plans_collect", collect);
    }
    if (currentPlanType == "done") {
      List<String> done = prefs.getStringList("plans_done") ?? [];
      done.removeAt(index);
      await prefs.setStringList("plans_done", done);
    }

    List<String> deleted = prefs.getStringList("plans_deleted") ?? [];
    item["type"] = "deleted";
    deleted.add(jsonEncode(item));
    await prefs.setStringList("plans_deleted", deleted);

    setState(() {
      selectedIndex = null;
      fadingItems.remove(index);
    });
    loadData();
  }

  // 带动画的恢复
  Future<void> restorePlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    var item = showList[index];

    List<String> deleted = prefs.getStringList("plans_deleted") ?? [];
    deleted.removeAt(index);
    await prefs.setStringList("plans_deleted", deleted);

    List<String> collect = prefs.getStringList("plans_collect") ?? [];
    item["type"] = "collect";
    collect.add(jsonEncode(item));
    await prefs.setStringList("plans_collect", collect);

    setState(() {
      selectedIndex = null;
      fadingItems.remove(index);
    });
    loadData();
  }

  // 带动画的彻底删除
  Future<void> foreverDeletePlan(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    List<String> deleted = prefs.getStringList("plans_deleted") ?? [];
    deleted.removeAt(index);
    await prefs.setStringList("plans_deleted", deleted);

    setState(() {
      selectedIndex = null;
      fadingItems.remove(index);
    });
    loadData();
  }

  void showDeleteConfirm(int index) {
    String title = showList[index]["title"] ?? "";
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("确认删除"),
        content: Text("确认是否删除 $title"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              deletePlan(index);
            },
            child: const Text("删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showForeverDeleteConfirm(int index) {
    String title = showList[index]["title"] ?? "";
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("彻底删除"),
        content: Text("是否彻底删除 $title"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              foreverDeletePlan(index);
            },
            child: const Text("彻底删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showLongPressMenu(int index) {
    setState(() => selectedIndex = index);
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    if (currentPlanType != "deleted") {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(100, offset.dy + 100, 100, 0),
        items: const [
          PopupMenuItem(value: "edit", child: Text("编辑")),
          PopupMenuItem(value: "delete", child: Text("删除")),
        ],
      ).then((v) {
        if (v == "edit") {
          final homeState = context.findAncestorStateOfType<_HomePageState>();
          if (homeState != null) {
            PlanPage.addPlan(
              context,
              homeState._planKey,
              editItem: showList[index],
              editIndex: index,
            );
          }
        }
        if (v == "delete") showDeleteConfirm(index);
        setState(() => selectedIndex = null);
      });
    } else {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(100, offset.dy + 100, 100, 0),
        items: const [
          PopupMenuItem(value: "restore", child: Text("恢复")),
          PopupMenuItem(value: "forever", child: Text("彻底删除")),
        ],
      ).then((v) {
        if (v == "restore") restorePlan(index);
        if (v == "forever") showForeverDeleteConfirm(index);
        setState(() => selectedIndex = null);
      });
    }
  }

  String getCountDownText(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    DateTime target = DateTime.parse(dateStr);
    DateTime now = DateTime.now();
    int diff = target.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff < 0) return "已过期";
    return "$diff 天";
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.lime;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: showList.length,
        itemBuilder: (c, i) {
          final item = showList[i];
          final color = getPriorityColor(item["priority"] ?? 2);
          final isSelected = selectedIndex == i;
          final deadline = getCountDownText(item["date"]);
          final isFading = fadingItems.contains(i);

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isFading ? 0.0 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: isFading ? Colors.grey[300] : null,
              child: InkWell(
                onLongPress: () => showLongPressMenu(i),
                onTap: () => setState(() => selectedIndex = null),
                child: Card(
                  color: isSelected
                      ? Colors.blue[50]
                      : (currentPlanType == "deleted"
                            ? Colors.grey[100]
                            : null),
                  elevation: isSelected ? 3 : 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        if (currentPlanType != "deleted")
                          Checkbox(
                            value: currentPlanType == "done",
                            onChanged: (v) {
                              if (currentPlanType == "collect") {
                                finishPlan(i);
                              } else if (currentPlanType == "done") {
                                unFinishPlan(i);
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        if (currentPlanType == "deleted")
                          const Padding(padding: EdgeInsets.only(left: 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["title"],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                  decoration: currentPlanType == "done"
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              if (item["desc"]?.isNotEmpty ?? false)
                                Text(
                                  item["desc"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (deadline.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              deadline,
                              style: TextStyle(
                                color: deadline == "已过期"
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ====================== 纪念日页面 ======================
class MemorialDayPage extends StatefulWidget {
  const MemorialDayPage({super.key});

  static Future addMemorialDay(
    BuildContext context,
    GlobalKey<_MemorialDayPageState> key, {
    Map<String, dynamic>? editItem,
    int? editIndex,
  }) async {
    final titleCtrl = TextEditingController(text: editItem?["title"] ?? "");
    DateTime? selectedDate = editItem != null && editItem["date"] != null
        ? DateTime.parse(editItem["date"])
        : null;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(editItem == null ? "添加纪念日" : "编辑纪念日"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: "纪念日名称"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
              },
              child: const Text("选择日期"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty && selectedDate != null) {
                final prefs = await SharedPreferences.getInstance();
                List<String> list = prefs.getStringList("memorialDays") ?? [];

                final item = {
                  "title": titleCtrl.text,
                  "date": selectedDate!.toIso8601String(),
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
            child: const Text("保存"),
          ),
        ],
      ),
    );
  }

  @override
  State<MemorialDayPage> createState() => _MemorialDayPageState();
}

class _MemorialDayPageState extends State<MemorialDayPage> {
  List<Map<String, dynamic>> days = [];
  int? selectedIndex;
  Set<int> fadingItems = {};

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
    });
  }

  // 带动画删除纪念日
  Future<void> deleteItem(int index) async {
    setState(() => fadingItems.add(index));
    await Future.delayed(const Duration(milliseconds: 500));

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      days.removeAt(index);
      fadingItems.remove(index);
    });
    await prefs.setStringList(
      "memorialDays",
      days.map((e) => jsonEncode(e)).toList(),
    );
  }

  void showDeleteConfirm(int index) {
    String title = days[index]["title"] ?? "";
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("确认删除"),
        content: Text("确认是否删除 $title"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              deleteItem(index);
            },
            child: const Text("删除", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showLongPressMenu(int index) {
    setState(() => selectedIndex = index);
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, offset.dy + 100, 100, 0),
      items: const [
        PopupMenuItem(value: "edit", child: Text("编辑")),
        PopupMenuItem(value: "delete", child: Text("删除")),
      ],
    ).then((value) {
      if (value == null) {
        setState(() => selectedIndex = null);
        return;
      }
      if (value == "edit") {
        final homeState = context.findAncestorStateOfType<_HomePageState>();
        if (homeState != null) {
          MemorialDayPage.addMemorialDay(
            context,
            homeState._memorialKey,
            editItem: days[index],
            editIndex: index,
          );
        }
      }
      if (value == "delete") showDeleteConfirm(index);
      setState(() => selectedIndex = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: days.length,
        itemBuilder: (c, i) {
          final item = days[i];
          final date = DateTime.parse(item["date"]);
          final diff = DateTime.now().difference(date).inDays;
          final isSelected = selectedIndex == i;
          final isFading = fadingItems.contains(i);

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isFading ? 0.0 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: isFading ? Colors.grey[300] : null,
              child: InkWell(
                onLongPress: () => showLongPressMenu(i),
                onTap: () => setState(() => selectedIndex = null),
                child: Card(
                  color: isSelected ? Colors.blue[50] : null,
                  elevation: isSelected ? 3 : 1,
                  child: ListTile(
                    title: Text(item["title"]),
                    subtitle: Text("已过 $diff 天"),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
