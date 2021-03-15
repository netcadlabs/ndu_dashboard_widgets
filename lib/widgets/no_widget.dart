import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class NoWidget extends BaseDashboardWidget {
  NoWidget(WidgetConfig widgetConfig) : super(widgetConfig);

  @override
  _StateNoWidget createState() => _StateNoWidget();
}

class _StateNoWidget extends State<NoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
