import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ndu_api_client/models/dashboards/data_models.dart';

// ignore: must_be_immutable
class BarChart extends StatelessWidget{
  List<charts.Series> seriesList = List<charts.Series<TimeSeriesGraphData, String>>();
  Map<String, List<dynamic>> seriesListData = Map<String, List<dynamic>>();
  List<charts.SeriesLegend> legendList = List();
  bool animate = false;

  BarChart({Key key, this.seriesList, this.legendList, this.animate}) : super(key: UniqueKey());
  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      animationDuration: Duration(seconds: 1),
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(labelStyle: charts.TextStyleSpec(fontSize: 12),labelRotation: 270, labelOffsetFromAxisPx: 50, labelOffsetFromTickPx: 50)),
    );
  }

}