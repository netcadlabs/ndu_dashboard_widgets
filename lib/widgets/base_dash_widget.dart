import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:provider/provider.dart';

abstract class BaseDashboardWidget extends StatefulWidget {
  const BaseDashboardWidget({Key key}) : super(key: key);

  Color convertColor(String colorValue) {
    if (colorValue.startsWith("#"))
      return HexColor.fromHex(colorValue);
    else if (colorValue.startsWith("rgb")) {

    }
    return Colors.white;
  }
//  void onData(GraphData graphData);
}

abstract class BaseDashboardState<T extends BaseDashboardWidget>
    extends State<T> {
  String _dataKey;

  void setKey(String dataKey) {
    _dataKey = dataKey;
//    context.watch<DashboardStateNotifier>().LATEST_DATA[_dataKey];
  }

  void onData(GraphData graphData);

  @override
  Widget build(BuildContext context) {
    if (context.watch<DashboardStateNotifier>().LATEST_DATA[_dataKey] != null) {
      var data = context.watch<DashboardStateNotifier>().LATEST_DATA[_dataKey];
      onData(data);
    }
  }
}
