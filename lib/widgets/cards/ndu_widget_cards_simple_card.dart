import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class SimpleCardWidget extends BaseDashboardWidget {
  SimpleCardWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _SimpleCardWidgetState createState() => _SimpleCardWidgetState();
}

class _SimpleCardWidgetState extends BaseDashboardState<SimpleCardWidget> {
  List<SocketData> allRawData = List();

  bool animate = false;

  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;

  @override
  void initState() {
    super.initState();

    if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      if (widget.widgetConfig.config.datasources[0].dataKeys != null &&
          widget.widgetConfig.config.datasources[0].dataKeys.length > 0) {
        dataSourceLabel = widget.widgetConfig.config.datasources[0].dataKeys[0].label;
        dataSourceKey = widget.widgetConfig.config.datasources[0].dataKeys[0].name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String formatted = data;
    if (widget.widgetConfig.config.decimals != null && widget.widgetConfig.config.decimals >= 0) {
      formatted = widget.convertNumberValue(double.parse(formatted), widget.widgetConfig.config.decimals);
    }

    String result = "$formatted ${widget.widgetConfig.config.units}";
    return Container(
      color: HexColor.fromCss(widget.widgetConfig.config.backgroundColor),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  "$dataSourceLabel",
                  style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            "$result",
            style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 25),
          )
        ],
      ),
    );
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(dataSourceKey)) {
      List telem = graphData.datas[dataSourceKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null) data = telem[1].toString();
    }
  }
}
