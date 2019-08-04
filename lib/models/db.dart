import 'package:moor/moor.dart';
import 'package:moor_flutter/moor_flutter.dart';

// Moor works by source gen. This file will all the generated code.
part 'db.g.dart';

// The name of the database table is "tasks"
// By default, the name of the generated data class will be "Task" (without "s")
class Todos extends Table {
  // autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();
  // If the length constraint is not fulfilled, the Task will not
  // be inserted into the database and an exception will be thrown.
  TextColumn get title => text().withLength(min: 1, max: 50)();
  // If the length constraint is not fulfilled, the Task will not
  // be inserted into the database and an exception will be thrown.
  TextColumn get description => text().withLength(min: 1, max: 200)();
  // DateTime is not natively supported by SQLite
  // Moor converts it to & from UNIX seconds
  DateTimeColumn get createdDate =>
      dateTime()();
  // Booleans are not supported as well, Moor converts them to integers
  // Simple default values are specified as Constants
  BoolColumn get completed => boolean().withDefault(Constant(false))();

  // @override
  // Set<Column> get primaryKey => {title};

}

// This annotation tells the code generator which tables this DB works with
@UseMoor(tables: [Todos])
// _$AppDatabase is the name of the generated class
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      // Specify the location of the database file
      : super((FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
          // Good for debugging - prints SQL in the console
          logStatements: true,
        )));

  // Bump this when changing tables and columns.
  // Migrations will be covered in the next part.
  @override
  int get schemaVersion => 1;

  // All tables have getters in the generated class - we can select the tasks table
  Future<List<Todo>> getAllTodos() => select(todos).get();

  // Moor supports Streams which emit elements when the watched data changes
  Stream<List<Todo>> watchAllTodos() => (select(todos)..orderBy(([
        (t) => OrderingTerm(expression: t.createdDate, mode: OrderingMode.desc)
      ]))).watch();

  Future insertTodo(Todo todo) => into(todos).insert(todo);

  // Updates a Task with a matching primary key
  Future updateTodo(Todo todo) => update(todos).replace(todo);

  Future deleteTodo(Todo todo) => delete(todos).delete(todo);
}
