import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:ndu_dashboard_widgets/models/data_models.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class GraphWidget extends BaseDashboardWidget {
  GraphWidget(WidgetConfig widgetConfig, {Key key}) : super(widgetConfig, key: key);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends BaseDashboardState<GraphWidget> {
  List<SocketData> allRawData = List();

  bool animate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      height: 150,
      child: charts.BarChart(
        [graphData()],
        animate: animate,
      ),
    );
  }

  charts.Series<SocketData, String> graphData() {
    final data = allRawData;

    return new charts.Series<SocketData, String>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (SocketData data, _) => getTime(data.ts),
      measureFn: (SocketData data, _) => data.value,
      data: data,
    );
  }

  final DateFormat formatter = DateFormat('HH:mm:s');

  String getTime(int ts) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return formatter.format(dt);
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null) return;
    allRawData.add(graphData);
//    setState(() {});
  }
}
