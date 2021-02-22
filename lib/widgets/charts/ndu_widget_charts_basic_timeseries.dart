import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ndu_dashboard_widgets/widgets/charts/chart_helper.dart';
import 'package:ndu_dashboard_widgets/widgets/charts/timeseries_chart.dart';

class BasicTimeseriesChart extends BaseDashboardWidget {
  BasicTimeseriesChart(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _BasicTimeseriesChartWidgetState createState() => _BasicTimeseriesChartWidgetState();
}

class _BasicTimeseriesChartWidgetState extends BaseDashboardState<BasicTimeseriesChart> {
  List<SocketData> allRawData = List();

  List<charts.Series<TimeSeriesGraphData, DateTime>> seriesList = List();

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

  fetchChartData() {
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
        widget.widgetConfig.config.datasources.forEach((dataSource) {
          dataSource.dataKeys.forEach((dataKey) {
            addNewSeries(dataKey, []);
            legendList.add(charts.SeriesLegend(
                position: position,
                outsideJustification: charts.OutsideJustification.start,
                horizontalFirst: false,
                desiredMaxRows: 2,
                cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                entryTextStyle: charts.TextStyleSpec(color: charts.Color.fromHex(code: dataKey.color), fontFamily: 'Georgia', fontSize: 9)));
          });
        });
      }
    }
  }

  addNewSeries(DataKeys dataKey, List<TimeSeriesGraphData> data) {
    seriesList.add(new charts.Series<TimeSeriesGraphData, DateTime>(
      id: dataKey.name,
      displayName: dataKey.label,
      colorFn: (_, __) => charts.Color.fromHex(code: dataKey.color),
      seriesCategory: dataKey.color,
      domainFn: (TimeSeriesGraphData time, _) => time.time,
      measureFn: (TimeSeriesGraphData value, _) => value.value,
      data: data,
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return seriesList.length < 1
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: 400,
            decoration: BoxDecoration(color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor)),
            child: Container(
              padding: EdgeInsets.all(10),
              child: TimeSeriesChart(seriesList: seriesList, animate: animate, legendList: legendList),
            ),
          );
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;

    graphData.datas.forEach((key, values) {
      List<TimeSeriesGraphData> tsDataList = List();
      values.forEach((value) {
        int ts = value[0];
        double val = 0;
        if (value[1] is double) val = value[1];
        if (value[1] is String) val = double.parse(value[1]);
        TimeSeriesGraphData tsData = TimeSeriesGraphData(DateTime.fromMillisecondsSinceEpoch(ts), val);
        tsDataList.add(tsData);
      });
      addDataToSeriesList(key, tsDataList);
    });
  }

  void addDataToSeriesList(String key, List<TimeSeriesGraphData> tsData) {
    int index = 0;
    int keyIndexInSeries = -1;

    seriesList.forEach((element) {
      if (element.id == key) {
        keyIndexInSeries = index;
      }
      index++;
    });

    List<TimeSeriesGraphData> tempList;

    if (seriesList.length > 0) {
      tempList = seriesList[keyIndexInSeries].data;
    } else {
      tempList = List();
    }
    tempList.addAll(tsData);
    tempList = ChartHelper.timeSeriesListUpdate(tempList, widget.widgetConfig.config);

    if (keyIndexInSeries > -1) {
      if (tempList.length > 0) {
        seriesList[keyIndexInSeries].data.add(tempList[tempList.length - 1]);
        int limit;
        if (!widget.widgetConfig.config.useDashboardTimewindow) {
          limit = ChartHelper.limitCalculater(widget.widgetConfig.config.timewindow);
        } else {
          limit = ChartHelper.limitCalculater(widget.socketCommandBuilder.dashboardDetail.dashboardConfiguration.timewindow);
        }
        if (seriesList[keyIndexInSeries].data.length > limit) {
          seriesList[keyIndexInSeries].data.removeRange(0, seriesList[keyIndexInSeries].data.length - limit);
        }
      }
    } else {
      if (tsData.length > 0) seriesList[keyIndexInSeries].data.add(tsData[0]);
    }
  }
}
