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

class ControlLedIndicator extends BaseDashboardWidget {
  ControlLedIndicator(WidgetConfig _widgetConfig, DashboardDetailConfiguration _dashboardDetailConfiguration, {Key key})
      : super(_widgetConfig, key: key, dashboardDetailConfiguration: _dashboardDetailConfiguration);

  @override
  _ControlLedIndicatorState createState() => _ControlLedIndicatorState();
}

class _ControlLedIndicatorState extends BaseDashboardState<ControlLedIndicator> {
  List<SocketData> allRawData = List();

  EntityType entityType = EntityType.DEVICE;
  AttributeScope attributeScope = AttributeScope.SHARED_SCOPE;
  String entityId = "";

  String title = "";

  Color currentSwitchValue = Colors.grey;

  String checkStatusMethod = "";
  String retrieveValueMethod = "";
  String valueKey = "";

  // Map methodParams = {};
  int requestTimeout = 5000;

  String parseValueFunction = "return data ? true : false;";

  bool isButtonReady = false;
  String errorText = "";

  Color activeColor = Colors.green;
  Color passiveColor = HexColor.darken(Colors.green, 50);

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

    if (settings.ledColor != null) {
      activeColor = HexColor.fromCss(settings.ledColor, defaultColor: activeColor);
      passiveColor = HexColor.darken(activeColor, 50);
    }

    currentSwitchValue = settings.initialValue ? activeColor : passiveColor;
    checkStatusMethod = settings.checkStatusMethod;
    retrieveValueMethod = settings.retrieveValueMethod;
    requestTimeout = settings.requestTimeout;
    if (settings.parseValueFunction != null && settings.parseValueFunction != "")
      parseValueFunction = settings.parseValueFunction;

    if (settings.performCheckStatus) {
      retrieveValueMethod = RETRIEVE_VALUE_METHOD_RPC;
    }

    valueKey = settings.valueAttribute;

    if (widget.widgetConfig.config.targetDeviceAliasIds != null &&
        widget.widgetConfig.config.targetDeviceAliasIds.length > 0) {
      String aliasId = widget.widgetConfig.config.targetDeviceAliasIds[0];
      widget.aliasController.getAliasInfo(aliasId).then((AliasInfo aliasInfo) {
        if (aliasInfo.resolvedEntities != null && aliasInfo.resolvedEntities.length > 0) {
          EntityInfo entityInfo = aliasInfo.resolvedEntities[0];

          setState(() {
            entityId = entityInfo.id;
            isButtonReady = true;
          });

          if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_RPC) {
            getRPCValue(checkStatusMethod, entityId, requestTimeout);
          } else {
            SubscriptionCommand subscriptionCommand;
            if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_ATTRIBUTE) {
              subscriptionCommand = SubscriptionCommand();
              subscriptionCommand.attrSubCmds =
                  widget.socketCommandBuilder.calculateCommandForEntityInfo(entityInfo, valueKey);
              subscriptionCommand.attrSubCmds.forEach((attrSubCmds) {
                context
                    .read<DashboardStateNotifier>()
                    .addSubscriptionId(widget.widgetConfig.id, attrSubCmds.cmdId.toString());
              });
            } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_TIMESERIES) {
              subscriptionCommand = SubscriptionCommand();
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

            if (subscriptionCommand != null) {
              String subscriptionCommandJson = jsonEncode(subscriptionCommand);
              widget.webSocketChannel.sink.add(subscriptionCommandJson);
            }
          }
        }
      }).catchError((err) {
        print("Can not resolve aliasId $aliasId");
      });
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
                      style: TextStyle(color: widget.color, fontSize: 18),
                    ),
                  ),
                ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(color: currentSwitchValue, shape: BoxShape.circle),
            ),
          ),
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

  @override
  void onData(SocketData graphData) {
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    if (graphData.datas.containsKey(valueKey)) {
      List telem = graphData.datas[valueKey][0];
      if (telem != null && telem.length > 1 && telem[1] != null) {
        evaluateServerData(telem[1].toString(), parseValueFunction).then((value) {
          // currentSwitchValue = value;
          setState(() {
            currentSwitchValue = value ? activeColor : passiveColor;
          });
        });
      }
    }
  }
}
