import 'package:flutter/cupertino.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class NotImplementedWidget extends BaseDashboardWidget {
  NotImplementedWidget(WidgetConfig widgetConfig, {Key key}) : super(widgetConfig, key: key);

  @override
  _NotImplementedWidgetState createState() => _NotImplementedWidgetState();
}

class _NotImplementedWidgetState extends BaseDashboardState<NotImplementedWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        padding: EdgeInsets.all(5),
        height: 150,
        child: Column(
          children: [
            Text("${widget.widgetConfig.bundleAlias} - ${widget.widgetConfig.typeAlias} not implemented"),
          ],
        ));
  }

  @override
  void onData(SocketData graphData) {}
}
