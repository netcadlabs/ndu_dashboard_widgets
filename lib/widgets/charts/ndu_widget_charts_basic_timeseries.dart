import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
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
  Map<String, List<dynamic>> seriesListData = Map<String, List<dynamic>>();
  List<charts.SeriesLegend> legendList = List();
  bool animate = false;

  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  fetchChartData(){
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
            addNewSeriest(dataKey);
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

  }
  addNewSeriest(DataKeys dataKey){
    seriesList.add(new charts.Series<TimeSeriesGraphData, DateTime>(
      id: dataKey.name,
      displayName: dataKey.label,
      colorFn: (_, __) => charts.Color.fromHex(code: dataKey.color),
      domainFn: (TimeSeriesGraphData sales, _) => sales.time,
      measureFn: (TimeSeriesGraphData sales, _) => sales.value,
      data: [],
    ));
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return seriesList.length<1
        ?Center(
        child: CircularProgressIndicator())
        :Container(
      height: 400,
      decoration: BoxDecoration(color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor)),
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
    );
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;

    int index = 0;
    graphData.datas.forEach((key, values) {
      List<TimeSeriesGraphData> tsDataList=List();
      values.forEach((value) {
        int ts = value[0];
        double val = 0;
        if (value[1] is double) val = value[1];
        if (value[1] is String) val = double.parse(value[1]);
        TimeSeriesGraphData tsData = TimeSeriesGraphData(DateTime.fromMillisecondsSinceEpoch(ts), val);
        tsDataList.add(tsData);
      });
      addDataToSeriesList(key,tsDataList);
      index++;
    });

  }
  void addDataToSeriesList(String key, List<TimeSeriesGraphData> tsData) {
    int index = 0;
    int foundIndex = 0;

    seriesList.forEach((element) {
      if (element.id == key) foundIndex = index;
      index++;
    });
    List<TimeSeriesGraphData> tempList;
    if(seriesList.length>0){
      tempList=seriesList[foundIndex].data;
    }
    else
      tempList=List();
    tempList.addAll(tsData);
    print(tsData.length.toString());
    tsData = timeSeriesListUpdate(tempList);
    seriesList[foundIndex].data.clear();
    seriesList[foundIndex].data.addAll(tsData);


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
  void addDataToSeries(String key, TimeSeriesGraphData tsData) {
    int index = 0;
    int foundIndex = 0;
    seriesList.forEach((element) {
      if (element.id == key) foundIndex = index;
      index++;
    });
    seriesList[foundIndex].data.add(tsData);

  }
}
