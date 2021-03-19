import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/util/icon_map.dart';
import 'package:ndu_dashboard_widgets/widgets/base_dash_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/no_data_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/alias_models.dart';

// ignore: must_be_immutable
class EntitiesTableWidget extends BaseDashboardWidget {
  EntitiesTableWidget(WidgetConfig _widgetConfig, {Key key}) : super(_widgetConfig, key: key);

  @override
  _EntitiesTableWidgetState createState() => _EntitiesTableWidgetState();
}

class _EntitiesTableWidgetState extends BaseDashboardState<EntitiesTableWidget> {
  static const int sortNameInt = 0;
  AliasInfo _aliasInfo;
  bool isAscending = true;
  int sortType = sortNameInt;
  Map tableTitleMap;
  Map<String, Map<String, dynamic>> rowMap = Map();
  WidgetConfigConfig conf;
  List<String> dataSourceLabel = List();
  List<String> dataSourceKey = List();
  List<String> rowMapKey = List();
  Settings settings;
  bool aliasInfoProgress = true;

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
    widget.aliasController.getAliasInfo(widget.widgetConfig.config.datasources[0].entityAliasId).then((aliasInfo) {
      aliasInfoProgress = false;
      _aliasInfo = aliasInfo;
      aliasInfo.resolvedEntities.forEach((element) {
        rowMapKey.add(element.name);
        rowMap.putIfAbsent(element.name, () => {});
        if (settings.displayEntityLabel) {
          rowMap[element.name]["displayEntityLabel"] = element.name;
        }
        if (settings.displayEntityType) {
          rowMap[element.name]["entityType"] = element.entityType;
        }
        if (widget.widgetConfig.config.actionCellButton) {
          rowMap[element.name]["actions"] = "actions";
        }
        //rowMap[element.name][element] = element.name.toString().replaceAll(" ", "") == "null" ? "" : element.name;
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * (rowMapKey.length / 12);
    height = (height < MediaQuery.of(context).size.height ? height : MediaQuery.of(context).size.height * 0.7);
    height = height < 250 ? 250 : height;

    super.build(context);
    return Container(
      height: height,
      child: Stack(children: [
        Container(
          color: Colors.white,
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
        ),
        Visibility(visible: rowMap.length > 0 ? false : (!aliasInfoProgress), child: NoDataWidget()),
        Visibility(
          visible: aliasInfoProgress,
          child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
        ),
      ]),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      FlatButton(
        padding: EdgeInsets.all(0),
        child: Container(
          child: Center(
            child: Text('${tableTitleMap["firstTitle"]}' + (sortType == sortNameInt ? (isAscending ? '↓' : '↑') : ''),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          width: 100,
          height: 56,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          alignment: Alignment.centerLeft,
        ));
      }
    });

    return list;
  }

  RelativeRect getWidgetGlobalRect(BuildContext context) {
    var offset = Offset.zero;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    return position;
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return InkWell(
      onDoubleTap: () {
        if (widget.widgetConfig.config.rowDoubleClick) {
          stateCallBack(widget.widgetConfig.config.actions.rowDoubleClick[0], widget.widgetConfig);
        }
      },
      onTap: () {
        if (widget.widgetConfig.config.rowClick) {
          stateCallBack(widget.widgetConfig.config.actions.rowClick[0], widget.widgetConfig);
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Center(child: Text("${rowMapKey[index]}")),
        width: 100,
        height: 52,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return InkWell(
      onDoubleTap: () {
        if (widget.widgetConfig.config.rowDoubleClick) {
          stateCallBack(widget.widgetConfig.config.actions.rowDoubleClick[0], widget.widgetConfig);
        }
      },
      onTap: () {
        if (widget.widgetConfig.config.rowClick) {
          stateCallBack(widget.widgetConfig.config.actions.rowClick[0], widget.widgetConfig);
        }
      },
      child: Row(
        children: rowList(index),
      ),
    );
  }

  List<Widget> popupList() {
    List<Widget> list = List();
    widget.widgetConfig.config.actions.actionCellButton.forEach((element) {
      list.add(PopupMenuItem(
          value: element,
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    IconMap.iconMap[element.icon],
                    color: Colors.grey,
                  ),
                  Container(margin: EdgeInsets.only(left: 8), child: Text('${element.name}')),
                ],
              ),
            ],
          )));
    });
    return list;
  }

  List<Widget> rowList(int index) {
    List<Widget> list = List();
    rowMap[rowMapKey[index]].forEach((key, value) {
      if (key == "actions") {
        list.add(Container(
          alignment: Alignment.centerRight,
          width: 40,
          height: 52,
          padding: EdgeInsets.only(left: 8, right: 8),
          child: widget.widgetConfig.config.actions.actionCellButton.length > 1
              ? PopupMenuButton(
                  onSelected: (RowClick rowClick) {
                    stateCallBack(rowClick, widget.widgetConfig);
                  },
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => <PopupMenuEntry<RowClick>>[...popupList()],
                )
              : InkWell(
                  onTap: () {
                    stateCallBack(widget.widgetConfig.config.actions.actionCellButton[0], _aliasInfo.resolvedEntities[index]);
                  },
                  child: Icon(
                    IconMap.iconMap[widget.widgetConfig.config.actions.actionCellButton[0].icon],
                    color: Colors.grey,
                  ),
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
    if (this.widget.socketCommandBuilder.subscriptionDataSources.containsKey(graphData.subscriptionId)) {
      if (!rowMapKey.contains(entityName)) {
        rowMapKey.add(entityName);
      }
      data.keys.forEach((element) {
        rowMap[entityName][element] = data[element].toString().replaceAll(" ", "") == "null" ? "" : data[element];
      });
    } else {
      print("${graphData.subscriptionId} datasource not found!");
    }
  }
}
