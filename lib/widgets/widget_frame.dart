import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/icon_map.dart';

class WidgetFrame extends StatelessWidget {
  final WidgetConfig widgetConfig;
  final Widget child;
  final AliasController aliasController;
  WidgetFrame({Key key, this.child, this.widgetConfig, this.aliasController}) : super(key: key);
  bool isRefresh=false;
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
            margin: EdgeInsets.all(5),
            // padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
            Container(margin:EdgeInsets.all(4),child: Icon(IconMap.iconMap["${widgetConfig.config.titleIcon}"],color: HexColor.fromCss(widgetConfig.config.iconColor),)),
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
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
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
  getTimeSeriesData(){
    //api.getTimeseries();
  }
}
