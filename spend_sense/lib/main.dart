import 'package:flutter/material.dart';
import 'package:spend_sense/accounts.dart';
import 'package:spend_sense/transactions.dart';


void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black
        )
      ),
      title: 'Named Routes Demo',
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const AccountsScreen(),
        '/transactions': (context) => const  TransactionsScreen(),
      },
    ),
  );
}

