import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_dashboard_widgets/models/data_models.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BasicTimeseriesChart extends BaseDashboardWidget {
  BasicTimeseriesChart(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _BasicTimeseriesChartWidgetState createState() => _BasicTimeseriesChartWidgetState();
}

class _BasicTimeseriesChartWidgetState extends BaseDashboardState<BasicTimeseriesChart> {
  List<SocketData> allRawData = List();

  List<charts.Series> seriesList = List<charts.Series<TimeSeriesGraphData, DateTime>>();
  List<charts.SeriesLegend> legendList = List();
  bool animate = true;

  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;

  @override
  void initState() {
    super.initState();

    charts.BehaviorPosition position = charts.BehaviorPosition.bottom;
    if (widget.widgetConfig.config.legendConfig != null) {
      if (widget.widgetConfig.config.legendConfig.position == "top") position = charts.BehaviorPosition.top;
      if (widget.widgetConfig.config.legendConfig.position == "bottom") position = charts.BehaviorPosition.bottom;
      if (widget.widgetConfig.config.legendConfig.position == "left") position = charts.BehaviorPosition.start;
      if (widget.widgetConfig.config.legendConfig.position == "right") position = charts.BehaviorPosition.end;
    }
    if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      if (widget.widgetConfig.config.datasources[0].dataKeys != null && widget.widgetConfig.config.datasources[0].dataKeys.length > 0) {
        dataSourceLabel = widget.widgetConfig.config.datasources[0].dataKeys[0].label;
        dataSourceKey = widget.widgetConfig.config.datasources[0].dataKeys[0].name;

        int index = 0;
        int dataKeyIndex = 0;
        widget.widgetConfig.config.datasources.forEach((dataSource) {
          dataSource.dataKeys.forEach((dataKey) {
            seriesList.add(new charts.Series<TimeSeriesGraphData, DateTime>(
              id: dataKey.name,
              displayName: dataKey.label,
              colorFn: (_, __) => charts.Color.fromHex(code: dataKey.color),
              domainFn: (TimeSeriesGraphData sales, _) => sales.time,
              measureFn: (TimeSeriesGraphData sales, _) => sales.value,
              data: [],
            ));

            legendList.add(charts.SeriesLegend(
                position: position,
                outsideJustification: charts.OutsideJustification.start,
                horizontalFirst: false,
                desiredMaxRows: 2,
                cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                entryTextStyle: charts.TextStyleSpec(color: charts.Color.fromHex(code: dataKey.color), fontFamily: 'Georgia', fontSize: 12)));
            dataKeyIndex++;
          });
          index++;
        });
      }
    }

    int a = 5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 250,
      decoration: BoxDecoration(color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: charts.TimeSeriesChart(
                seriesList,
                animate: animate,
                // Optionally pass in a [DateTimeFactory] used by the chart. The factory
                // should create the same type of [DateTime] as the data provided. If none
                // specified, the default creates local date time.
                dateTimeFactory: const charts.LocalDateTimeFactory(),
                behaviors: legendList,
              ),
            ),
          ),
          // Text(
          //   "${result}",
          //   style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 35),
          // )
        ],
      ),
    );
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;

    int index = 0;
    graphData.datas.forEach((key, values) {
      values.forEach((value) {
        int ts = value[0];
        double val = 0;
        if (value[1] is double) val = value[1];
        if (value[1] is String) val = double.parse(value[1]);
        TimeSeriesGraphData tsData = TimeSeriesGraphData(DateTime.fromMillisecondsSinceEpoch(ts), val);
        addDataToSeries(key, tsData);
      });
      index++;
    });
  }

  void addDataToSeries(String key, TimeSeriesGraphData tsData) {
    int index = 0;
    int foundIndex = 0;
    seriesList.forEach((element) {
      if (element.id == key) foundIndex = index;
      index++;
    });
    seriesList[foundIndex].data.add(tsData);
    setState(() {});
  }
}
