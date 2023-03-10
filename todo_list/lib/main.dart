import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/todo_dto.dart';
import 'package:todo_list/screen/todo_list_view.dart';

import 'dao/todo_dao.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoHomePage(title: 'Hello TodoList'),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key, required this.title});

// TodoHomePage() 생상자에 title 변수 값으로 전달된 문자열이
// 자동 setting 된다.
  final String title;

  @override
  State<TodoHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TodoHomePage> {
  String content = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Image(
            image: AssetImage("images/image.jpg"),
            height: 100,
            width: 100,
          ),
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                onPressed: () {
                  todoInputBox(context);
                },
                icon: const Icon(Icons.add),
              ),
            )
          ],
        ),
        // Future 로 감싼 클래스 실행

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
          child: FutureBuilder(
              // 데이터 가져오기
              future: TodoDao().selectAll(),
              // 데이터를 화면에 표시
              builder: (context, snapShot) {
                if (snapShot.hasData) {
                  return TodoListView(todoList: snapShot);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        ));
  }

  Future<dynamic> todoInputBox(BuildContext context) {
    return showDialog(
        // 모달 영역 밖을 눌러도 모달이 사라지지 않음
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  decoration: const InputDecoration(hintText: "할일 입력"),
                  onChanged: (value) {
                    setState(() {
                      content = value;
                    });
                  },
                ),
              ),
              // 여백 요소
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, "INSERT");
                      },
                      child: const Text("추가")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("취소",
                          style: TextStyle(color: Colors.blue))),
                ],
              )
            ],
          );
        }).then((result) {
      if (result == "INSERT") {
        // DateTime.now(): 시스템(단말장치)의 현재 날짜와 시간 가져오기
        // DateFormat(형식).format(날짜 데이터): 날짜 데이터를 형식 문자열로 변환
        String sdate = DateFormat("yyyy-MM-dd").format(DateTime.now());
        String stime = DateFormat("HH:mm:ss").format(DateTime.now());
        TodoDto todo = TodoDto(
          sdate: sdate, // "2023-03-02"
          stime: stime, // "15:50:00"
          content: content,
        );
        TodoDao().insert(todo);
        // 화면 갱신
        setState(() {});
      }
    });
  }
}
