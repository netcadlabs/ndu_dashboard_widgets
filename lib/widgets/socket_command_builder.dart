import 'package:ndu_dashboard_widgets/models/dashboard_details.dart';
import 'package:ndu_dashboard_widgets/models/widget_config.dart';

class SocketCommandBuilder {
  static SubscriptionCommandResult create(DashboardDetail dashboardDetail) {
    SubscriptionCommand subscriptionCommand = SubscriptionCommand();
    Map<String, String> widgetCmdIds = Map();

    int commandId = 1;
    if (dashboardDetail.dashboardConfiguration.widgets != null)
      dashboardDetail.dashboardConfiguration.widgets.forEach((widgetConfig) {
        if (widgetConfig.config == null ||
            widgetConfig.config.datasources == null ||
            widgetConfig.config.datasources.length == 0) return;

        widgetConfig.config.datasources.forEach((datasource) {
          TsSubCmds subCmds = _convertDatasource(
              datasource,
              dashboardDetail.dashboardConfiguration
                  .entityAliases[datasource.entityAliasId]);
          if (subCmds != null) {
            widgetCmdIds[commandId.toString()] = widgetConfig.id;
            subCmds.cmdId = commandId;
            commandId++;
            subscriptionCommand.tsSubCmds.add(subCmds);
          }
        });
      });

    return SubscriptionCommandResult(subscriptionCommand, widgetCmdIds);
  }

  static TsSubCmds _convertDatasource(
      Datasources datasources, EntityAliases entityAliases) {
    if (datasources == null) return null;

    if (entityAliases.filter.type == "singleEntity" &&
        entityAliases.filter.singleEntity != null) {
      TsSubCmds tsSubCmds = TsSubCmds(
          entityId: entityAliases.filter.singleEntity.id,
          entityType: entityAliases.filter.singleEntity.entityType);
      String label = "";
      datasources.dataKeys.forEach((element) {
        label += '${element.label},';
      });
      label = label.substring(0, label.length - 1);
      tsSubCmds.keys = label;
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
  List<TsSubCmds> attrSubCmds = List(); //TODO - yeni model tipini öğren

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

    attrSubCmds = new List<TsSubCmds>();
    if (json['attrSubCmds'] != null) {
      json['attrSubCmds'].forEach((v) {
        attrSubCmds.add(new TsSubCmds.fromJson(v));
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
