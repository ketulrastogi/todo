
import 'package:todo/models/db.dart';

class TodoService {

  final AppDatabase database = AppDatabase();  
  
  // All tables have getters in the generated class - we can select the tasks table
  Future<List<Todo>> getAllTodos() => database.getAllTodos();

  // Moor supports Streams which emit elements when the watched data changes
  Stream<List<Todo>> watchAllTodos() => database.watchAllTodos();

  Future insertTodo(Todo todo) => database.insertTodo(todo);

  // Updates a Task with a matching primary key
  Future updateTodo(Todo todo) => database.updateTodo(todo);

  Future deleteTodo(Todo todo) => database.deleteTodo(todo);
}