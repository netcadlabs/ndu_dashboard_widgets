import 'package:ndu_api_client/models/dashboards/widget_config.dart';

class SubscriptionCommandResult {
  SubscriptionCommand subscriptionCommand;
  Map<String, String> widgetCmdIds;

  SubscriptionCommandResult(this.subscriptionCommand, this.widgetCmdIds);
}

class SubscriptionCommand {
  List<TsSubCmds> tsSubCmds = List();
  List<HistoryCmds> historyCmds = List();
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
        historyCmds.add(new HistoryCmds.fromJson(v));
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
  int endTs;
  int startTs;
  int timeWindow;
  int interval;
  int limit;
  String agg;
  bool isAttribute;
  Datasources datasource;

  TsSubCmds(
      {this.entityType,
      this.entityId,
      this.keys,
      this.cmdId,
      this.startTs,
      this.endTs,
      this.timeWindow,
      this.interval,
      this.limit,
      this.agg,
      this.isAttribute = false,
      this.datasource});

  TsSubCmds.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    entityId = json['entityId'];
    keys = json['keys'];
    cmdId = json['cmdId'];
    timeWindow = json['timeWindow'];
    interval = json['interval'];
    limit = json['limit'];
    agg = json['agg'];
    startTs = json['startTs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['entityId'] = this.entityId;
    data['keys'] = this.keys;
    data['cmdId'] = this.cmdId;
    data['timeWindow'] = this.timeWindow;
    data['interval'] = this.interval;
    data['limit'] = this.limit;
    data['agg'] = this.agg;
    data['startTs'] = this.startTs;
    return data;
  }
}

class HistoryCmds extends TsSubCmds {
  String entityType;
  String entityId;
  String keys;
  int cmdId;
  int endTs;
  int startTs;
  int interval;
  int limit;
  String agg;

  HistoryCmds({this.entityType, this.entityId, this.keys, this.cmdId, this.startTs, this.endTs, this.interval, this.limit, this.agg});

  HistoryCmds.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    entityId = json['entityId'];
    keys = json['keys'];
    cmdId = json['cmdId'];
    startTs = json['startTs'];
    startTs = json['endTs'];
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
    data['endTs'] = this.endTs;
    data['interval'] = this.interval;
    data['limit'] = this.limit;
    data['agg'] = this.agg;
    return data;
  }
}
