import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ndu_api_client/assets_api.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/find_by_query_body.dart';
import 'package:ndu_api_client/rpc_api.dart';
import 'package:ndu_api_client/telemetry_api.dart';
import 'package:ndu_api_client/util/constants.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/dashboard_state_notifier.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/toast.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/alias_models.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/socket_command_builder.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/socket_models.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef RowClickCallBack = Function(RowClick, EntityInfo);

// ignore: must_be_immutable
abstract class BaseDashboardWidget extends StatefulWidget {
  WidgetConfig _widgetConfig;
  DashboardDetailConfiguration dashboardDetailConfiguration;
  AliasController aliasController;
  SocketCommandBuilder socketCommandBuilder;
  WebSocketChannel webSocketChannel;
  Map<SocketData, DataKeys> map = Map();
  DateTime lastDataTime;

  WidgetConfig get widgetConfig => _widgetConfig;

  Color backgroundColor = Colors.white;
  Color color = Colors.black;

  BaseDashboardWidget(this._widgetConfig, {Key key, this.dashboardDetailConfiguration}) : super(key: key) {
    if (widgetConfig.config != null) {
      if (widgetConfig.config.backgroundColor != null)
        backgroundColor = HexColor.fromCss(widgetConfig.config.backgroundColor, defaultColor: backgroundColor);
      if (widgetConfig.config.color != null) color = HexColor.fromCss(widgetConfig.config.color, defaultColor: color);
    }
  }

  String convertNumberValue(dynamic value, int decimal) {
    if (value is double) {
      double val = value.toDouble();
      // print("double $value  to ${val.toStringAsFixed(decimal)}");
      return val.toStringAsFixed(decimal);
    }
    if (value is int) {
      int val = value.toInt();
      // print("int $value  to ${val.toStringAsFixed(decimal)}");
      return val.toStringAsFixed(decimal);
    }
    return value.toString();
  }

  VoidCallback callBack;
  RowClickCallBack entitiesTableCallBack;

  void runCallBack() {
    if (callBack != null) callBack();
  }

  void runEntitiesTableCallBack(RowClick rowClick, EntityInfo config) {
    if (entitiesTableCallBack != null) entitiesTableCallBack(rowClick, config);
  }

  bool hasAnimation() {
    return false;
  }

  void registerCallBack({Function func}) {
    callBack = func;
  }

  void registerEntitiesTableCallBack({Function func}) {
    entitiesTableCallBack = func;
  }
}

abstract class BaseDashboardState<T extends BaseDashboardWidget> extends State<T> {
  final RPCApi rpcApi = RPCApi();
  final TelemetryApi telemetryApi = TelemetryApi();

  final String RETRIEVE_VALUE_METHOD_DO_NOT_RETRIEVE = 'none';
  final String RETRIEVE_VALUE_METHOD_RPC = 'rpc';
  final String RETRIEVE_VALUE_METHOD_SUBSCRIBE_ATTRIBUTE = 'attribute';
  final String RETRIEVE_VALUE_METHOD_SUBSCRIBE_TIMESERIES = 'timeseries';

  final String SET_VALUE_METHOD_SET_ATTRIBUTE = "_SET_ATTR";
  final String SET_VALUE_METHOD_SET_TIMESERIES = "_SET_TS"; //Not supported yet

  String entityId = "";

  bool isButtonReady = false;
  int requestState = 0;
  String errorText = "";

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  void onData(SocketData graphData);

  void notifyMe() {
    widget.runCallBack();
  }

  void stateCallBack(RowClick rowClick, var config) {
    widget.runEntitiesTableCallBack(rowClick, config);
  }

  @override
  void dispose() {
    widget.webSocketChannel.sink.close();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(Constants.baseUrl + "/api/dummy", hidden: true);
  }

  @override
  Widget build(BuildContext context) {
    List<SocketData> listData = context.watch<DashboardStateNotifier>().getWidgetData(widget.widgetConfig.id);
    if (listData.length > 0) {
      for (int i = 0; i < listData.length; i++) {
        var stream1 = getDataKeyElement(listData[i]);
        postFunc(stream1);
      }
    }
    return Container();
  }

  Stream<SocketData> getDataKeyElement(SocketData element) async* {
    if (widget.socketCommandBuilder != null && widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId] != null)
      for (int i = 0; i < widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys.length; i++) {
        if (widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].entityType != null) {
          element.entityType = widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].entityType;
        }

        if (widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys[i].postFuncBody != null) {
          element.dataKeys = widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys[i];
          yield element;
        } else {
          setState(() {
            onData(convertData(element));
          });
        }
      }
    else {
      onData(element);
    }
  }

  SocketData convertData(SocketData data) {
    List<DataKeys> keys = widget.socketCommandBuilder.subscriptionDataSources[data.subscriptionId].dataKeys;
    for (int i = 0; i < keys.length; i++) {
      if (data.datas.length > 0) {
        String tempValue = data.datas[keys[i].name] != null ? data.datas[keys[i].name][0][1] : "0";
        if (keys[i].decimals != null && keys[i].units != "" && tempValue is double) {
          tempValue = widget.convertNumberValue(double.parse(tempValue), keys[i].decimals);
        } else if (widget._widgetConfig.config.decimals != -1 && widget._widgetConfig.config.decimals != null) {
          double temp = double.tryParse(tempValue);
          if (temp != null) tempValue = widget.convertNumberValue(temp, widget._widgetConfig.config.decimals);
        }
        if (keys[i].units != null && keys[i].units != "") {
          tempValue = '$tempValue ${keys[i].units}';
        } else if (widget._widgetConfig.config.units != null) {
          tempValue = '$tempValue ${widget._widgetConfig.config.units}';
        }
        if (data.datas[keys[i].name] != null) {
          data.datas[keys[i].name][0][1] = tempValue;
        }
      }
    }
    return data;
  }

  Future<void> postFunc(Stream<SocketData> stream) async {
    await for (var value in stream) {
      if (value.datas != null && value.datas.length > 0 && value.datas[value.dataKeys.name]!=null) {
        String response = await evaluateDeviceValue(value.datas[value.dataKeys.name][0][1], value.dataKeys.postFuncBody);
        value.datas[value.dataKeys.name][0][1] = response;
        value = convertData(value);
        setState(() {
          onData(value);
        });
      }
    }
  }

  void setTimeAgo(DateTime lastData) {
    widget.lastDataTime = lastData;
  }

  void startTargetDeviceAliasIdsSubscription(String retrieveValueMethod, String valueKey, {int requestTimeout: 500}) {
    String aliasId = widget.widgetConfig.config.targetDeviceAliasIds[0];
    widget.aliasController.getAliasInfo(aliasId).then((AliasInfo aliasInfo) {
      if (aliasInfo.resolvedEntities != null && aliasInfo.resolvedEntities.length > 0) {
        EntityInfo entityInfo = aliasInfo.resolvedEntities[0];
        setState(() {
          entityId = entityInfo.id;
          isButtonReady = true;
        });

        SubscriptionCommand subscriptionCommand = SubscriptionCommand();
        if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_DO_NOT_RETRIEVE) {
          print("retrieveValueMethod is none!");
        } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_RPC) {
          getRPCValue(retrieveValueMethod, entityId, requestTimeout);
        } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_ATTRIBUTE) {
          subscriptionCommand.attrSubCmds = widget.socketCommandBuilder.calculateCommandForEntityInfo(entityInfo, valueKey);
          subscriptionCommand.attrSubCmds.forEach((attrSubCmds) {
            context.read<DashboardStateNotifier>().addSubscriptionId(widget.widgetConfig.id, attrSubCmds.cmdId.toString());
          });
        } else if (retrieveValueMethod == RETRIEVE_VALUE_METHOD_SUBSCRIBE_TIMESERIES) {
          subscriptionCommand.tsSubCmds = widget.socketCommandBuilder.calculateTsSubCmdsCommandForEntityInfo(entityInfo, valueKey);
          subscriptionCommand.tsSubCmds.forEach((tsSubCmds) {
            context.read<DashboardStateNotifier>().addSubscriptionId(widget.widgetConfig.id, tsSubCmds.cmdId.toString());
          });
        } else {
          print("not supported retrieveValueMethod : $retrieveValueMethod");
        }

        String subscriptionCommandJson = jsonEncode(subscriptionCommand);
        print("startTargetDeviceAliasIdsSubscription $subscriptionCommandJson");
        widget.webSocketChannel.sink.add(subscriptionCommandJson);
      }
    }).catchError((err) {
      print("Can not resolve aliasId $aliasId");
    });
  }

  void getRPCValue(String getValueMethod, String entityId, int requestTimeout) {
    Map requestData = {"method": getValueMethod, "params": null, "timeout": requestTimeout};
    rpcApi.handleTwoWayDeviceRPCRequest(entityId, requestData).then((reponse) {
      //TODO - cihazdan gelen veriyi yorumla ve currentSwitchValue değerini set et.
      setState(() {
        // currentSwitchValue = reponse //response parse et
        errorText = "";
      });
    }).catchError((err) {
      // if (err == 408)//timeout
      setState(() {
        errorText = "Cihaza erişilemiyor";
      });
    });
  }

  void sendRPC2(String entityId, String setValueMethod, dynamic value, int requestTimeout, {bool isOneWay: true}) {
    setState(() {
      isButtonReady = false;
      requestState = 1;
    });
    Map requestData = {"method": setValueMethod, "params": value, "timeout": requestTimeout};
    rpcApi.handleDeviceRPCRequest(entityId, isOneWay, requestData).then((res) {
      if (res) {
        showToast(context, "İstek başarıyla gönderildi(rpc)");
      } else {
        showToast(context, "İstek başarısız oldu!(rpc)", isError: true);
      }
    }).catchError((Object err) {
      showToast(context, "İstek başarısız oldu!(rpc)", isError: true);
      print(err);
    }).whenComplete(() {
      setState(() {
        isButtonReady = true;
        requestState = 0;
      });
    });
  }

  void sendAttributeKeyValue(EntityType entityType, String entityId, AttributeScope attributeScope, valueKey, value) {
    Map requestData = {};
    requestData[valueKey] = value; // currentSwitchValue;
    sendAttributeData(entityType, entityId, attributeScope, requestData);
  }

  void sendAttributeData(EntityType entityType, String entityId, AttributeScope attributeScope, Map requestData) {
    telemetryApi.saveEntityAttributesV1(entityType, entityId, attributeScope, requestData).then((res) {
      if (res) {
        showToast(context, "İstek başarıyla gönderildi(attribute)");
      } else {
        showToast(context, "İstek başarısız oldu!(attribute)", isError: true);
      }
    }).catchError((Object err) {
      showToast(context, "İstek başarısız oldu!(attribute)", isError: true);
      print(err);
    }).whenComplete(() {
      setState(() {
        isButtonReady = true;
        requestState = 0;
      });
    });
  }

  Future<List<dynamic>> getAttributeData(EntityType entityType, String entityId, AttributeScope attributeScope, String keys) {
    return telemetryApi.getEntityAttributes(entityType, entityId, attributeScope, keys);
  }

  Future<bool> evaluateServerData(dynamic data, String parseValueFunction) async {
    String functionContent = "function f(data){$parseValueFunction} f($data)";
    String evalResult = await flutterWebViewPlugin.evalJavascript(functionContent);
    if (evalResult == null || evalResult == "" || evalResult == "null") {
      return false;
    }
    if (evalResult.toLowerCase() == "true" || evalResult == '1') {
      return true;
    }
    return false;
  }

  Future<String> evaluateDeviceValue(dynamic value, String parseValueFunction) async {
    String functionContent = "function f(value){$parseValueFunction} f($value)";
    String evalResult = await flutterWebViewPlugin.evalJavascript(functionContent);
    if (evalResult == null || evalResult == "" || evalResult == "null") {
      return null;
    }
    return evalResult;
  }

  Future<String> evaluateDeviceValue2(dynamic value, String parseValueFunction) async {
    String functionContent = "function f(value){$parseValueFunction} f($value)";
    return flutterWebViewPlugin.evalJavascript(functionContent);
  }
}

enum AliasFilterType {
  singleEntity,
  entityList,
  entityName,
  stateEntity,
  assetType,
  deviceType,
  entityViewType,
  apiUsageState,
  relationsQuery,
  assetSearchQuery,
  deviceSearchQuery,
  entityViewSearchQuery
}
