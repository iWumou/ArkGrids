import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  MemorialDayPageState createState() => MemorialDayPageState();
}

class MemorialDayPageState extends State<MemorialDayPage> {
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
        MemorialDayPage.addMemorialDay(
          context,
          widget.key as GlobalKey<MemorialDayPageState>,
          editItem: days[index],
          editIndex: index,
        );
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
