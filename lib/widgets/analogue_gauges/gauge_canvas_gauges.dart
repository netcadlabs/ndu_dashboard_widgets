import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:ui';

// ignore: must_be_immutable
class GaugeCanvasGaugeWidget extends BaseDashboardWidget {
  final WidgetConfig widgetConfig;
  final DashboardDetailConfiguration dashboardConfiguration;

  GaugeCanvasGaugeWidget(this.widgetConfig, this.dashboardConfiguration, {Key key}) : super(widgetConfig, key: key);

  @override
  _GaugeCanvasGaugeWidgetState createState() => _GaugeCanvasGaugeWidgetState();
}

class _GaugeCanvasGaugeWidgetState extends BaseDashboardState<GaugeCanvasGaugeWidget> {
  bool animate = false;
  String backgroundImageUrl = "";
  String data = "0";
  String dataSourceLabel;
  String dataSourceKey;
  bool displayLabel = false;
  String labelPosition = "top";
  double labelFontSize = 16;
  double valueFontSize = 25;
  int maxValue;
  double value = 10;

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
  Widget build(BuildContext context) {
    super.build(context);
    List<GaugeRange> highlightsList = List();
    WidgetConfigConfig conf = widget.widgetConfig.config;

    String formatted = data;
    if (conf.decimals != null && conf.decimals >= 0) {
      formatted = widget.convertNumberValue(double.parse(formatted), conf.decimals);
    }
    if (conf.settings.highlights[0].from != 0) {
      GaugeRange range = GaugeRange(startValue: 0, endValue: conf.settings.highlights[0].from, color: HexColor.fromCss("#ede6e6"), startWidth: 12, endWidth: 12);
      highlightsList.add(range);
    }
    conf.settings.highlights.forEach((element) {
      GaugeRange range =
          GaugeRange(startValue: element.from, endValue: element.to, color: HexColor.fromCss(element.color), startWidth: 20, endWidth: 20);
      highlightsList.add(range);
    });
    Color rangeColor = HexColor.fromCss(conf.datasources[0].dataKeys[0].color);
    RegExp exp = new RegExp(r"/\$\{([^}]*)\}/g");
    maxValue = conf.settings.maxValue;

    labelFontSize = conf.settings.labelFontSize == 0 ? labelFontSize : conf.settings.labelFontSize;
    valueFontSize = conf.settings.valueFontSize == 0 ? valueFontSize : conf.settings.valueFontSize;

    labelPosition = conf.settings.labelPosition;
    displayLabel = conf.settings.displayLabel;
    if (labelPosition == "none") displayLabel = false;

    return Container(
      height: 300,
      child: SfRadialGauge(
          enableLoadingAnimation: true,
          title: GaugeTitle(text: '', textStyle: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          axes: <RadialAxis>[
            RadialAxis(minimum: 0, maximum: double.parse(maxValue.toString()), ranges: highlightsList, pointers: <GaugePointer>[
              NeedlePointer(value: value)
            ], annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Container(child: Text('$value', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
                  angle: 90,
                  positionFactor: 0.5)
            ])
          ]),
    );
  }

  @override
  void onData(SocketData graphData) async {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(dataSourceKey)) {
      List telem = graphData.datas[dataSourceKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null) data = telem[1].toString();
    }
    if (widget.widgetConfig.config.datasources[0].dataKeys[0].postFuncBody != null) {
      String result = await evaluateDeviceValue(data, widget.widgetConfig.config.datasources[0].dataKeys[0].postFuncBody);
      setState(() {
        value = double.parse(result.split(".")[0]);
      });
    } else {
      value = double.parse(data);
    }

    print(graphData.toString());
  }
}
