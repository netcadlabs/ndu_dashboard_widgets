import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class GraphWidget extends BaseDashboardWidget {
  final String dataKey;

  GraphWidget(this.dataKey, {Key key}) : super(key: key);

  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends BaseDashboardState<GraphWidget> {
  List<GraphData> allRawData = List();

  bool animate = false;

  @override
  void initState() {
    super.initState();
    super.setKey(widget.dataKey);
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

  charts.Series<GraphData, String> graphData() {
    final data = allRawData;

    return new charts.Series<GraphData, String>(
      id: 'Sales',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (GraphData data, _) => getTime(data.ts),
      measureFn: (GraphData data, _) => data.value,
      data: data,
    );
  }

  final DateFormat formatter = DateFormat('HH:mm:s');

  String getTime(int ts) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return formatter.format(dt);
  }

  @override
  void onData(GraphData graphData) {
    if (graphData == null) return;
    allRawData.add(graphData);
//    setState(() {});
  }
}
