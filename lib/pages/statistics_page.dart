import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Study Statistics')),
      body: Center(
        child: Text('Statistics Screen - Track Progress'),
      ),
    );
  }
}