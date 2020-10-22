import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/rpc_api.dart';
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
  static const String RETRIEVE_VALUE_METHOD_DO_NOT_RETRIEVE = 'none';
  static const String RETRIEVE_VALUE_METHOD_RPC = 'rpc';
  static const String RETRIEVE_VALUE_METHOD_SUBSCRIBE_ATTRIBUTE = 'attribute';
  static const String RETRIEVE_VALUE_METHOD_SUBSCRIBE_TIMESERIES = 'timeseries';

  static const String SET_VALUE_METHOD_SET_ATTRIBUTE = "_SET_ATTR";

  RPCApi _RPCApi = RPCApi();
  TelemetryApi _telemetryApi = TelemetryApi();

  List<SocketData> allRawData = List();

  String dataSourceLabel;
  String dataSourceKey;

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
  String retrieveValueMethod;
  String setValueMethod;
  String valueKey;

  // Map methodParams = {};
  bool showOnOffLabels = false;
  int requestTimeout = 5000;

  String parseValueFunction = "return data == 1 ? true : false;";
  String convertValueFunction = "return value;";

  bool isButtonReady = false;

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  void dispose() {
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(Constants.baseUrl, hidden: true);

    // flutterWebViewPlugin.onStateChanged
    //     .listen((viewState) async {
    //       if (viewState.type == WebViewState.finishLoad) {
    //         int a = 3;
    //       }
    //     })
    //     .asFuture()
    //     .then((value) {
    //       print('Yuklendi');
    //     })
    //     .catchError((err) {
    //       print(err);
    //     });

    title = "${widget.widgetConfig.config.settings.title}";
    buttonLabel = "${widget.widgetConfig.config.settings.buttonText}";

    showOnOffLabels = widget.widgetConfig.config.settings.showOnOffLabels;
    currentSwitchValue = widget.widgetConfig.config.settings.initialValue;
    retrieveValueMethod = widget.widgetConfig.config.settings.retrieveValueMethod;
    requestTimeout = widget.widgetConfig.config.settings.requestTimeout;
    if (widget.widgetConfig.config.settings.parseValueFunction != null &&
        widget.widgetConfig.config.settings.parseValueFunction != "")
      parseValueFunction = widget.widgetConfig.config.settings.parseValueFunction;
    if (widget.widgetConfig.config.settings.convertValueFunction != null &&
        widget.widgetConfig.config.settings.convertValueFunction != "")
      convertValueFunction = widget.widgetConfig.config.settings.convertValueFunction;

    valueKey = widget.widgetConfig.config.settings.valueKey;
    // _SET_ATTR ise attribute update yapacak, başka bir şey ise method adıdır bu
    setValueMethod = widget.widgetConfig.config.settings.setValueMethod;

    // if (widget.widgetConfig.config.settings.methodParams != null) {
    //   try {
    //     methodParams = jsonDecode(widget.widgetConfig.config.settings.methodParams);
    //   } catch (e) {
    //     print(e);
    //   }
    // }

    if (widget.widgetConfig.config.targetDeviceAliasIds != null &&
        widget.widgetConfig.config.targetDeviceAliasIds.length > 0) {
      String aliasId = widget.widgetConfig.config.targetDeviceAliasIds[0];
      widget.aliasController.getAliasInfo(aliasId).then((AliasInfo aliasInfo) {
        if (aliasInfo.resolvedEntities != null && aliasInfo.resolvedEntities.length > 0) {
          EntityInfo entityInfo = aliasInfo.resolvedEntities[0];

          SubscriptionCommand subscriptionCommand = SubscriptionCommand();
          if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_DO_NOT_RETRIEVE) {
            print("retrieveValueMethod is none!");
          } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_RPC) {
            //TODO -
          } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_ATTRIBUTE) {
            subscriptionCommand.attrSubCmds =
                widget.socketCommandBuilder.calculateCommandForEntityInfo(entityInfo, valueKey);
            subscriptionCommand.attrSubCmds.forEach((attrSubCmds) {
              context
                  .read<DashboardStateNotifier>()
                  .addSubscriptionId(widget.widgetConfig.id, attrSubCmds.cmdId.toString());
            });
          } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_TIMESERIES) {
            subscriptionCommand.tsSubCmds =
                widget.socketCommandBuilder.calculateTsSubCmdsCommandForEntityInfo(entityInfo, valueKey);
            subscriptionCommand.tsSubCmds.forEach((tsSubCmds) {
              context
                  .read<DashboardStateNotifier>()
                  .addSubscriptionId(widget.widgetConfig.id, tsSubCmds.cmdId.toString());
            });
          } else {
            print("not supported retrieveValueMethod $retrieveValueMethod");
          }

          String subscriptionCommandJson = jsonEncode(subscriptionCommand);
          widget.webSocketChannel.sink.add(subscriptionCommandJson);
          setState(() {
            entityId = entityInfo.id;
            isButtonReady = true;
          });
        }
      });
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
                      style: TextStyle(color: widget.color),
                    ),
                  ),
                ),
          Switch(
            value: currentSwitchValue,
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
            onChanged: (setValueMethod == null || !isButtonReady) ? null : evaluateValue,
          ),
          showOnOffLabels
              ? Text(
                  currentSwitchValue ? "Açık" : "Kapalı",
                  style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 15),
                )
              : Container()
        ],
      ),
    );
  }

  int _requestState = 0;

  Widget setUpButtonChild() {
    if (_requestState == 0) {
      return new Text(buttonLabel);
    } else if (_requestState == 1) {
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
      _requestState = 1;
    });

    Future request;
    Map requestData = {};

    String convertedValue = "false";

    if (setValueMethod == SET_VALUE_METHOD_SET_ATTRIBUTE) {
      requestData[valueKey] = evalResult; // currentSwitchValue;
      request = _telemetryApi.saveEntityAttributesV1(entityType, entityId, attributeScope, requestData);
    } else {
      requestData["method"] = setValueMethod;
      requestData["params"] = jsonEncode(evalResult);
      requestData["timeout"] = requestTimeout;
      request = _RPCApi.handleDeviceRPCRequest(entityId, true, requestData);
    }

    request.then((res) {
      if (res) {
        showToast(context, "İstek başarıyla gönderildi");
      } else {
        showToast(context, "İstek başarısız oldu!", isError: true);
      }
    }).catchError((Object err) {
      showToast(context, "İstek başarısız oldu!", isError: true);
      String errorMessage = err.toString();
      print(err);
    }).whenComplete(() {
      setState(() {
        isButtonReady = true;
        _requestState = 0;
      });
    });
  }

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(valueKey)) {
      List telem = graphData.datas[valueKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null) {
        evaluateServerData(telem[1].toString()).then((value) {
          // currentSwitchValue = value;
          setState(() {
            currentSwitchValue = value;
          });
        });
      }
    }
  }

  Future<bool> evaluateServerData(dynamic data) async {
    String functionContent = "function f(data){$parseValueFunction} f($data)";
    String evalResult = await flutterWebViewPlugin.evalJavascript(functionContent);
    if (evalResult == null || evalResult == "" || evalResult == "null") {
      return false;
    }
    if (evalResult.toLowerCase() == "true" || evalResult.toLowerCase() == "false") {
      return evalResult == "true";
    }
    return false;
  }
}
