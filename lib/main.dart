import 'package:flutter/material.dart';
import'package:flutter_bloc/flutter_bloc.dart';

void main(){
  runApp(const MyApp());
}
//model class for todo item
class TodoModel{
  final String id;
  final String title;
  final bool isCompleted;
  TodoModel({
    required this.id,
    required this.title,
    this.isCompleted  = false,
  });
  TodoModel copyWith({bool? isCompleted, String? id, String? title}){    //nullable used to show that it can contain null values. 
    return TodoModel(
      id: id ?? this.id, //if id is null then use the existing id
      title: title ?? this.title,  //if title is null then use the existing title
      isCompleted: isCompleted ?? this.isCompleted, //if isCompleted is null then use the existing isCompleted
    );
  }
}
// state class for managing the list of todos
class TodoState{
  final List<TodoModel> todos;
  TodoState(this.todos);
}
//cubit class for managing todo state and actions
class TodoCubit extends Cubit<TodoState>{ //Cubit is a state management class that extends the Cubit class from the flutter_bloc package. It manages the state of the todo list and provides methods to add and toggle todos.
  TodoCubit(): super(TodoState([])); //whenever the cubit is created, it initializes the state with an empty list of todos.
  void addTodo(String title){
    if(title.isEmpty) return; //if the title is empty, function returns without adding a new todo.
    debugPrint("-----------------------------------");
    debugPrint("Cubit: Adding todo with title: $title");
    final newTodo = TodoModel(id: DateTime.now().toString(), title: title); //creates a new instance of the TodoModel class with a unique id based on the current timestamp and the provided title.
    final updatedList = List<TodoModel>.from(state.todos)..add(newTodo);
    debugPrint("Cubit: Total task count after adding: ${updatedList.length}");
    debugPrint("-----------------------------------");
    emit(TodoState(updatedList)); //emits a new state with the updated list of todos, which triggers a rebuild of the UI to reflect the changes.
  }
  void toggleTodoStatus(String id){
    debugPrint("-----------------------------------");
    debugPrint("Cubit: Toggling todo status with id: $id");
    final updatedList = state.todos.map((todo) {
      if (todo.id == id) {
        bool newStatus= !todo.isCompleted;
        debugPrint("Cubit: New status for todo with id $id: $newStatus");
        return todo.copyWith(isCompleted: newStatus);
      }
      return todo;
    }).toList();
    debugPrint("------------------------------------");
    emit(TodoState(updatedList)); 
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key}); //

  @override
  Widget build(BuildContext context) {  //build method is called when the widget is inserted into the widget tree. It describes the part of the user interface represented by this widget.
    return MaterialApp(
      home: BlocProvider( //BlocProvider is a widget that provides an instance of a Bloc or Cubit to its descendants in the widget tree. It allows widgets to access and interact with the state managed by the provided Bloc or Cubit.
        create: (_) => TodoCubit(),   //
        child: const TodoScreen(),  //The child property of BlocProvider is set to an instance of TodoScreen, which is the main screen of the app where users can add and view their todo tasks. By wrapping TodoScreen with BlocProvider, we ensure that it has access to the TodoCubit and can interact with the state it manages.
      ),
    );
  }
}
class TodoScreen extends StatelessWidget { 
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App with Models & Prints'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Naya task likhein...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_task),
                  onPressed: () {
                    context.read<TodoCubit>().addTodo(textController.text);
                    textController.clear(); 
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Task List View
            Expanded(
              child: BlocBuilder<TodoCubit, TodoState>(
                builder: (context, state) {
                  if (state.todos.isEmpty) {
                    return const Center(
                      child: Text('Abhi koi task nahi hai! Upar likh kar add karein.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.todos.length,
                    itemBuilder: (context, index) {
                      TodoModel todo = state.todos[index];

                      return Card(
                        child: ListTile(
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 18,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: todo.isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          leading: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (_) {
                              context.read<TodoCubit>().toggleTodoStatus(todo.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}