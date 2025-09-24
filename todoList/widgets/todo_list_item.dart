import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({super.key, required this.todo, required this.onDelete});

  final Todo todo;
  final Function(Todo) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Slidable(
        key: ValueKey(todo.title),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_){
                onDelete(todo);
              },
              backgroundColor: Colors.redAccent,
              icon: Icons.delete,
              foregroundColor: Colors.white,
              label: 'delete',
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.green,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DateFormat('dd/MM/yyyy - HH:mm').format(todo.date),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                todo.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
