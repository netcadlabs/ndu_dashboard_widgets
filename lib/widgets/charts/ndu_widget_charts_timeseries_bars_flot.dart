import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/datetime_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TimeSeriesBarsFlot extends BaseDashboardWidget {
  TimeSeriesBarsFlot(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _TimeSeriesBarsFlotWidgetState createState() => _TimeSeriesBarsFlotWidgetState();
}

class _TimeSeriesBarsFlotWidgetState extends BaseDashboardState<TimeSeriesBarsFlot> {
  List<SocketData> allRawData = List();

  List<charts.Series> seriesList = List<charts.Series<TimeSeriesGraphData, String>>();
  Map<String, List<dynamic>> seriesListData = Map<String, List<dynamic>>();
  List<charts.SeriesLegend> legendList = List();
  bool animate = false;

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
      widget.widgetConfig.config.datasources.forEach((dataSource) {
        dataSource.dataKeys.forEach((dataKey) {
          seriesList.add(new charts.Series<TimeSeriesGraphData, String>(
            id: dataKey.name,
            displayName: dataKey.label,
            colorFn: (_, __) => charts.Color.fromHex(code: dataKey.color),
            domainFn: (TimeSeriesGraphData sales, _) => DatetimeUtils.getTime(sales.time),
            measureFn: (TimeSeriesGraphData sales, _) => sales.value,
            data: seriesListData[dataKey.name] == null ? [] : seriesListData[dataKey.name],
          ));

          legendList.add(charts.SeriesLegend(
              position: position,
              outsideJustification: charts.OutsideJustification.start,
              horizontalFirst: false,
              desiredMaxRows: 2,
              cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
              entryTextStyle: charts.TextStyleSpec(color: charts.Color.fromHex(code: dataKey.color), fontFamily: 'Georgia', fontSize: 12)));
        });
      });
    }

    int a = 5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    charts.BarGroupingType barGroupingType = charts.BarGroupingType.grouped;
    if (widget.widgetConfig.config.settings != null && widget.widgetConfig.config.settings.stack) {
      barGroupingType = charts.BarGroupingType.stacked;
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: charts.BarChart(
                seriesList,
                animate: animate,
                barGroupingType: barGroupingType,
                behaviors: legendList,
                animationDuration: Duration(seconds: 1),
                domainAxis: new charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(labelRotation: 270, labelOffsetFromAxisPx: 50, labelOffsetFromTickPx: 50)),
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
      List<TimeSeriesGraphData> tsDataList = List();
      values.forEach((value) {
        int ts = value[0];
        double val = 0;
        if (value[1] is double) val = value[1];
        if (value[1] is String) val = double.parse(value[1]);
        TimeSeriesGraphData tsData = TimeSeriesGraphData(DateTime.fromMillisecondsSinceEpoch(ts), val);
        tsDataList.add(tsData);
        // addDataToSeries(key, tsData);
        addDataListToSeries(key, tsDataList);
      });
      index++;
    });
  }
  List<TimeSeriesGraphData> timeSeriesListUpdate( List<TimeSeriesGraphData> tsData){
    double minute = (widget.widgetConfig.config.timewindow.realtime.timewindowMs*0.001)/60;
    List<TimeSeriesGraphData> resultList=List();
    DateTime historyDateTime=DateTime(
        DateTime.now().year,DateTime.now().month,DateTime.now().day
        ,DateTime.now().hour,DateTime.now().minute-int.parse(minute.round().toString())
        ,DateTime.now().second);

    tsData.forEach((element) {
      if(historyDateTime.isBefore(element.time)){
        resultList.add(element);
      }
    });
    return resultList;
  }

  void addDataListToSeries(String key, List<TimeSeriesGraphData> tsDataList) {
    int index = 0;
    int foundIndex = 0;
    seriesList.forEach((element) {
      if (element.id == key) foundIndex = index;
      index++;
    });
    seriesList[foundIndex].data.addAll(tsDataList);

    if (!seriesListData.containsKey(key)) {
      seriesListData[key] = List();
    }
    List<TimeSeriesGraphData> tempList;
    if(seriesList.length>0){
      tempList=seriesList[foundIndex].data;
    }
    else
      tempList=List();
    tempList.addAll(tsDataList);
    print(tsDataList.length.toString());
    tsDataList = timeSeriesListUpdate(tempList);
    seriesListData[key].addAll(tsDataList);
  }

  void addDataToSeries(String key, TimeSeriesGraphData tsData) {
    int index = 0;
    int foundIndex = 0;
    seriesList.forEach((element) {
      if (element.id == key) foundIndex = index;
      index++;
    });
    seriesList[foundIndex].data.add(tsData);

    if (!seriesListData.containsKey(key)) {
      seriesListData[key] = List();
    }
    seriesListData[key].add(tsData);
  }
}
