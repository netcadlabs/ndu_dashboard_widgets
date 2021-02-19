import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class StateChartWidget extends BaseDashboardWidget {
  StateChartWidget(WidgetConfig widgetConfig) : super(widgetConfig);

  @override
  _StateChartWidgetStates createState() => _StateChartWidgetStates();
}

class _StateChartWidgetStates extends State<StateChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(height: 100,child: Text("State Chart Widget"),);
  }
}
