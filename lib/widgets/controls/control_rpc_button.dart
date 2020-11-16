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

  WidgetConfigConfig conf;

  @override
  void initState() {
    super.initState();

    conf = widget.widgetConfig.config;

    title = "${conf.settings.title}";
    buttonLabel = "${conf.settings.buttonText}";

    oneWayElseTwoWay = conf.settings.oneWayElseTwoWay;
    requestTimeout = conf.settings.requestTimeout;

    methodName = conf.settings.methodName;
    if (conf.settings.methodParams != null) {
      try {
        methodParams = jsonDecode(conf.settings.methodParams);
      } catch (e) {
        print(e);
      }
    }

    if (conf.targetDeviceAliasIds != null && conf.targetDeviceAliasIds.length > 0) {
      String aliasId = conf.targetDeviceAliasIds[0];
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

    if (conf.settings.styleButton != null) {
      if (!conf.settings.styleButton.isPrimary) {
        buttonColor = HexColor.fromHex(conf.settings.styleButton.bgColor, defaultColor: buttonColor);
      }

      buttonTextColor = HexColor.fromHex(conf.settings.styleButton.textColor, defaultColor: buttonTextColor);
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
            style: TextStyle(color: HexColor.fromCss(conf.color), fontSize: 15),
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
      print(err);
    }).whenComplete(() {
      setState(() {
        isButtonReady = true;
        _requestState = 0;
      });
    });
  }

  @override
  void onData(SocketData graphData) {}
}
