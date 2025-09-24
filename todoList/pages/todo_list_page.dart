import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}
class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  String? oErro;

  List<Todo> todos = [];
  void onDelete(Todo todo){
    int pos = todos.indexOf(todo);
   setState(() {
     todos.remove(todo);
     todoRepository.saveTodoList(todos);
   });
   ScaffoldMessenger.of(context).clearSnackBars();
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
         content: Text('Tarefa ${todo.title} foi deletada. ', style: TextStyle(color: Colors.black)),
         backgroundColor: Colors.lightGreen,
       action: SnackBarAction(label: 'Desfazer', textColor: Color(0xffc042fe),onPressed: (){
         setState(() {
           todos.insert(pos, todo);
           todoRepository.saveTodoList(todos);
         });
       }),
     ),
   );
  } // onDelete

  @override
  void initState(){
    super.initState();

    todoRepository.getTodoList().then((value){
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'e.g: Estudar compiladores.',
                          errorText: oErro,
                        ),
                        style: TextStyle(
                          fontSize: 15
                        ),
                      ),
                    ),
                    SizedBox(width: 8,),
                    ElevatedButton(
                        onPressed: () {
                          String text = todoController.text;
                          Todo newTodo = Todo(title: text, date: DateTime.now());
                          setState(() {
                            if(text.isEmpty){
                              setState(() {
                                oErro = 'Não pode inserir tarefas vazias.';
                              });
                            }
                            if(text != '') {
                              todos.add(newTodo);
                              todoRepository.saveTodoList(todos);
                              oErro = null;
                            }
                          });
                          todoController.clear();
                        },
                        child: Icon(Icons.add, size: 35),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.purpleAccent,
                          backgroundColor: Colors.brown,
                          padding: EdgeInsets.all(16)
                        ),
                    )
                  ],
                ),
                SizedBox(height: 16,),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                      children: [
                        for(Todo todo in todos)
                          TodoListItem(todo: todo, onDelete: onDelete)
                      ],
                    ),
                ),
                SizedBox(height: 16,),
                Row(
                  children: [
                    Expanded(
                        child: Text('Você possui ${todos.length} tarefas pendentes.')
                    ),
                    SizedBox(width: 8,),
                    ElevatedButton(
                        onPressed: (){
                            showDialog(context: context, builder: (context) => AlertDialog(
                              title: Text('Limpar todas as tarefas?'),
                              content: Text('Tem certeza irmãozinho?'),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text('Delete não...')),
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                  setState(() {
                                    todos.clear();
                                    todoRepository.saveTodoList(todos);
                                  });
                                },style: TextButton.styleFrom(foregroundColor: Colors.redAccent) ,child: Text('APAGUE!!'))
                              ],
                            ));
                        },

                        style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                        ),
                        foregroundColor: Colors.purpleAccent,
                        backgroundColor: Colors.brown,
                        padding: EdgeInsets.all(16),
                        ),
                        child: Text('Limpar Tudo'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
