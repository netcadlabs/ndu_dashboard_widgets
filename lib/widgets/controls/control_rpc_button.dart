import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/rpc_api.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/toast.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class ControlRPCButton extends BaseDashboardWidget {
  ControlRPCButton(WidgetConfig _widgetConfig, DashboardDetailConfiguration _dashboardDetailConfiguration, {Key key})
      : super(_widgetConfig, key: key, dashboardDetailConfiguration: _dashboardDetailConfiguration);

  @override
  _ControlRPCButtonState createState() => _ControlRPCButtonState();
}

class _ControlRPCButtonState extends BaseDashboardState<ControlRPCButton> {
  RPCApi _RPCApi = RPCApi();

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

  String methodName;
  Map methodParams = {};
  bool oneWayElseTwoWay = true;
  int requestTimeout = 5000;

  bool isButtonReady = false;

  @override
  void initState() {
    super.initState();

    title = "${widget.widgetConfig.config.settings.title}";
    buttonLabel = "${widget.widgetConfig.config.settings.buttonText}";

    oneWayElseTwoWay = widget.widgetConfig.config.settings.oneWayElseTwoWay;
    requestTimeout = widget.widgetConfig.config.settings.requestTimeout;

    methodName = widget.widgetConfig.config.settings.methodName;
    if (widget.widgetConfig.config.settings.methodParams != null) {
      try {
        methodParams = jsonDecode(widget.widgetConfig.config.settings.methodParams);
      } catch (e) {
        print(e);
      }
    }

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
          MaterialButton(
            child: setUpButtonChild(),
            color: buttonColor,
            textColor: buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              // side: BorderSide(color: Colors.black),
            ),
            onPressed: (methodName == null || !isButtonReady) ? null : sendRPC,
          ),
          Text(
            "$infoText",
            style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 15),
          )
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

  void sendRPC() {
    setState(() {
      isButtonReady = false;
      _requestState = 1;
    });
    Map requestData = {"method": methodName, "params": jsonEncode(methodParams), "timeout": requestTimeout};
    _RPCApi.handleDeviceRPCRequest(entityId, oneWayElseTwoWay, requestData).then((res) {
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
    int a = 4;
    // if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    // if (graphData.datas.containsKey(dataSourceKey)) {
    //   List telem = graphData.datas[dataSourceKey][0];
    //   if (telem != null && telem.length > 1 && telem[1] != null) data = telem[1].toString();
    // }
  }
}
