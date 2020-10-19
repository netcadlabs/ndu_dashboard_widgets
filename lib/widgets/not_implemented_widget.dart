import 'package:flutter/cupertino.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class NotImplementedWidget extends BaseDashboardWidget {
  final WidgetConfig widgetConfig;

  NotImplementedWidget(this.widgetConfig, {Key key}) : super(key: key);

  @override
  _NotImplementedWidgetState createState() => _NotImplementedWidgetState();
}

class _NotImplementedWidgetState
    extends BaseDashboardState<NotImplementedWidget> {
  @override
  void initState() {
    super.initState();
    super.setKey(widget.widgetConfig.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: EdgeInsets.all(5),
        height: 150,
        child: Column(
          children: [
            Text(
              "${widget.widgetConfig.config.title}",
              style: TextStyle(fontSize: 25),
            ),
            Text(
                "${widget.widgetConfig.bundleAlias} - ${widget.widgetConfig.typeAlias} not implemented"),
          ],
        ));
  }

  @override
  void onData(GraphData graphData) {

  }
}
