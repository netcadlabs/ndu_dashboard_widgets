import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class NduControlSlider extends BaseDashboardWidget {
  NduControlSlider(WidgetConfig _widgetConfig, DashboardDetailConfiguration _dashboardDetailConfiguration, {Key key})
      : super(_widgetConfig, key: key, dashboardDetailConfiguration: _dashboardDetailConfiguration);

  @override
  _NduControlSliderState createState() => _NduControlSliderState();
}

class _NduControlSliderState extends BaseDashboardState<NduControlSlider> {
  List<SocketData> allRawData = List();

  EntityType entityType = EntityType.DEVICE;
  AttributeScope attributeScope = AttributeScope.SHARED_SCOPE;

  String title = "";
  String infoText = "";

  String getValueMethod = "";
  String retrieveValueMethod = "";
  String setValueMethod = "";
  String valueKey = "";

  int requestTimeout = 5000;
  double _currentValue = 0;
  double _currentValueSlider = 0;

  // double _currentValueSlider = 0;
  bool useMapping = false;
  double minValue = 0;
  double maxValue = 100;
  double realMinValue = 0;
  double realMaxValue = 100;

  @override
  void dispose() {
    super.dispose();
  }

  WidgetConfigConfig conf;

  @override
  void initState() {
    super.initState();

    conf = widget.widgetConfig.config;

    title = conf.settings.title;
    if (conf.settings.initialValue != null) {
      _currentValue = double.parse(conf.settings.initialValue.toString());
    }
    requestTimeout = conf.settings.requestTimeout;

    getValueMethod = conf.settings.getValueMethod;
    setValueMethod = conf.settings.setValueMethod;
    retrieveValueMethod = conf.settings.retrieveValueMethod;
    valueKey = conf.settings.valueKey;
    useMapping = conf.settings.useMapping;

    realMinValue = double.parse(conf.settings.minValue.toString());
    realMaxValue = double.parse(conf.settings.maxValue.toString());
    if (useMapping) {
      minValue = 0;
      maxValue = 100;
    } else {
      minValue = realMinValue;
      maxValue = realMaxValue;
    }

    if (widget.widgetConfig.config.targetDeviceAliasIds != null &&
        widget.widgetConfig.config.targetDeviceAliasIds.length > 0) {
      startTargetDeviceAliasIdsSubscription(retrieveValueMethod, valueKey, requestTimeout: requestTimeout);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
          Row(
            children: [
              Text(minValue.toString()),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue[700],
                    inactiveTrackColor: Colors.blue[100],
                    trackShape: RoundedRectSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    thumbColor: Colors.blueAccent,
                    overlayColor: Colors.blue.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                    tickMarkShape: RoundSliderTickMarkShape(),
                    activeTickMarkColor: Colors.blue[700],
                    inactiveTickMarkColor: Colors.blue[100],
                    valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                    valueIndicatorColor: Colors.blueAccent,
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  child: Slider(
                    value: _currentValueSlider,
                    min: minValue,
                    max: maxValue,
                    divisions: 10,
                    label: '$_currentValueSlider',
                    onChanged: (value) {
                      setState(() {
                        _currentValueSlider = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (_currentValue == value) return;
                      sendRequest(value);
                    },
                  ),
                ),
              ),
              Text(maxValue.toString()),
            ],
          ),
          Text(
            "$infoText",
            style: TextStyle(color: HexColor.fromCss(conf.color), fontSize: 15),
          )
        ],
      ),
    );
  }

  void sendRequest(double value) {
    setState(() {
      isButtonReady = false;
      requestState = 1;
    });

    if (useMapping) {
      value = convertToRealValue(value, realMinValue, realMaxValue);
    }

    if (setValueMethod == SET_VALUE_METHOD_SET_ATTRIBUTE) {
      sendAttributeKeyValue(entityType, entityId, attributeScope, valueKey, value);
    } else if (setValueMethod == SET_VALUE_METHOD_SET_TIMESERIES) {
      // sendAttributeKeyValue(entityType, entityId, attributeScope, valueKey, value);
      //TODO - send telemetry support
    } else {
      sendRPC2(entityId, setValueMethod, value, requestTimeout, isOneWay: true);
    }
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(valueKey)) {
      List telemetry = graphData.datas[valueKey][0];
      if (telemetry != null && telemetry.length > 1 && telemetry[1] != null) {
        double resultData = 0;
        if (telemetry[1] is String) {
          resultData = double.parse(telemetry[1]);
        } else {
          resultData = telemetry[1];
        }

        setState(() {
          if (useMapping) {
            resultData = convertToMappedValue(resultData, realMinValue, realMaxValue);
          }
          if (resultData >= minValue && resultData <= maxValue) {
            _currentValue = resultData;
            _currentValueSlider = _currentValue;
          }
        });
      }
    }
  }

  convertToRealValue(double mappedValue, double min, double max) {
    var realMappedRate = min + (max - min) * mappedValue / 100;
    return realMappedRate;
  }

  convertToMappedValue(double realValue, double min, double max) {
    var realMappedRate = (realValue - min) / (max - min);
    var mappedRate = realMappedRate * 100;
    return mappedRate;
  }
}
