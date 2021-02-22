import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/datetime_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ndu_dashboard_widgets/widgets/charts/bar_chart.dart';
import 'package:ndu_dashboard_widgets/widgets/charts/chart_helper.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);


    return Container(
      height: 400,
      decoration: BoxDecoration(color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: BarChart(seriesList: seriesList,legendList: legendList,animate: animate)
            ),
          ),
        ],
      ),
    );
  }

  @override
  // ignore: must_call_super
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
        // addDataToSeries(key, tsData);
        addDataToSeriesList(key, tsDataList);
      });
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
      if (tempList.length > 0) seriesList[keyIndexInSeries].data.add(tempList[tempList.length - 1]);
      int limit;
      if (!widget.widgetConfig.config.useDashboardTimewindow) {
        limit = ChartHelper.limitCalculater(widget.widgetConfig.config.timewindow);
      } else {
        limit = ChartHelper.limitCalculater(widget.socketCommandBuilder.dashboardDetail.dashboardConfiguration.timewindow);
      }
      if (seriesList[keyIndexInSeries].data.length > limit) {
        seriesList[keyIndexInSeries].data.removeRange(0, seriesList[keyIndexInSeries].data.length - limit);
      }
    } else {
      if (tsData.length > 0) seriesList[keyIndexInSeries].data.add(tsData[0]);
    }
  }

}
