import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphView extends StatelessWidget {

  final String text;

  const GraphView({
    super.key,
    required this.text
  });

  List<FlSpot> generatePoints(){

    List<FlSpot> points = [];

    for(double x=-5; x<=5; x+=0.5){

      double y = x * x; // example parabola

      points.add(
        FlSpot(x,y)
      );

    }

    return points;

  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      height:200,

      child: LineChart(

        LineChartData(

          gridData: FlGridData(show:true),

          borderData: FlBorderData(show:true),

          titlesData: FlTitlesData(show:true),

          lineBarsData:[

            LineChartBarData(

              spots: generatePoints(),

              isCurved:true,

              color: Colors.blue,

              barWidth:3,

              dotData: FlDotData(show:false),

            )

          ],

        ),

      ),

    );

  }

}