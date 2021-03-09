import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';

// ignore: must_be_immutable
class EntitiesTableWidget extends BaseDashboardWidget {
  EntitiesTableWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _EntitiesTableWidgetState createState() => _EntitiesTableWidgetState();
}

class _EntitiesTableWidgetState extends BaseDashboardState<EntitiesTableWidget> {
  static const int sortNameInt = 0;
  bool isAscending = true;
  int sortType = sortNameInt;
  Map tableTitleMap;
  Map<String, Map<String, dynamic>> rowMap = Map();
  WidgetConfigConfig conf;
  List<String> dataSourceLabel = List();
  List<String> dataSourceKey = List();
  List<String> rowMapKey = List();
  Settings settings;

  @override
  void initState() {
    super.initState();
    tableTitleMap = Map();
    settings = widget.widgetConfig.config.settings;
    if (settings.defaultSortOrder != null) {
      tableTitleMap.putIfAbsent("firstTitle", () => (settings.defaultSortOrder == "entityName" ? "Entity Name" : settings.defaultSortOrder));
    } else {
      tableTitleMap.putIfAbsent("firstTitle", () => settings.entityLabelColumnTitle);
    }

    if (settings.displayEntityLabel) {
      if (settings.entityLabelColumnTitle != null) {
        tableTitleMap.putIfAbsent("displayEntityLabel", () => settings.entityLabelColumnTitle);
      } else {
        tableTitleMap.putIfAbsent("displayEntityLabel", () => "Entity Label");
      }
    }
    if (settings.displayEntityType) {
      tableTitleMap.putIfAbsent("entityType", () => "Entity type");
    }
    /*  if (settings.displayEntityName && settings.defaultSortOrder != null && settings.defaultSortOrder != "entityType") {

    }*/
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
    if (widget.widgetConfig.config.actionCellButton) {
      tableTitleMap.putIfAbsent("actions", () => "");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: MediaQuery.of(context).size.width * 0.33,
        rightHandSideColumnWidth: MediaQuery.of(context).size.width * (tableTitleMap.length / 4.5),
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        refreshIndicator: WaterDropHeader(),
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: rowMap.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black54,
          height: 1.0,
          thickness: 0.0,
        ),
      ),
      height: MediaQuery.of(context).size.height * (rowMapKey.length / 15),
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

  showActionsMenu() {
    showMenu(
      context: context,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(Icons.delete),
              Text("Delete"),
            ],
          ),
        )
      ],
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        if (widget.widgetConfig.config.rowClick) {
          print("row_click");
        }
      },
      child: Container(
        child: Center(child: Text("${rowMapKey[index]}")),
        width: 100,
        height: 52,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        if (widget.widgetConfig.config.rowClick) {
          print("row_click2");
        }
      },
      child: Row(
        children: rowList(index),
      ),
    );
  }

  List<Widget> rowList(int index) {
    List<Widget> list = List();
    rowMap[rowMapKey[index]].forEach((key, value) {
      if (key == "actions") {
        list.add(Container(
          width: 40,
          child: IconButton(
            icon: SvgPicture.asset("assets/menu.svg"),
            color: Colors.black,
            onPressed: showActionsMenu,
          ),
        ));
      } else {
        list.add(Container(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            strutStyle: StrutStyle(fontSize: 12.0),
            text: TextSpan(style: TextStyle(color: Colors.black), text: "$value"),
          ),
          width: 100,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ));
      }
    });
    /* dataSourceKey.forEach((element) {
      if (element != "firstTitle") {
        list.add(Container(
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
      }
    });
*/
    //});

    return list;
  }

  void sortLasUpdate(bool isAscending) {
    rowMapKey.sort((a, b) {
      if (isAscending) {
        return b.compareTo(a);
      } else {
        return a.compareTo(b);
      }
    });
  }

  @override
  void onData(SocketData graphData) async {
    Map<String, dynamic> data = Map();
    if (graphData == null || graphData.datas == null || graphData.datas.length == 0) return;
    for (int i = 0; i < dataSourceKey.length; i++) {
      if (graphData.datas.containsKey(dataSourceKey[i])) {
        List telem = graphData.datas[dataSourceKey[i]][0];
        if (telem != null && telem.length > 1 && telem[1] != null) {
          data[dataSourceKey[i]] = telem[1].toString();
        }
      }
    }
    String entityName = this.widget.socketCommandBuilder.subscriptionDataSources[graphData.subscriptionId].entityName;
    rowMap.putIfAbsent(entityName, () => {});
    if (settings.displayEntityLabel) {
      rowMap[entityName]["displayEntityLabel"] = entityName;
    }
    if (settings.displayEntityType) {
      rowMap[entityName]["entityType"] = graphData.entityType;
    }
    if (this.widget.socketCommandBuilder.subscriptionDataSources.containsKey(graphData.subscriptionId)) {
      rowMapKey.add(entityName);
      data.keys.forEach((element) {
        rowMap[entityName][element] = data[element].toString().replaceAll(" ", "") == "null" ? "" : data[element];
      });
    } else {
      print("${graphData.subscriptionId} datasource not found!");
    }
    if(widget.widgetConfig.config.actionCellButton){
      rowMap[entityName]["actions"] = "actions";
    }
  }
}
