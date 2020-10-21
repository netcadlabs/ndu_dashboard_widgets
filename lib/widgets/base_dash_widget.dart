import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:provider/provider.dart';

abstract class BaseDashboardWidget extends StatefulWidget {
  WidgetConfig _widgetConfig;
  DashboardDetailConfiguration dashboardDetailConfiguration;
  AliasController aliasController;

  WidgetConfig get widgetConfig => _widgetConfig;

  Color backgroundColor;
  Color color;

  BaseDashboardWidget(this._widgetConfig, {Key key, this.dashboardDetailConfiguration}) : super(key: key) {
    backgroundColor = HexColor.fromCss(widgetConfig.config.backgroundColor);
    color = HexColor.fromCss(widgetConfig.config.color);
  }

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
  void onData(SocketData graphData);

  @override
  Widget build(BuildContext context) {
    if (context.watch<DashboardStateNotifier>().latestData[widget.widgetConfig.id] != null) {
      SocketData data = context.watch<DashboardStateNotifier>().latestData[widget.widgetConfig.id];
      onData(data);
    }

    // if (Provider.of<DashboardStateNotifier>(context).latestData[widget.widgetConfig.id] != null) {
    //   SocketData data = Provider.of<DashboardStateNotifier>(context).latestData[widget.widgetConfig.id];
    //   onData(data);
    // }

    return Container();
  }
}
