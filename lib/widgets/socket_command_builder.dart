import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';

class SocketCommandBuilder {
  //private fields
  AliasController _aliasController;
  DashboardDetail _dashboardDetail;

  //getters
  DashboardDetail get dashboardDetail => _dashboardDetail;

  AliasController get aliasController => _aliasController;

  SocketCommandBuilder(this._aliasController, this._dashboardDetail);

  int commandId = 1;

  Future<SubscriptionCommandResult> build() async {
    SubscriptionCommand subscriptionCommand = SubscriptionCommand();
    Map<String, String> widgetCmdIds = Map();

    try {
      // aliasController = AliasController(entityAliases: dashboardDetail.dashboardConfiguration.entityAliases);

      if (_dashboardDetail.dashboardConfiguration.widgets != null)
        for (var i = 0; i < _dashboardDetail.dashboardConfiguration.widgets.length; i++) {
          WidgetConfig widgetConfig = _dashboardDetail.dashboardConfiguration.widgets[i];
          if (widgetConfig.config == null ||
              widgetConfig.config.datasources == null ||
              widgetConfig.config.datasources.length == 0) continue;

          List<Datasources> datasources = await resolveDatasources(widgetConfig.config.datasources);
          List<TsSubCmds> subCmdsList =
              await _calculateTimeSeriesSubscriptionCommands2(widgetConfig.config, datasources);

          if (subCmdsList != null && subCmdsList.length > 0) {
            subCmdsList.forEach((subCmd) {
              widgetCmdIds[commandId.toString()] = widgetConfig.id;
              subCmd.cmdId = commandId;
              commandId++;
              subscriptionCommand.tsSubCmds.add(subCmd);
            });
          }
        }
    } catch (err) {
      throw Exception('build hatasi ${err.toString()}');
    }

    return SubscriptionCommandResult(subscriptionCommand, widgetCmdIds);
  }

  Future<List<Datasources>> resolveDatasources(List<Datasources> datasources) async {
    List<Datasources> allDataSources = List();
    for (int i = 0; i < datasources.length; i++) {
      try {
        List<Datasources> datasourceList = await _aliasController.resolveDatasource(datasources[i], false);
        //TODO - javascript koduna bak.. resolveDatasources(datasources)
        allDataSources.addAll(datasourceList);
      } catch (err) {
        print(err);
      }
    }

    return allDataSources;
  }

  Future<List<TsSubCmds>> _calculateTimeSeriesSubscriptionCommands2(
      WidgetConfigConfig widgetConfig, List<Datasources> datasources) async {
    if (datasources == null) return null;

    // List<Datasources> datasourceList = await aliasController.resolveDatasource(datasources, false);

    List<TsSubCmds> list = List();
    datasources.forEach((datasource) {
      //TODO - TsSubCmds
      TsSubCmds tsSubCmds = TsSubCmds(entityId: datasource.entityId, entityType: datasource.entityType);
      String label = "";
      datasource.dataKeys.forEach((element) {
        label += '${element.name},';
      });
      label = label.substring(0, label.length - 1);
      tsSubCmds.keys = label;

      tsSubCmds = setTimeProperties(widgetConfig, tsSubCmds);
      list.add(tsSubCmds);
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
      // widgetConfig.timewindow.aggregation.limit; // limit ?
    }

    return tsSubCmds;
  }

  TsSubCmds _calculateTimeSeriesSubscriptionCommands(
      WidgetConfigConfig widgetConfig, Datasources datasources, EntityAliases entityAliases) {
    if (datasources == null) return null;

    if (entityAliases.filter.type == "singleEntity" && entityAliases.filter.singleEntity != null) {
      TsSubCmds tsSubCmds = TsSubCmds(
          entityId: entityAliases.filter.singleEntity.id, entityType: entityAliases.filter.singleEntity.entityType);
      String label = "";
      datasources.dataKeys.forEach((element) {
        label += '${element.name},';
      });
      label = label.substring(0, label.length - 1);
      tsSubCmds.keys = label;

      if (widgetConfig.timewindow != null && widgetConfig.timewindow.history != null) {
        tsSubCmds.interval = widgetConfig.timewindow.history.interval;
        // tsSubCmds.limit ?
        // tsSubCmds.timewindow ?
        if (widgetConfig.timewindow.history.fixedTimewindow != null)
          tsSubCmds.startTs = widgetConfig.timewindow.history.fixedTimewindow.startTimeMs * 1000;
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
        // widgetConfig.timewindow.aggregation.limit; // limit ?
      }

      return tsSubCmds;
    }

    return null;
  }
}

class SubscriptionCommandResult {
  SubscriptionCommand subscriptionCommand;
  Map<String, String> widgetCmdIds;

  SubscriptionCommandResult(this.subscriptionCommand, this.widgetCmdIds);
}

class SubscriptionCommand {
  List<TsSubCmds> tsSubCmds = List();
  List<TsSubCmds> historyCmds = List(); //TODO - yeni model tipini öğren
  List<AttrSubCmds> attrSubCmds = List(); //TODO - yeni model tipini öğren

  SubscriptionCommand();

  SubscriptionCommand.fromJson(Map<String, dynamic> json) {
    tsSubCmds = new List<TsSubCmds>();
    if (json['tsSubCmds'] != null) {
      json['tsSubCmds'].forEach((v) {
        tsSubCmds.add(new TsSubCmds.fromJson(v));
      });
    }

    historyCmds = new List<TsSubCmds>();
    if (json['historyCmds'] != null) {
      json['historyCmds'].forEach((v) {
        historyCmds.add(new TsSubCmds.fromJson(v));
      });
    }

    attrSubCmds = new List<AttrSubCmds>();
    if (json['attrSubCmds'] != null) {
      json['attrSubCmds'].forEach((v) {
        attrSubCmds.add(new AttrSubCmds.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tsSubCmds != null) {
      data['tsSubCmds'] = this.tsSubCmds.map((v) => v.toJson()).toList();
    }
    if (this.historyCmds != null) {
      data['historyCmds'] = this.historyCmds.map((v) => v.toJson()).toList();
    }
    if (this.attrSubCmds != null) {
      data['attrSubCmds'] = this.attrSubCmds.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttrSubCmds {
  String entityType;
  String entityId;
  String keys;
  int cmdId;

  AttrSubCmds({
    this.entityType,
    this.entityId,
    this.keys,
    this.cmdId,
  });

  AttrSubCmds.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    entityId = json['entityId'];
    keys = json['keys'];
    cmdId = json['cmdId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['entityId'] = this.entityId;
    data['keys'] = this.keys;
    data['cmdId'] = this.cmdId;
    return data;
  }
}

class TsSubCmds {
  String entityType;
  String entityId;
  String keys;
  int cmdId;
  int startTs;
  int timeWindow;
  int interval;
  int limit;
  String agg;

  TsSubCmds(
      {this.entityType,
      this.entityId,
      this.keys,
      this.cmdId,
      this.startTs,
      this.timeWindow,
      this.interval,
      this.limit,
      this.agg});

  TsSubCmds.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    entityId = json['entityId'];
    keys = json['keys'];
    cmdId = json['cmdId'];
    startTs = json['startTs'];
    timeWindow = json['timeWindow'];
    interval = json['interval'];
    limit = json['limit'];
    agg = json['agg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['entityId'] = this.entityId;
    data['keys'] = this.keys;
    data['cmdId'] = this.cmdId;
    data['startTs'] = this.startTs;
    data['timeWindow'] = this.timeWindow;
    data['interval'] = this.interval;
    data['limit'] = this.limit;
    data['agg'] = this.agg;
    return data;
  }
}
