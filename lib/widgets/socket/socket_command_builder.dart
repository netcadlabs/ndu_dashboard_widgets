import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/alias_models.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/socket_models.dart';

class SocketCommandBuilder {
  //private fields
  AliasController _aliasController;
  DashboardDetail _dashboardDetail;

  //getters
  DashboardDetail get dashboardDetail => _dashboardDetail;

  AliasController get aliasController => _aliasController;

  SocketCommandBuilder(this._aliasController, this._dashboardDetail);

  Map<String, Datasources> _subscriptionDataSources = Map();

  Map<String, Datasources> get subscriptionDataSources => _subscriptionDataSources;

  int commandId = 1;

  Future<SubscriptionCommandResult> build() async {
    SubscriptionCommand subscriptionCommand = SubscriptionCommand();
    Map<String, String> widgetCmdIds = Map();

    try {
      // aliasController = AliasController(entityAliases: dashboardDetail.dashboardConfiguration.entityAliases);
      DashboardDetailConfiguration dashConfig = _dashboardDetail.dashboardConfiguration;
      if (dashConfig.widgets != null)
        for (var i = 0; i < dashConfig.widgets.length; i++) {
          WidgetConfig widgetConfig = dashConfig.widgets[i];
          if (widgetConfig.config == null || widgetConfig.config.datasources == null || widgetConfig.config.datasources.length == 0) continue;

          List<Datasources> dataSources = await resolveDataSourceList(widgetConfig.config.datasources);
          List<TsSubCmds> subCmdsList = await _calculateTimeSeriesSubscriptionCommands2(widgetConfig, dataSources, dashConfig.timewindow);
          if (subCmdsList != null && subCmdsList.length > 0) {
            subCmdsList.forEach((subCmd) {
              widgetCmdIds[commandId.toString()] = widgetConfig.id;
              subCmd.cmdId = commandId;
              _subscriptionDataSources["$commandId"] = subCmd.datasource;
              commandId++;
              if (subCmd.isAttribute) {
                AttrSubCmds attrSubCmds =
                    AttrSubCmds(entityType: subCmd.entityType, entityId: subCmd.entityId, keys: subCmd.keys, cmdId: subCmd.cmdId);
                subscriptionCommand.attrSubCmds.add(attrSubCmds);
              } else if (subCmd.endTs != null) {
                HistoryCmds historyCmds = HistoryCmds(
                    agg: subCmd.agg,
                    cmdId: subCmd.cmdId,
                    endTs: subCmd.endTs,
                    entityId: subCmd.entityId,
                    entityType: subCmd.entityType,
                    interval: subCmd.interval,
                    keys: subCmd.keys,
                    limit: subCmd.limit,
                    startTs: subCmd.startTs);
                subscriptionCommand.historyCmds.add(historyCmds);
              } else {
                subscriptionCommand.tsSubCmds.add(subCmd);
              }
            });
          }
        }
    } catch (err) {
      throw Exception('Build error : ${err.toString()}');
    }

    return SubscriptionCommandResult(subscriptionCommand, widgetCmdIds);
  }

  Future<List<Datasources>> resolveDataSourceList(List<Datasources> dataSourceList) async {
    List<Datasources> allDataSources = List();
    for (int i = 0; i < dataSourceList.length; i++) {
      try {
        List<Datasources> resolvedDataSourceList = await _aliasController.resolveDatasource(dataSourceList[i], false);
        //TODO - javascript koduna bak.. resolveDatasources(datasources)
        allDataSources.addAll(resolvedDataSourceList);
      } catch (err) {
        print(err);
      }
    }

    return allDataSources;
  }

  Future<List<TsSubCmds>> _calculateTimeSeriesSubscriptionCommands2(
      WidgetConfig widgetConfig, List<Datasources> dataSourceList, TimeWindow dashboardTimeWindow) async {
    if (dataSourceList == null) return null;

    List<TsSubCmds> list = List();
    dataSourceList.forEach((dataSource) {
      //TODO - TsSubCmds
      TsSubCmds tsSubCommands = TsSubCmds(entityId: dataSource.entityId, entityType: dataSource.entityType, datasource: dataSource);
      String label = "";
      dataSource.dataKeys.forEach((element) {
        label += '${element.name},';
        if (element.type == "attribute") {
          tsSubCommands.isAttribute = true;
        }
      });
      label = label.substring(0, label.length - 1);
      tsSubCommands.keys = label;
      if (widgetConfig.type != "latest") {
        if (!widgetConfig.config.useDashboardTimewindow)
          tsSubCommands = setTimeWindowProperties(widgetConfig.config.timewindow, tsSubCommands);
        else
          tsSubCommands = setTimeWindowProperties(dashboardTimeWindow, tsSubCommands);
      }
      list.add(tsSubCommands);
    });

    return list;
  }

  Future<List<AttrSubCmds>> calculateCommandForAliasId(String aliasId, String key) async {
    AliasInfo aliasInfo = await aliasController.getAliasInfo(aliasId);
    List<AttrSubCmds> list = List();
    if (aliasInfo == null || aliasInfo.resolvedEntities.length == 0) return list;

    if (aliasInfo.resolveMultiple) {
      aliasInfo.resolvedEntities.forEach((element) {
        AttrSubCmds attrSubCmds = AttrSubCmds();
        attrSubCmds.cmdId = commandId++;
        attrSubCmds.entityId = element.id;
        attrSubCmds.entityType = element.entityType;
        attrSubCmds.keys = key;
        list.add(attrSubCmds);
      });
    } else {
      var element = aliasInfo.resolvedEntities[0];
      AttrSubCmds attrSubCmds = AttrSubCmds();
      attrSubCmds.cmdId = commandId++;
      attrSubCmds.entityId = element.id;
      attrSubCmds.entityType = element.entityType;
      attrSubCmds.keys = key;
      list.add(attrSubCmds);
    }

    return list;
  }

  List<AttrSubCmds> calculateCommandForEntityInfo(EntityInfo element, String key) {
    List<AttrSubCmds> list = List();
    if (element == null) return list;

    AttrSubCmds attrSubCmds = AttrSubCmds();
    attrSubCmds.cmdId = commandId++;
    attrSubCmds.entityId = element.id;
    attrSubCmds.entityType = element.entityType;
    attrSubCmds.keys = key;
    list.add(attrSubCmds);

    return list;
  }

  List<TsSubCmds> calculateTsSubCmdsCommandForEntityInfo(EntityInfo element, String key) {
    List<TsSubCmds> list = List();
    if (element == null) return list;

    TsSubCmds tsSubCmds = TsSubCmds();
    tsSubCmds.cmdId = commandId++;
    tsSubCmds.entityId = element.id;
    tsSubCmds.entityType = element.entityType;
    tsSubCmds.keys = key;
    list.add(tsSubCmds);

    return list;
  }

  TsSubCmds setTimeProperties(WidgetConfigConfig widgetConfig, TsSubCmds tsSubCmds) {
    if (widgetConfig.timewindow != null && widgetConfig.timewindow.history != null) {
      tsSubCmds.interval = widgetConfig.timewindow.history.interval;
      // tsSubCmds.limit ?
      // tsSubCmds.timewindow ?
      if (widgetConfig.timewindow.history.fixedTimewindow != null)
        tsSubCmds.startTs = widgetConfig.timewindow.history.fixedTimewindow.startTimeMs * 1000;
      tsSubCmds.endTs = widgetConfig.timewindow.history.fixedTimewindow.endTimeMs * 1000;
    }
    if (widgetConfig.timewindow != null && widgetConfig.timewindow.realtime != null) {
      tsSubCmds.startTs = (DateTime.now().millisecondsSinceEpoch - widgetConfig.timewindow.realtime.timewindowMs);
      if (widgetConfig.timewindow.realtime.interval > 0) {
        tsSubCmds.interval = widgetConfig.timewindow.realtime.interval;

        tsSubCmds.timeWindow = widgetConfig.timewindow.realtime.timewindowMs + tsSubCmds.interval;
        tsSubCmds.limit = (tsSubCmds.timeWindow / tsSubCmds.interval).ceil();
      }
      // tsSubCmds.timeWindow = widgetConfig.timewindow.realtime.timewindowMs + tsSubCmds.interval;
      // tsSubCmds.limit = (tsSubCmds.timeWindow / tsSubCmds.interval) as int;
    }

    if (widgetConfig.timewindow.aggregation != null) {
      tsSubCmds.agg = widgetConfig.timewindow.aggregation.type;
      tsSubCmds.limit = 289;
      // widgetConfig.timewindow.aggregation.limit; // limit ?
    }

    return tsSubCmds;
  }

  TsSubCmds setTimeWindowProperties(TimeWindow timeWindow, TsSubCmds tsSubCommands) {
    if (timeWindow != null && timeWindow.history != null) {
      tsSubCommands.interval = timeWindow.history.interval;
      // tsSubCmds.limit ?
      // tsSubCmds.timewindow ?
      if (timeWindow.history.fixedTimewindow != null) {
        tsSubCommands.startTs = timeWindow.history.fixedTimewindow.startTimeMs;
        tsSubCommands.endTs = timeWindow.history.fixedTimewindow.endTimeMs;
      } else {
        tsSubCommands.startTs = timeWindow.history.fixedTimewindow.startTimeMs * 1000;
        tsSubCommands.endTs = timeWindow.history.fixedTimewindow.endTimeMs * 1000;
      }
    }
    if (timeWindow != null && timeWindow.realtime != null) {
      tsSubCommands.startTs = (DateTime.now().millisecondsSinceEpoch - timeWindow.realtime.timewindowMs);
      if (timeWindow.realtime.interval > 0) {
        tsSubCommands.interval = timeWindow.realtime.interval;

        tsSubCommands.timeWindow = timeWindow.realtime.timewindowMs + tsSubCommands.interval;
        tsSubCommands.limit = (tsSubCommands.timeWindow / tsSubCommands.interval).ceil();
      }
      // tsSubCmds.timeWindow = widgetConfig.timewindow.realtime.timewindowMs + tsSubCmds.interval;
      // tsSubCmds.limit = (tsSubCmds.timeWindow / tsSubCmds.interval) as int;
    }

    if (timeWindow.aggregation != null) {
      tsSubCommands.agg = timeWindow.aggregation.type;
      // tsSubCommands.limit = 289;
      // widgetConfig.timewindow.aggregation.limit; // limit ?
    }

    return tsSubCommands;
  }
}
