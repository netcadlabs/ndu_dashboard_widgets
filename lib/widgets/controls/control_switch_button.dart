import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';

import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/telemetry_api.dart';
import 'package:ndu_api_client/util/constants.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/string_utils.dart';
import 'package:ndu_dashboard_widgets/util/toast.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:provider/provider.dart';

import '../socket_command_builder.dart';

class ControlSwitchButton extends BaseDashboardWidget {
  ControlSwitchButton(WidgetConfig _widgetConfig, DashboardDetailConfiguration _dashboardDetailConfiguration, {Key key})
      : super(_widgetConfig, key: key, dashboardDetailConfiguration: _dashboardDetailConfiguration);

  @override
  _ControlSwitchButtonState createState() => _ControlSwitchButtonState();
}

class _ControlSwitchButtonState extends BaseDashboardState<ControlSwitchButton> {
  List<SocketData> allRawData = List();

  EntityType entityType = EntityType.DEVICE;
  AttributeScope attributeScope = AttributeScope.SHARED_SCOPE;
  String entityId = "";

  String title = "";
  String buttonLabel = "";
  String infoText = "";
  bool isRaisedButton = true;

  Color buttonColor;
  Color buttonTextColor;

  bool currentSwitchValue = false;
  String getValueMethod = "";
  String retrieveValueMethod = "";
  String setValueMethod = "";
  String valueKey = "";

  // Map methodParams = {};
  bool showOnOffLabels = false;
  int requestTimeout = 5000;

  String parseValueFunction = "return data == 1 ? true : false;";
  String convertValueFunction = "return value;";

  String errorText = "";

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(Constants.baseUrl + "/api/dummy", hidden: true);

    var settings = widget.widgetConfig.config.settings;

    title = "${settings.title}";
    buttonLabel = "${settings.buttonText}";

    showOnOffLabels = settings.showOnOffLabels;
    currentSwitchValue = settings.initialValue;
    getValueMethod = settings.getValueMethod;
    retrieveValueMethod = settings.retrieveValueMethod;
    requestTimeout = settings.requestTimeout;
    if (settings.parseValueFunction != null && settings.parseValueFunction != "")
      parseValueFunction = settings.parseValueFunction;
    if (settings.convertValueFunction != null && settings.convertValueFunction != "")
      convertValueFunction = settings.convertValueFunction;

    valueKey = settings.valueKey;
    // _SET_ATTR ise attribute update yapacak, başka bir şey ise method adıdır bu
    setValueMethod = settings.setValueMethod;

    // if (widget.widgetConfig.config.settings.methodParams != null) {
    //   try {
    //     methodParams = jsonDecode(widget.widgetConfig.config.settings.methodParams);
    //   } catch (e) {
    //     print(e);
    //   }
    // }

    if (widget.widgetConfig.config.targetDeviceAliasIds != null &&
        widget.widgetConfig.config.targetDeviceAliasIds.length > 0) {
      startTargetDeviceAliasIdsSubscription(retrieveValueMethod, valueKey, requestTimeout: requestTimeout);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    buttonColor = Theme.of(context).primaryColor;
    buttonTextColor = Theme.of(context).accentColor;

    if (widget.widgetConfig.config.settings.styleButton != null) {
      if (!widget.widgetConfig.config.settings.styleButton.isPrimary) {
        buttonColor =
            HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.bgColor, defaultColor: buttonColor);
      }

      buttonTextColor =
          HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.textColor, defaultColor: buttonTextColor);
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
                      style: TextStyle(color: widget.color, fontSize: 18),
                    ),
                  ),
                ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Transform.scale(
              scale: 2.5,
              child: Switch(
                value: currentSwitchValue,
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
                onChanged: (setValueMethod == null || !isButtonReady) ? null : evaluateValue,
              ),
            ),
          ),
          showOnOffLabels
              ? Text(
                  currentSwitchValue ? "Açık" : "Kapalı",
                  style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 16),
                )
              : Container(),
          (errorText != "")
              ? Text(
                  errorText,
                  style: TextStyle(color: Colors.red, fontSize: 13),
                )
              : Container()
        ],
      ),
    );
  }

  Widget setUpButtonChild() {
    if (requestState == 0) {
      return new Text(buttonLabel);
    } else if (requestState == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void evaluateValue(bool switchValue) async {
    String functionContent = "function f(value){$convertValueFunction} f($switchValue)";
    flutterWebViewPlugin.evalJavascript(functionContent).then((evalResult) {
      if (evalResult == null || evalResult == "" || evalResult == "null") {
        return;
      }
      print(evalResult);
      if (evalResult.toLowerCase() == "true" || evalResult.toLowerCase() == "false") {
        sendRequest(switchValue, evalResult == "true");
      } else {
        evalResult = evalResult.trim();
        evalResult = StringUtils.trimLeading("\"", evalResult);
        evalResult = StringUtils.trimTrailing("\"", evalResult);
        sendRequest(switchValue, evalResult);
      }
    }).catchError((err) {
      print(err);
    });
  }

  void sendRequest(bool switchValue, dynamic evalResult) {
    setState(() {
      currentSwitchValue = switchValue;
      isButtonReady = false;
      requestState = 1;
    });

    if (setValueMethod == SET_VALUE_METHOD_SET_ATTRIBUTE) {
      sendAttributeKeyValue(entityType, entityId, attributeScope, valueKey, evalResult);
    } else {
      sendRPC2(entityId, setValueMethod, evalResult, requestTimeout, isOneWay: true);
    }
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(valueKey)) {
      List telem = graphData.datas[valueKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null) {
        evaluateServerData(telem[1].toString(), parseValueFunction).then((value) {
          // currentSwitchValue = value;
          setState(() {
            currentSwitchValue = value;
          });
        });
      }
    }
  }
}
