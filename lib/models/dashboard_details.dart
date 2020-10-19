import 'package:ndu_dashboard_widgets/models/widget_config.dart';

class DashboardDetail {
  DashboardId id;
  int createdTime;
  TenantId tenantId;
  String title;
  List<dynamic> assignedCustomers;
  bool entityTypeEnabled;
  DashboardDetailConfiguration dashboardConfiguration;
  String name;

  DashboardDetail(
      {this.id,
      this.createdTime,
      this.tenantId,
      this.title,
      this.assignedCustomers,
      this.entityTypeEnabled,
      this.dashboardConfiguration,
      this.name});

  DashboardDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? new DashboardId.fromJson(json['id']) : null;
    createdTime = json['createdTime'];
    tenantId = json['tenantId'] != null
        ? new TenantId.fromJson(json['tenantId'])
        : null;
    title = json['title'];
    assignedCustomers = json['assignedCustomers'];
    entityTypeEnabled = json['entityTypeEnabled'];
    dashboardConfiguration = json['configuration'] != null
        ? new DashboardDetailConfiguration.fromJson(json['configuration'])
        : null;
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id.toJson();
    }
    data['createdTime'] = this.createdTime;
    if (this.tenantId != null) {
      data['tenantId'] = this.tenantId.toJson();
    }
    data['title'] = this.title;
    data['assignedCustomers'] = this.assignedCustomers;
    data['entityTypeEnabled'] = this.entityTypeEnabled;
    if (this.dashboardConfiguration != null) {
      data['configuration'] = this.dashboardConfiguration.toJson();
    }
    data['name'] = this.name;
    return data;
  }
}

class DashboardId {
  String entityType;
  String id;

  DashboardId({this.entityType, this.id});

  DashboardId.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['id'] = this.id;
    return data;
  }
}

class TenantId {
  String entityType;
  String id;

  TenantId({this.entityType, this.id});

  TenantId.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['id'] = this.id;
    return data;
  }
}

class DashboardDetailConfiguration {
  String description;
  List<ConfigurationState> states;
  Map<String, EntityAliases> entityAliases;
  Timewindow timewindow;
  List<WidgetConfig> widgets;
  ConfigurationSettings configurationsettings;

  DashboardDetailConfiguration(
      {this.description,
      this.states,
      this.entityAliases,
      this.timewindow,
      this.widgets,
      this.configurationsettings});

  DashboardDetailConfiguration.fromJson(Map<String, dynamic> json) {
    description = json['description'];

    states = List();
    if (json['states'] != null) {
      Map<String, dynamic> stateMap = json['states'];
      stateMap.forEach((key, value) {
        states.add(ConfigurationState.fromJson(value, key));
      });
    }

    entityAliases = Map();
    if (json['entityAliases'] != null) {
      Map<String, dynamic> aliases = json['entityAliases'];
      aliases.forEach((key, value) {
        entityAliases[key] = EntityAliases.fromJson(value);
      });
    }

    widgets = List();
    if (json['widgets'] != null) {
      Map<String, dynamic> aliases = json['widgets'];
      aliases.forEach((key, value) {
        widgets.add(WidgetConfig.fromJson(value));
      });
    }

    timewindow = json['timewindow'] != null
        ? new Timewindow.fromJson(json['timewindow'])
        : null;
    configurationsettings = json['settings'] != null
        ? new ConfigurationSettings.fromJson(json['settings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;

    if (this.states != null) {
      Map result = {};
      this.states.forEach((element) {
        result[element.key] = element.toJson();
      });
      data['states'] = result;
    }

    if (this.entityAliases != null) {
      data['entityAliases'] = this.entityAliases;
    }
    if (this.widgets != null) {
      Map result = {};
      this.widgets.forEach((element) {
        result[element.id] = element.toJson();
      });
      data['widgets'] = result;
    }
    if (this.timewindow != null) {
      data['timewindow'] = this.timewindow.toJson();
    }
    if (this.configurationsettings != null) {
      data['settings'] = this.configurationsettings.toJson();
    }
    return data;
  }
}

class ConfigurationState {
  String name;
  String key;
  bool root;

  //TODO
  // Layouts layouts;

  ConfigurationState({this.name, this.root});

  ConfigurationState.fromJson(Map<String, dynamic> json, String key) {
    name = json['name'];
    root = json['root'];
    this.key = key;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['root'] = this.root;
    data['key'] = this.key;

    return data;
  }
}

class EntityAliases {
  String id;
  String alias;
  Filter filter;

  EntityAliases({this.id, this.alias, this.filter});

  EntityAliases.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alias = json['alias'];
    filter =
        json['filter'] != null ? new Filter.fromJson(json['filter']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['alias'] = this.alias;
    if (this.filter != null) {
      data['filter'] = this.filter.toJson();
    }
    return data;
  }
}

class Filter {
  String type;
  bool resolveMultiple;
  String entityType;
  String entityNameFilter;
  SingleEntity singleEntity;

  Filter(
      {this.type,
      this.resolveMultiple,
      this.entityType,
      this.entityNameFilter});

  Filter.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    resolveMultiple = json['resolveMultiple'];
    entityType = json['entityType'];
    entityNameFilter = json['entityNameFilter'];
    singleEntity = json['singleEntity'] != null
        ? new SingleEntity.fromJson(json['singleEntity'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['resolveMultiple'] = this.resolveMultiple;
    data['entityType'] = this.entityType;
    data['entityNameFilter'] = this.entityNameFilter;
    if (this.singleEntity != null) {
      data['singleEntity'] = this.singleEntity.toJson();
    }

    return data;
  }
}

class SingleEntity {
  String entityType;
  String id;

  SingleEntity({this.entityType, this.id});

  SingleEntity.fromJson(Map<String, dynamic> json) {
    entityType = json['entityType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entityType'] = this.entityType;
    data['id'] = this.id;
    return data;
  }
}

class Timewindow {
  String displayValue;
  int selectedTab;
  bool hideInterval;
  bool hideAggregation;
  bool hideAggInterval;
  Realtime realtime;
  History history;
  Aggregation aggregation;

  Timewindow(
      {this.displayValue,
      this.selectedTab,
      this.hideInterval,
      this.hideAggregation,
      this.hideAggInterval,
      this.realtime,
      this.history,
      this.aggregation});

  Timewindow.fromJson(Map<String, dynamic> json) {
    displayValue = json['displayValue'];
    selectedTab = json['selectedTab'];
    hideInterval = json['hideInterval'];
    hideAggregation = json['hideAggregation'];
    hideAggInterval = json['hideAggInterval'];
    realtime = json['realtime'] != null
        ? new Realtime.fromJson(json['realtime'])
        : null;
    history =
        json['history'] != null ? new History.fromJson(json['history']) : null;
    aggregation = json['aggregation'] != null
        ? new Aggregation.fromJson(json['aggregation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayValue'] = this.displayValue;
    data['selectedTab'] = this.selectedTab;
    data['hideInterval'] = this.hideInterval;
    data['hideAggregation'] = this.hideAggregation;
    data['hideAggInterval'] = this.hideAggInterval;
    if (this.realtime != null) {
      data['realtime'] = this.realtime.toJson();
    }
    if (this.history != null) {
      data['history'] = this.history.toJson();
    }
    if (this.aggregation != null) {
      data['aggregation'] = this.aggregation.toJson();
    }
    return data;
  }
}

class Realtime {
  int interval;
  int timewindowMs;

  Realtime({this.interval, this.timewindowMs});

  Realtime.fromJson(Map<String, dynamic> json) {
    interval = json['interval'];
    timewindowMs = json['timewindowMs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['interval'] = this.interval;
    data['timewindowMs'] = this.timewindowMs;
    return data;
  }
}

class History {
  int historyType;
  int interval;
  int timewindowMs;
  FixedTimewindow fixedTimewindow;

  History(
      {this.historyType,
      this.interval,
      this.timewindowMs,
      this.fixedTimewindow});

  History.fromJson(Map<String, dynamic> json) {
    historyType = json['historyType'];
    interval = json['interval'];
    timewindowMs = json['timewindowMs'];
    fixedTimewindow = json['fixedTimewindow'] != null
        ? new FixedTimewindow.fromJson(json['fixedTimewindow'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['historyType'] = this.historyType;
    data['interval'] = this.interval;
    data['timewindowMs'] = this.timewindowMs;
    if (this.fixedTimewindow != null) {
      data['fixedTimewindow'] = this.fixedTimewindow.toJson();
    }
    return data;
  }
}

class FixedTimewindow {
  int startTimeMs;
  int endTimeMs;

  FixedTimewindow({this.startTimeMs, this.endTimeMs});

  FixedTimewindow.fromJson(Map<String, dynamic> json) {
    startTimeMs = json['startTimeMs'];
    endTimeMs = json['endTimeMs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startTimeMs'] = this.startTimeMs;
    data['endTimeMs'] = this.endTimeMs;
    return data;
  }
}

class Aggregation {
  String type;
  int limit;

  Aggregation({this.type, this.limit});

  Aggregation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['limit'] = this.limit;
    return data;
  }
}

class ConfigurationSettings {
  String stateControllerId;
  bool showTitle;
  bool showDashboardsSelect;
  bool showEntitiesSelect;
  bool showDashboardTimewindow;
  bool showDashboardExport;
  bool toolbarAlwaysOpen;

  ConfigurationSettings(
      {this.stateControllerId,
      this.showTitle,
      this.showDashboardsSelect,
      this.showEntitiesSelect,
      this.showDashboardTimewindow,
      this.showDashboardExport,
      this.toolbarAlwaysOpen});

  ConfigurationSettings.fromJson(Map<String, dynamic> json) {
    stateControllerId = json['stateControllerId'];
    showTitle = json['showTitle'];
    showDashboardsSelect = json['showDashboardsSelect'];
    showEntitiesSelect = json['showEntitiesSelect'];
    showDashboardTimewindow = json['showDashboardTimewindow'];
    showDashboardExport = json['showDashboardExport'];
    toolbarAlwaysOpen = json['toolbarAlwaysOpen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stateControllerId'] = this.stateControllerId;
    data['showTitle'] = this.showTitle;
    data['showDashboardsSelect'] = this.showDashboardsSelect;
    data['showEntitiesSelect'] = this.showEntitiesSelect;
    data['showDashboardTimewindow'] = this.showDashboardTimewindow;
    data['showDashboardExport'] = this.showDashboardExport;
    data['toolbarAlwaysOpen'] = this.toolbarAlwaysOpen;
    return data;
  }
}
