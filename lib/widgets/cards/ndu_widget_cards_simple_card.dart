import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/widget_config.dart';

class SimpleCardWidget extends BaseDashboardWidget {
  final WidgetConfig _widgetConfig;

  SimpleCardWidget(this._widgetConfig, {Key key}) : super(key: key);

  @override
  _SimpleCardWidgetState createState() => _SimpleCardWidgetState();
}

class _SimpleCardWidgetState extends BaseDashboardState<SimpleCardWidget> {
  List<GraphData> allRawData = List();

  bool animate = false;

  int data = 0;
  String label = "Sıcaklık";

  @override
  void initState() {
    super.initState();
    super.setKey(widget._widgetConfig.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      height: 150,
      decoration: BoxDecoration(
          color: HexColor.fromCss(widget._widgetConfig.config.backgroundColor)),
      child: Center(
        child: Column(
          children: [
            Text(
              "${label}",
              style: TextStyle(
                  color: HexColor.fromCss(widget._widgetConfig.config.color)),
            ),
            Text(
              "${data.toString()}",
              style: TextStyle(
                  color: HexColor.fromCss(widget._widgetConfig.config.color)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onData(GraphData graphData) {
    if (graphData == null) return;
    data = graphData.value;
  }
}
