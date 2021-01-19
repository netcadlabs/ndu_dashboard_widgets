import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

// ignore: must_be_immutable
class SimpleCardWidget extends BaseDashboardWidget {
  SimpleCardWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);
  @override
  bool hasAnimation(){
    return true;
  }

  @override
  _SimpleCardWidgetState createState() => _SimpleCardWidgetState();
}

class _SimpleCardWidgetState extends BaseDashboardState<SimpleCardWidget> with TickerProviderStateMixin {
  List<SocketData> allRawData = List();

  bool animate = false;

  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;
  bool displayLabel = false;
  String labelPosition = "top";
  double labelFontSize = 16;
  double valueFontSize = 25;
  Color textColor;
  @override
  void initState() {
    super.initState();
    if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      if (widget.widgetConfig.config.datasources[0].dataKeys != null && widget.widgetConfig.config.datasources[0].dataKeys.length > 0) {
        dataSourceLabel = widget.widgetConfig.config.datasources[0].dataKeys[0].label;
        dataSourceKey = widget.widgetConfig.config.datasources[0].dataKeys[0].name;
      }
    }
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    WidgetConfigConfig conf = widget.widgetConfig.config;

    String formatted = data;
    /*if (conf.decimals != null && conf.decimals >= 0) {
      formatted = widget.convertNumberValue(double.parse(formatted), conf.decimals);
    }
*/
    textColor = HexColor.fromCss(conf.color);

    labelFontSize = conf.settings.labelFontSize == 0 ? labelFontSize : conf.settings.labelFontSize;
    valueFontSize = conf.settings.valueFontSize == 0 ? valueFontSize : conf.settings.valueFontSize;

    labelPosition = conf.settings.labelPosition;
    displayLabel = conf.settings.displayLabel;
    if (labelPosition == "none") displayLabel = false;

    return Container(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  labelPosition == "top" ? getLabel() : Container(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "$formatted",
                    style: TextStyle(color: textColor, fontSize: valueFontSize),
                  ),
                  labelPosition == "bottom"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            getLabel(),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          );
  }

  Widget getLabel() {
    return displayLabel
        ? Text(
            "$dataSourceLabel",
            style: TextStyle(color: textColor, fontSize: labelFontSize),
          )
        : Container();
  }

  @override
  void onData(SocketData graphData) {
    //super.onData(graphData);
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(dataSourceKey)) {
      List telem = graphData.datas[dataSourceKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null){
        var date = new DateTime.fromMillisecondsSinceEpoch(telem[0],isUtc: false);
        data = telem[1].toString();
        setTimeAgo(date);
        super.notifyMe();
      }
    }
  }
  @override
  void setTimeAgo(DateTime lastData) {
    super.setTimeAgo(lastData);
  }
}
