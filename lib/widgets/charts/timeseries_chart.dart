import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ndu_api_client/models/dashboards/data_models.dart';

class TimeSeriesChart extends StatelessWidget {

  final List<charts.Series<TimeSeriesGraphData, DateTime>> seriesList;
  final List<charts.SeriesLegend> legendList;
  final bool animate;

  TimeSeriesChart({this.seriesList, this.legendList, this.animate}) :super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
        seriesList,
        animate: animate,
        behaviors: legendList,
        domainAxis: new charts.DateTimeAxisSpec(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              minute: new charts.TimeFormatterSpec(
                format: 'mm', // or even HH:mm here too
                transitionFormat: 'HH:mm:ss',
              ),))

    );
  }

}