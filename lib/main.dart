import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/services/todo.dart';
import 'package:todo/ui/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      builder: (context) => TodoService(), 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
        ),
        title: 'Material App',
        home: SafeArea(
                  child: Scaffold(
            body: HomePage(),
          ),
        ),
      ),
    );
  }
}
