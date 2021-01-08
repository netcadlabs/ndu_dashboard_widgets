import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/entity_types.dart';
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

abstract class BaseDashboardWidget extends StatefulWidget {
  WidgetConfig _widgetConfig;
  DashboardDetailConfiguration dashboardDetailConfiguration;
  AliasController aliasController;
  SocketCommandBuilder socketCommandBuilder;
  WebSocketChannel webSocketChannel;
  Map<SocketData, DataKeys> map = Map();

  WidgetConfig get widgetConfig => _widgetConfig;

  // AliasController get aliasController => _aliasController;
  // set aliasController(AliasController _aliasController) {
  //   this._aliasController = _aliasController;
  // }

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

  StreamController controller = StreamController<SocketData>();

  void onData(SocketData graphData);

  @override
  void dispose() {
    super.dispose();
    flutterWebViewPlugin.dispose();
    controller.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flutterWebViewPlugin.close();
    flutterWebViewPlugin.launch(Constants.baseUrl + "/api/dummy", hidden: true);
    controller.stream.listen((event) {
      print(event);

      setState(() {
        onData(event);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<SocketData> listData = context.watch<DashboardStateNotifier>().getWidgetData(widget.widgetConfig.id);
    if (listData.length > 0) {
      listData.forEach((element) {
        calculate(element);
        //onData(element);
        // calculate(element).then((result) {
        //   onData(result);
        // });
      });
    }
    return Container();
  }

  void calculate(SocketData socketData) {
    // SocketData socketData =
    socketData.datas.forEach((key, List<dynamic> value) {
      String postFunction = getPostFunction(socketData.subscriptionId, key);
      if (postFunction != null) {
        value.forEach((element) {
          // element[1];
          //todo - eval
          evaluateDeviceValue2(element[1], postFunction).then((evalResult) {
            Map<String, List<dynamic>> map = Map();
            map[key] = List();

            if (evalResult == null || evalResult == "" || evalResult == "null") {
              map[key].add(element);
            } else {
              map[key].add([element[0], evalResult]);
            }

            SocketData copySocket = SocketData(0, socketData.ts, map, socketData.subscriptionId);
            controller.add(copySocket);
          });
        });
      } else {
        Map<String, List<dynamic>> map = Map();
        map[key] = List();
        map[key].add(value);
        SocketData copySocket = SocketData(0, socketData.ts, map, socketData.subscriptionId);
        controller.add(copySocket);
      }
    });
  }

  Stream<SocketData> calculate2(SocketData socketData) {
    // SocketData socketData =
    socketData.datas.forEach((key, List<dynamic> value) {
      String postFunction = getPostFunction(socketData.subscriptionId, key);
      if (postFunction != null) {
        value.forEach((element) {
          // element[1];
          //todo - eval
          evaluateDeviceValue(element[1], postFunction);
        });
      }
    });
  }

  String getPostFunction(String subscriptionId, String dataKey) {
    if (widget.socketCommandBuilder.subscriptionDataSources[subscriptionId].dataKeys != null) {
      for (int i = 0; i < widget.socketCommandBuilder.subscriptionDataSources[subscriptionId].dataKeys.length; i++) {
        var element = widget.socketCommandBuilder.subscriptionDataSources[subscriptionId].dataKeys[i];
        if (element.name == dataKey && element.postFuncBody != null) return element.postFuncBody;
      }
    }

    return null;
  }

  // Stream<SocketData> test(SocketData element) async* {
  //   for (int i = 0; i < widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys.length; i++) {
  //     if (widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys[i].postFuncBody != null) {
  //         element.dataKeys=widget.socketCommandBuilder.subscriptionDataSources[element.subscriptionId].dataKeys[i];
  //        yield element;
  //     }
  //   }
  // }

  // Future<void> sumStream(Stream<SocketData> stream) async {
  //   var sum = 0;
  //   await for (var value in stream) {
  //     print("asd");
  //     String response = await evaluateDeviceValue(value.datas[value.dataKeys.name][0][1],value.dataKeys.postFuncBody);
  //     value.datas[value.dataKeys.name][1]=response;
  //     onData(value);
  //   }
  // }

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
      String errorMessage = err.toString();
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
    if (evalResult.toLowerCase() == "true" || evalResult.toLowerCase() == "false") {
      return evalResult == "true";
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
