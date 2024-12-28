import 'package:flutter/material.dart';
import 'package:isread/pages/book_view.dart';
import 'package:isread/pages/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISREAD',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: Colors.white,
          surface: Color(0xff112D4E),
        ),
      ),
      initialRoute: 'home_page',
      routes: {
        'home_page': (context) => HomeView(onCategorySelected: (category) {}),
        'book_page': (context) => BookView(selectedCategory: 'All'),
      },
    );
  }
}
