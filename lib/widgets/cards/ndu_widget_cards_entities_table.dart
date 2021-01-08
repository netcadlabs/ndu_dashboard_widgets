import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_api_client/models/entity_types.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/color_utils.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'dart:typed_data';

// ignore: must_be_immutable
class EntitiesTableWidget extends BaseDashboardWidget {
  EntitiesTableWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _EntitiesTableWidgetState createState() => _EntitiesTableWidgetState();
}

class _EntitiesTableWidgetState extends BaseDashboardState<EntitiesTableWidget> {
  static const int sortNameInt = 0;
  static const int sortStatus = 1;
  bool isAscending = true;
  int sortType = sortNameInt;
  Map tableTitleMap;
  Map<String,Map<String,dynamic>> rowMap = Map();
  WidgetConfigConfig conf;
  List<String> dataSourceLabel=List();
  List<String> dataSourceKey=List();
  List<String> rowMapKey=List();

  @override
  void initState() {
    super.initState();
    tableTitleMap = Map();
    tableTitleMap.putIfAbsent("firstTitle", () => widget.widgetConfig.config.settings.entityLabelColumnTitle);
    conf = widget.widgetConfig.config;
    if (widget.widgetConfig.config.datasources != null && widget.widgetConfig.config.datasources.length > 0) {
      if (widget.widgetConfig.config.datasources[0].dataKeys != null && widget.widgetConfig.config.datasources[0].dataKeys.length > 0) {
        widget.widgetConfig.config.datasources[0].dataKeys.forEach((element) {
          dataSourceLabel.add(element.label);
          dataSourceKey.add(element.name);
          tableTitleMap.putIfAbsent(element.name, () => element.label);
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: MediaQuery.of(context).size.width * 0.33,
        rightHandSideColumnWidth: 400,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: rowMap.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.7,
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      FlatButton(
        padding: EdgeInsets.all(0),
        child: Container(
          child: Text('${tableTitleMap["firstTitle"]}' + (sortType == sortNameInt ? (isAscending ? '↓' : '↑') : ''),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          width: 100,
          height: 56,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          sortType = sortNameInt;
          isAscending = !isAscending;
          sortLasUpdate(isAscending);
          setState(() {});
        },
      ),
      ..._getTitleItemWidget(),
    ];
  }

  List<Widget> _getTitleItemWidget() {
    List<Widget> list = List();
    tableTitleMap.forEach((key, value) {
      if (key != "firstTitle") {
        list.add(Container(
          child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          width: 100,
          height: 56,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ));
      }
    });

    return list;
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text("${rowMapKey[index]}"),
      width: 100,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
       ...rowList(index),
      ],
    );
  }

  List<Widget> rowList(int index) {
    List<Widget> list = List();
    dataSourceKey.forEach((element) {
      list.add( Container(
        child: RichText(
          overflow: TextOverflow.ellipsis,
          strutStyle: StrutStyle(fontSize: 12.0),
          text: TextSpan(style: TextStyle(color: Colors.black), text: "${rowMap[rowMapKey[index]][element]}"),
        ),
        width: 100,
        height: 52,
        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        alignment: Alignment.centerLeft,
      ));
    });

    //});

    return list;
  }

  void sortLasUpdate(bool isAscending) {
    /*list.sort((a, b) {
      if (isAscending) {
        return b.lastUpdateTs.compareTo(a.lastUpdateTs);
      } else
        return a.lastUpdateTs.compareTo(b.lastUpdateTs);
    });*/
  }

  @override
  void onData(SocketData graphData)async {
    Map<String,dynamic> data=Map();
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    for(int i =0;i<dataSourceKey.length;i++){
      if (graphData.datas.containsKey(dataSourceKey[i])) {
        List telem = graphData.datas[dataSourceKey[i]][0];
        if (telem != null && telem.length > 1 && telem[1] != null){
          data[dataSourceKey[i]]=telem[1].toString() ;
        }
      }
    }
    //evaluateDeviceValue();
    if (this.widget.socketCommandBuilder.subscriptionDataSources.containsKey(graphData.subscriptionId)) {
      rowMapKey.add(this.widget.socketCommandBuilder.subscriptionDataSources[graphData.subscriptionId].entityLabel);
      rowMap.putIfAbsent(this.widget.socketCommandBuilder.subscriptionDataSources[graphData.subscriptionId].entityLabel, () => data);
      print("${graphData.subscriptionId} - Name : ${this.widget.socketCommandBuilder.subscriptionDataSources[graphData.subscriptionId].name}");
    } else {
      print("${graphData.subscriptionId} datasource not found!");
    }
  }
}
