import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/telemetry_api.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/toast.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class ControlUpdateAttributes extends BaseDashboardWidget {
  ControlUpdateAttributes(WidgetConfig _widgetConfig, DashboardDetailConfiguration _dashboardDetailConfiguration,
      {Key key})
      : super(_widgetConfig, key: key, dashboardDetailConfiguration: _dashboardDetailConfiguration);

  @override
  _ControlUpdateAttributesWidgetState createState() => _ControlUpdateAttributesWidgetState();
}

class _ControlUpdateAttributesWidgetState extends BaseDashboardState<ControlUpdateAttributes> {
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

  Map entityParameters = {};

  @override
  void initState() {
    super.initState();

    title = "${widget.widgetConfig.config.settings.title}";
    buttonLabel = "${widget.widgetConfig.config.settings.buttonText}";

    if (widget.widgetConfig.config.settings.entityParameters != null) {
      try {
        entityParameters = jsonDecode(widget.widgetConfig.config.settings.entityParameters);
      } catch (e) {
        print(e);
      }
    }

    if (widget.widgetConfig.config.settings.entityAttributeType != null) {
      if (widget.widgetConfig.config.settings.entityAttributeType == describeEnum(AttributeScope.SERVER_SCOPE)) {
        attributeScope = AttributeScope.SERVER_SCOPE;
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
          RaisedButton(
            child: setUpButtonChild(),
            color: buttonColor,
            textColor: buttonTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(18.0),
              // side: BorderSide(color: Colors.black),
            ),
            onPressed: (entityParameters == null || !isButtonReady) ? null : sendAttribute,
          ),
          Text(
            "$infoText",
            style: TextStyle(color: HexColor.fromCss(widget.widgetConfig.config.color), fontSize: 15),
          )
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

  void sendAttribute() {
    setState(() {
      isButtonReady = false;
      requestState = 1;
    });

    sendAttributeData(entityType, entityId, attributeScope, entityParameters);
  }

  @override
  void onData(SocketData graphData) {}
}
