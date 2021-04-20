import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/util/widget_helper_list.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/alias_models.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/socket_models.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/state_controller.dart';

class SocketCommandBuilder {
  //private fields
  AliasController _aliasController;
  StateController _stateController;
  DashboardDetail _dashboardDetail;

  //getters
  DashboardDetail get dashboardDetail => _dashboardDetail;

  AliasController get aliasController => _aliasController;

  StateController get stateController => _stateController;

  SocketCommandBuilder(this._aliasController, this._dashboardDetail,this._stateController);

  Map<String, Datasources> _subscriptionDataSources = Map();

  Map<String, Datasources> get subscriptionDataSources => _subscriptionDataSources;

  int commandId = 1;
  void setStateController(StateController controller){
    this._stateController=controller;
    this._aliasController.stateController=controller;
  }
  Future<SubscriptionCommandResult> build() async {
    SubscriptionCommand subscriptionCommand = SubscriptionCommand();
    Map<String, String> widgetCmdIds = Map();
    Map<String, String> aliasCmdIds = Map();

    try {
       DashboardDetailConfiguration dashConfig = _dashboardDetail.dashboardConfiguration;
      if (dashConfig.widgets != null)
        for (var i = 0; i < dashConfig.widgets.length; i++) {
          WidgetConfig widgetConfig = dashConfig.widgets[i];
          if (widgetConfig == null || !WidgetHelperList.list.contains(widgetConfig.typeAlias)) {
            continue;
          }
          if (!dashConfig.defaultState.map.containsKey(widgetConfig.id)) {
            continue;
          }

          if (widgetConfig.config == null || widgetConfig.config.datasources == null || widgetConfig.config.datasources.length == 0) continue;

          List<Datasources> dataSources = await resolveDataSourceList(widgetConfig.config.datasources);
          List<TsSubCmds> subCmdsList = await _calculateTimeSeriesSubscriptionCommands2(widgetConfig, dataSources, dashConfig.timewindow);
          if (subCmdsList != null && subCmdsList.length > 0) {
            subCmdsList.forEach((subCmd) {
              if(subCmd.keys=="" || subCmd.keys==null) return;
              widgetCmdIds[commandId.toString()] = widgetConfig.id;
              aliasCmdIds[commandId.toString()] = subCmd.aliasId;
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

    return SubscriptionCommandResult(subscriptionCommand, widgetCmdIds,aliasCmdIds);
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
      tsSubCommands.aliasId=dataSource.entityAliasId;
      dataSource.dataKeys?.forEach((element) {
        if(element.type!="entityField"){
          label += '${element.name},';
          if (element.type == "attribute") {
            tsSubCommands.isAttribute = true;
          }
        }
      });

      if (label != null && label != "") {
        label = label.substring(0, label.length - 1);
      }
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
    }

    if (widgetConfig.timewindow.aggregation != null) {
      tsSubCmds.agg = widgetConfig.timewindow.aggregation.type;
      tsSubCmds.limit = 289;
    }

    return tsSubCmds;
  }

  TsSubCmds setTimeWindowProperties(TimeWindow timeWindow, TsSubCmds tsSubCommands) {
    if (timeWindow != null && timeWindow.history != null) {
      tsSubCommands.interval = timeWindow.history.interval;

      if (timeWindow.history.fixedTimewindow != null) {
        tsSubCommands.startTs = timeWindow.history.fixedTimewindow.startTimeMs;
        tsSubCommands.endTs = timeWindow.history.fixedTimewindow.endTimeMs;
      } else {
        tsSubCommands.startTs = (DateTime.now().millisecondsSinceEpoch - timeWindow.history.timewindowMs);
        tsSubCommands.endTs = (DateTime.now().millisecondsSinceEpoch);
        if (timeWindow.history.interval > 0) {
          tsSubCommands.interval = timeWindow.history.interval;
        }
      }
    }
    if (timeWindow != null && timeWindow.realtime != null) {
      tsSubCommands.startTs = (DateTime.now().millisecondsSinceEpoch - timeWindow.realtime.timewindowMs);
      if (timeWindow.realtime.interval > 0) {
        tsSubCommands.interval = timeWindow.realtime.interval;

        tsSubCommands.timeWindow = timeWindow.realtime.timewindowMs + tsSubCommands.interval;
        tsSubCommands.limit = (tsSubCommands.timeWindow / tsSubCommands.interval).ceil();
      }
    }

    if (timeWindow.aggregation != null) {
      tsSubCommands.agg = timeWindow.aggregation.type;
    }

    return tsSubCommands;
  }
}
