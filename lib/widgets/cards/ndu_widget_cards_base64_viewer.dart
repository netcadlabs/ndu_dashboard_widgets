import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'dart:typed_data';

// ignore: must_be_immutable
class Base64ViewerWidget extends BaseDashboardWidget {
  Base64ViewerWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _Base64ViewerWidgetState createState() => _Base64ViewerWidgetState();
}

class _Base64ViewerWidgetState extends BaseDashboardState<Base64ViewerWidget> {
  List<SocketData> allRawData = List();

  bool animate = false;

  String data = "";
  String valueAttribute = "CAMERA_CAPTURE";
  EntityType entityType = EntityType.DEVICE;
  AttributeScope attributeScope = AttributeScope.CLIENT_SCOPE;

  WidgetConfigConfig conf;
  bool isWaiting = true;

  @override
  void initState() {
    super.initState();

    conf = widget.widgetConfig.config;

    if (conf.targetDeviceAliasIds != null && conf.targetDeviceAliasIds.length > 0) {
      String aliasId = conf.targetDeviceAliasIds[0];
      widget.aliasController.getAliasInfo(aliasId).then((AliasInfo aliasInfo) {
        if (aliasInfo.resolvedEntities != null && aliasInfo.resolvedEntities.length > 0) {
          EntityInfo entityInfo = aliasInfo.resolvedEntities[0];
          entityId = entityInfo.id;
          getImageData();
        }
      });
    }

    if (conf.settings.entityAttributeType != null) {
      if (conf.settings.entityAttributeType == describeEnum(AttributeScope.SERVER_SCOPE)) {
        attributeScope = AttributeScope.SERVER_SCOPE;
      } else if (conf.settings.entityAttributeType == describeEnum(AttributeScope.SHARED_SCOPE)) {
        attributeScope = AttributeScope.SHARED_SCOPE;
      } else if (conf.settings.entityAttributeType == describeEnum(AttributeScope.CLIENT_SCOPE)) {
        attributeScope = AttributeScope.CLIENT_SCOPE;
      }
    }

    if (conf.settings.valueAttribute != null) {
      valueAttribute = conf.settings.valueAttribute;
    }
  }

  void getImageData() {
    getAttributeData(entityType, entityId, attributeScope, valueAttribute).then((res) {
      if (res.length > 0) {
        Map map = res[0];
        map.containsKey('value');
        setState(() {
          data = map['value'];
        });
      }
    }).catchError((Object err) {
      print(err);
    }).whenComplete(() {
      setState(() {
        isWaiting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // if (entityId != '') {}

    WidgetConfigConfig conf = widget.widgetConfig.config;

    Uint8List bytes;

    if (data != null && data != '') {
      bytes = base64.decode(data);
    }

    return Container(
      color: HexColor.fromCss(conf.backgroundColor),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            isWaiting
                ? CircularProgressIndicator()
                : (bytes != null
                    ? Image.memory(bytes)
                    : Container(
                        child: Text('No Data'),
                      ))
          ],
        ),
      ),
    );
  }

  @override
  void onData(SocketData graphData) {}
}
