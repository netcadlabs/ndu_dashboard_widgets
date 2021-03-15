import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/icon_map.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/timeago/time_ago.dart';
class WidgetFrame extends StatefulWidget {
  final WidgetConfig widgetConfig;
  final BaseDashboardWidget child;
  final AliasController aliasController;
  final RowClickCallBack rowClickCallBack;

  WidgetFrame({Key key, this.child, this.widgetConfig, this.aliasController,this.rowClickCallBack}) : super(key: key);

  @override
  _WidgetFrameState createState() => _WidgetFrameState();
}

class _WidgetFrameState extends State<WidgetFrame> with TickerProviderStateMixin {
  bool isRefresh = false;
  AnimationController _controller;
  Color endColor;
  Color backgroundColor;
  DateTime lastTime =DateTime.now();
  Color color;

  @override
  void initState() {
    super.initState();
    endColor = HexColor.fromCss(widget.widgetConfig.config.backgroundColor);
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    widget.child.registerCallBack(func: () {
      lastTime=widget.child.lastDataTime;
      _controller.value = 1;
      _controller.isCompleted ? _controller.reverse() : _controller.forward();
    });
    widget.child.registerEntitiesTableCallBack(func: (RowClick rowClick){
      widget.rowClickCallBack(rowClick);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    backgroundColor = HexColor.fromCss(widget.widgetConfig.config.backgroundColor);
    color = HexColor.fromCss(widget.widgetConfig.config.color);
    Animatable<Color> background = TweenSequence<Color>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: backgroundColor==Colors.transparent?Colors.white:backgroundColor,
            end: backgroundColor.withOpacity(0.5),
          ),
        ),
      ],
    );
    if (widget.child.hasAnimation()) {
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return bodyWidget(background);
          });
    } else {
      return bodyWidget(background);
    }
  }

  Widget bodyWidget(var background) {
    final fifteenAgo = DateTime.now().subtract(Duration(seconds: 10));

    return Container(

      child: Container(
        decoration: BoxDecoration(
          color: background.evaluate(AlwaysStoppedAnimation(_controller.value)),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        //background.evaluate(AlwaysStoppedAnimation(_controller.value)),
        margin: EdgeInsets.symmetric(vertical: 2),
        //padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          children: [
            getTitleWidget(widget.widgetConfig.config),
            Container(
              child: widget.child,
            ),
            TimeAgo(lastTime),
          ],
        ),
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
                Container(
                    margin: EdgeInsets.all(4),
                    child: Icon(
                      IconMap.iconMap["${widget.widgetConfig.config.titleIcon}"],
                      color: HexColor.fromCss(widget.widgetConfig.config.iconColor),
                    )),
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

  getTimeSeriesData() {
    //api.getTimeseries();
  }
}
