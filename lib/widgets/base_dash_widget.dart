import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:provider/provider.dart';

abstract class BaseDashboardWidget extends StatefulWidget {
  const BaseDashboardWidget({Key key}) : super(key: key);
}

abstract class BaseDashboardState<T extends BaseDashboardWidget> extends State<T> {
  String _dataKey;

  void setKey(String dataKey) {
    _dataKey = dataKey;
  }

  void onData(GraphData graphData);

  @override
  Widget build(BuildContext context) {
    if (context.watch<DashboardStateNotifier>().LATEST_DATA[_dataKey] != null) {
      GraphData data = context.watch<DashboardStateNotifier>().LATEST_DATA[_dataKey];
      onData(data);
    }

    return Container();
  }
}
