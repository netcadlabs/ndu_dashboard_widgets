import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class StateChartsWidget extends BaseDashboardWidget {
  StateChartsWidget(WidgetConfig widgetConfig) : super(widgetConfig);

  @override
  _StateChartWidgetState createState() => _StateChartWidgetState();
}

class _StateChartWidgetState extends State<StateChartsWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Step line chart"));
  }
}
