import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/todo.dart';

class TodoRepository{

  late SharedPreferences sharedPreferences;

  void saveTodoList(List<Todo> todos){
    final jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }

  Future<List<Todo>> getTodoList() async{
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString('todo_list') ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((item) => Todo.fromJson(item)).toList();
  }

}
