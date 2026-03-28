import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  static Future addPlan(
    BuildContext context,
    GlobalKey<PlanPageState> key, {
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
  PlanPageState createState() => PlanPageState();
}

class PlanPageState extends State<PlanPage> {
  List<Map<String, dynamic>> showList = [];
  String currentPlanType = "collect";
  int? selectedIndex;
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
          PlanPage.addPlan(
            context,
            widget.key as GlobalKey<PlanPageState>,
            editItem: showList[index],
            editIndex: index,
          );
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
