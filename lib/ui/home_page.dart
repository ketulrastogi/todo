import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todo/models/db.dart';
import 'package:todo/services/todo.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String title = '';
  String description = '';

  @override
  Widget build(BuildContext context) {
    final todoService = Provider.of<TodoService>(context);
    return Scaffold(
        appBar: AppBar(
            title: Center(
              child: Text(
                'Todos',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0),
              ),
            ),
            elevation: 1.0,
            titleSpacing: NavigationToolbar.kMiddleSpacing,
            backgroundColor: Colors.white),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _buildTaskList(context, todoService),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showAddTodoDialog(context, todoService);
          },
        ),
        backgroundColor: Colors.white);
  }

  StreamBuilder<List<Todo>> _buildTaskList(
      BuildContext context, TodoService todoService) {
    return StreamBuilder(
      stream: todoService.watchAllTodos(),
      builder: (context, AsyncSnapshot<List<Todo>> snapshot) {
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, todoService);
          },
        );
      },
    );
  }

  Widget _buildListItem(Todo todo, TodoService todoService) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          foregroundColor: Colors.white,
          color: Colors.orangeAccent,
          iconWidget: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onTap: () {
            print(todo.toJson());
            showUpdateTodoDialog(context, todoService, todo);
          },
        ),
        IconSlideAction(
            caption: 'Delete',
            color: Colors.redAccent,
            iconWidget: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            onTap: () {
              try {
                todoService.deleteTodo(todo);
                Flushbar(
                  title: "SUCCESS",
                  message: "Succesfully deleted a todo item.",
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.green,
                )..show(context);
              } catch (e) {
                Flushbar(
                  title: "ERROR",
                  message: "Error occured while deleting a todo item.",
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.red,
                )..show(context);
              }
            })
      ],
      child: InkWell(
        onTap: () {
          try {
            todoService.updateTodo(todo.copyWith(completed: !todo.completed));
          } catch (e) {
            Flushbar(
              title: "ERROR",
              message: "Error occured while changing status of a todo item.",
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
            )..show(context);
          }
        },
        splashColor: Colors.pink[50],
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                child: (todo.completed)
                    ? Icon(
                        Icons.done,
                        color: Colors.green,
                        size: 32.0,
                      )
                    : Icon(
                        Icons.access_time,
                        color: Colors.pink,
                        size: 32.0,
                      ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 2.0, left: 4.0, right: 4.0),
                    child: Text(
                      todo.title,
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 2.0, left: 4.0, right: 4.0),
                    child: Text(
                      todo.description,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAddTodoDialog(BuildContext context, TodoService todoService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Add Todo')),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Title can not be empty.';
                      } else if (value.length < 3) {
                        return 'Title must of minimum 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        this.title = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      hintText: 'Enter Title',
                      labelText: 'Title',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Description can not be empty.';
                      } else if (value.length < 3) {
                        return 'Description must of minimum 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        this.description = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      hintText: 'Enter Description',
                      labelText: 'Description',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Text(
                      "ADD",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        Todo todo = Todo(
                            title: this.title,
                            description: this.description,
                            completed: true);
                        titleController.text = '';
                        descriptionController.text = '';
                        Navigator.pop(context);
                        try {
                          todoService.insertTodo(todo);
                          Flushbar(
                            title: "SUCCESS",
                            message: "Succesfully added a todo item.",
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.green,
                          )..show(context);
                        } catch (e) {
                          print(e);
                          Flushbar(
                            title: "ERROR",
                            message: "Error occured while adding a todo item.",
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          )..show(context);
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  showUpdateTodoDialog(
      BuildContext context, TodoService todoService, Todo todo) {
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Update Todo')),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: titleController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Title can not be empty.';
                      } else if (value.length < 3) {
                        return 'Title must of minimum 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        this.title = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      hintText: 'Enter Title',
                      labelText: 'Title',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: descriptionController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Description can not be empty.';
                      } else if (value.length < 3) {
                        return 'Description must of minimum 4 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        this.description = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      hintText: 'Enter Description',
                      labelText: 'Description',
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Text(
                      "UPDATE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _formKey.currentState.save();
                        print(this.title + ' + ' + this.description );
                        Todo _todo = Todo(
                            id: todo.id,
                            title: this.title,
                            description: this.description,
                            completed: true);

                        Navigator.pop(context);
                        try {
                          print(_todo.toJson());
                          todoService.updateTodo(_todo);
                          setState(() {
                            titleController.text = '';
                            descriptionController.text = '';
                          });
                          Flushbar(
                            title: "SUCCESS",
                            message: "Succesfully updated a todo item.",
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.green,
                          )..show(context);
                        } catch (e) {
                          print(e);
                          Flushbar(
                            title: "ERROR",
                            message:
                                "Error occured while updating a todo item.",
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.red,
                          )..show(context);
                        }
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
