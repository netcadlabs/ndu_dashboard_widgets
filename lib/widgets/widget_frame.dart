import 'package:flutter/cupertino.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';

class WidgetFrame extends StatelessWidget {
  final WidgetConfig widgetConfig;
  final Widget child;

  WidgetFrame({Key key, this.child, this.widgetConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = widgetConfig.config.title;

    Color backgroundColor = HexColor.fromCss(widgetConfig.config.backgroundColor);
    return Container(
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          widgetConfig.config.showTitle
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "$title",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : Container(),
          Container(
            child: child,
          )
        ],
      ),
    );
  }
}
