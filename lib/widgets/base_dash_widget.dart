import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:provider/provider.dart';

abstract class BaseDashboardWidget extends StatefulWidget {
  WidgetConfig _widgetConfig;

  WidgetConfig get widgetConfig => _widgetConfig;

  BaseDashboardWidget(
    this._widgetConfig, {
    Key key,
  }) : super(key: key);

  String convertNumberValue(dynamic value, int decimal) {
    if (value is double) {
      double val = value.toDouble();
      print("dobule $value  to ${val.toStringAsFixed(decimal)}");
      return val.toStringAsFixed(decimal);
    }
    if (value is int) {
      int val = value.toInt();
      print("int $value  to ${val.toStringAsFixed(decimal)}");
      return val.toStringAsFixed(decimal);
    }
    return value.toString();
  }
}

abstract class BaseDashboardState<T extends BaseDashboardWidget> extends State<T> {
  void onData(GraphData graphData);

  @override
  Widget build(BuildContext context) {
    if (context.watch<DashboardStateNotifier>().LATEST_DATA[widget.widgetConfig.id] != null) {
      GraphData data = context.watch<DashboardStateNotifier>().LATEST_DATA[widget.widgetConfig.id];
      onData(data);
    }

    return Container();
  }
}
