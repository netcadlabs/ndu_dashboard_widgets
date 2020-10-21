import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/telemetry_api.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/util/toast.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

class ControlUpdateAttributes extends BaseDashboardWidget {
  ControlUpdateAttributes(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

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

  Map entityParameters;

  bool isButtonReady = true;

  @override
  void initState() {
    super.initState();

    title = "${widget.widgetConfig.config.settings.title}";
    buttonLabel = "${widget.widgetConfig.config.settings.buttonText}";

    if (widget.widgetConfig.config.settings.styleButton != null) {
      if (!widget.widgetConfig.config.settings.styleButton.isPrimary) {
        buttonColor = HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.bgColor);
      }

      if (widget.widgetConfig.config.settings.styleButton.textColor != null) {
        buttonTextColor =
            HexColor.fromHex(widget.widgetConfig.config.settings.styleButton.textColor, defaultColor: buttonTextColor);
      }
    }

    if (widget.widgetConfig.config.settings.entityParameters != null) {
      try {
        entityParameters = jsonDecode(widget.widgetConfig.config.settings.entityParameters);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    buttonColor = Theme.of(context).primaryColor;
    buttonTextColor = Theme.of(context).accentColor;

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
            child: Text(buttonLabel),
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

  void sendAttribute() {
    isButtonReady = false;
    _telemetryApi.saveEntityAttributesV1(entityType, entityId, attributeScope, entityParameters).then((res) {
      if (res) {
        showToast(context, "İşlem başarıyla tamamlandı!");
      } else {
        showToast(context, "İşlem başarısız oldu!", isError: true);
      }
    }).catchError((Object err) {
      String errorMessage = err.toString();
      showToast(context, errorMessage);
      print(err);
    }).whenComplete(() {
      isButtonReady = true;
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
