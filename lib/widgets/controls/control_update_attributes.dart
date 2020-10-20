import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class ControlUpdateAttributes extends BaseDashboardWidget {
  ControlUpdateAttributes(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _ControlUpdateAttributesWidgetState createState() => _ControlUpdateAttributesWidgetState();
}

class _ControlUpdateAttributesWidgetState extends BaseDashboardState<ControlUpdateAttributes> {
  List<SocketData> allRawData = List();

  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;

  @override
  void initState() {
    super.initState();

    if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      int a = 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String formatted = data;
    if (widget.widgetConfig.config.decimals != null && widget.widgetConfig.config.decimals >= 0) {
      formatted = widget.convertNumberValue(double.parse(formatted), widget.widgetConfig.config.decimals);
    }

    String title = "${widget.widgetConfig.config.settings.title}";
    String buttonLabel = "${widget.widgetConfig.config.settings.buttonText}";
    String infoText = "";

    bool isRaisedButton = true;
    Color buttonColor = Theme.of(context).primaryColor;
    Color buttonTextColor = Theme.of(context).accentColor;

    if (widget.widgetConfig.config.settings.styleButton != null) {
      if (!widget.widgetConfig.config.settings.styleButton.isPrimary) {
        buttonColor = HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.bgColor);
      }

      if (widget.widgetConfig.config.settings.styleButton.textColor != null) {
        buttonTextColor =
            HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.textColor, defaultColor: buttonTextColor);
      }
    }

    return Container(
      child: Column(
        children: [
          title == ""
              ? Container()
              : Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(color: widget.color),
                    ),
                  ),
                ),
          RaisedButton(
            child: Text(buttonLabel),
            color: buttonColor,
            textColor: buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              // side: BorderSide(color: Colors.black),
            ),
            onPressed: () {
              print("basildi");
            },
          ),
          Text(
            "$infoText",
            style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 15),
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
