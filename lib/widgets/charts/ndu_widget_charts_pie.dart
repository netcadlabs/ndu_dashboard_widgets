import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ndu_dashboard_widgets/widgets/charts/chart_helper.dart';
import 'package:ndu_dashboard_widgets/widgets/charts/charts.dart';
import 'package:ndu_dashboard_widgets/widgets/charts/timeseries_chart.dart';

class PieChart extends BaseDashboardWidget {
  PieChart(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends BaseDashboardState<PieChart> {
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
    /* if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      if (widget.widgetConfig.config.datasources[0].dataKeys != null && widget.widgetConfig.config.datasources[0].dataKeys.length > 0) {
        dataSourceLabel = widget.widgetConfig.config.datasources[0].dataKeys[0].label;
        dataSourceKey = widget.widgetConfig.config.datasources[0].dataKeys[0].name;
        widget.widgetConfig.config.datasources.forEach((dataSource) {
          dataSource.dataKeys.forEach((dataKey) {
            //addNewSeries(dataKey, [], dataSource.entityAliasId);
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
    }*/
  }

  addNewSeries(List<TimeSeriesGraphData> data) {
    seriesList?.clear();
    seriesList.add(new charts.Series<TimeSeriesGraphData, DateTime>(
      id: "Series list",
      domainFn: (TimeSeriesGraphData time, _) => time.time,
      measureFn: (TimeSeriesGraphData value, _) => value.value,
      data: data,
      labelAccessorFn: (TimeSeriesGraphData row, _) => '${row.displayName}: ${row.value}',
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
              child: charts.PieChart(seriesList, animate: animate, defaultRenderer: new charts.ArcRendererConfig(arcLength: 3 / 2 * 3.14)),
            ),
          );
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    TimeSeriesGraphData tsData;
    graphData.datas.forEach((key, values) {
      List<TimeSeriesGraphData> tsDataList = List();
      values.forEach((value) {
        int ts = value[0];
        double val = 0;
        if (value[1] is double) val = value[1];
        if (value[1] is String) val = double.parse(value[1]);
        tsData = TimeSeriesGraphData(DateTime.fromMillisecondsSinceEpoch(ts), val,
            displayName: key, subscriptionId: graphData.subscriptionId, aliasId: graphData.aliasId);
      });
      addDataToSeriesList(key, tsData);
    });
  }

  void addDataToSeriesList(String key, TimeSeriesGraphData tsData) {
    List<TimeSeriesGraphData> tempList;
    if (seriesList.length > 0) {
      for (int i = 0; i < seriesList[0].data.length; i++) {
        if (seriesList[0].data[i].displayName == key) {
          seriesList[0].data[i] = tsData;
          break;
        }
      }
      if (seriesList[0].data.length < 1) {
        seriesList[0].data.add(tsData);
      }
    }
    if (seriesList.length > 0) {
      tempList = seriesList[0].data;
    } else {
      tempList = List();
      tempList.add(tsData);
    }

    addNewSeries(tempList);
    //
    // if (tempList.length > 0) {
    //   setState(() {
    //     seriesList[0].data.add(tempList[tempList.length - 1]);
    //   });
    // }
  }
}
