import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';

class WidgetFrame extends StatelessWidget {
  final WidgetConfig widgetConfig;
  final Widget child;

  WidgetFrame({Key key, this.child, this.widgetConfig}) : super(key: key);

  Color backgroundColor;
  Color color;

  @override
  Widget build(BuildContext context) {
    backgroundColor = HexColor.fromCss(widgetConfig.config.backgroundColor);
    color = HexColor.fromCss(widgetConfig.config.color);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Column(
        children: [
          getTitleWidget(widgetConfig.config),
          Container(
            child: child,
          )
        ],
      ),
    );
  }

  Widget getTitleWidget(WidgetConfigConfig widgetConfigConfig) {
    String title = widgetConfigConfig.title;
    return widgetConfigConfig.showTitle
        ? Container(
            margin: EdgeInsets.only(top: 5),
            // padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    child: Text(
                      "$title",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
