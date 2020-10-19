class WidgetConfig {
  bool isSystemType;
  String bundleAlias;
  String typeAlias;
  String type;
  String title;
  int sizeX;
  int sizeY;
  WidgetConfigConfig config;
  String id;

  WidgetConfig(
      {this.isSystemType,
      this.bundleAlias,
      this.typeAlias,
      this.type,
      this.title,
      this.sizeX,
      this.sizeY,
      this.config,
      this.id});

  WidgetConfig.fromJson(Map<String, dynamic> json) {
    isSystemType = json['isSystemType'];
    bundleAlias = json['bundleAlias'];
    typeAlias = json['typeAlias'];
    type = json['type'];
    title = json['title'];
    sizeX = json['sizeX'];
    sizeY = json['sizeY'];
    config = json['config'] != null
        ? new WidgetConfigConfig.fromJson(json['config'])
        : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSystemType'] = this.isSystemType;
    data['bundleAlias'] = this.bundleAlias;
    data['typeAlias'] = this.typeAlias;
    data['type'] = this.type;
    data['title'] = this.title;
    data['sizeX'] = this.sizeX;
    data['sizeY'] = this.sizeY;
    if (this.config != null) {
      data['config'] = this.config.toJson();
    }
    data['id'] = this.id;
    return data;
  }
}

class WidgetConfigConfig {
  List<Datasources> datasources;
  Timewindow timewindow;
  bool showTitle;
  String backgroundColor;
  String color;
  String padding;
  Settings settings;
  String title;
  bool dropShadow;
  bool enableFullscreen;
  TitleStyle titleStyle;
  String mobileHeight;
  bool showTitleIcon;
  String titleIcon;
  String iconColor;
  String iconSize;
  String titleTooltip;
  WidgetStyle widgetStyle;
  bool useDashboardTimewindow;
  bool displayTimewindow;
  bool showLegend;
  bool showOnMobile;
  WidgetStyle actions;

  WidgetConfigConfig(
      {this.datasources,
      this.timewindow,
      this.showTitle,
      this.backgroundColor,
      this.color,
      this.padding,
      this.settings,
      this.title,
      this.dropShadow,
      this.enableFullscreen,
      this.titleStyle,
      this.mobileHeight,
      this.showTitleIcon,
      this.titleIcon,
      this.iconColor,
      this.iconSize,
      this.titleTooltip,
      this.widgetStyle,
      this.useDashboardTimewindow,
      this.displayTimewindow,
      this.showLegend,
      this.showOnMobile,
      this.actions});

  WidgetConfigConfig.fromJson(Map<String, dynamic> json) {
    if (json['datasources'] != null) {
      datasources = new List<Datasources>();
      json['datasources'].forEach((v) {
        datasources.add(new Datasources.fromJson(v));
      });
    }
    timewindow = json['timewindow'] != null
        ? new Timewindow.fromJson(json['timewindow'])
        : null;
    showTitle = json['showTitle'];
    backgroundColor = json['backgroundColor'];
    color = json['color'];
    padding = json['padding'];
    settings = json['settings'] != null
        ? new Settings.fromJson(json['settings'])
        : null;
    title = json['title'] == null ? "" : json['title'];
    dropShadow = json['dropShadow'];
    enableFullscreen = json['enableFullscreen'];
    titleStyle = json['titleStyle'] != null
        ? new TitleStyle.fromJson(json['titleStyle'])
        : null;
    mobileHeight = json['mobileHeight'];
    showTitleIcon = json['showTitleIcon'];
    titleIcon = json['titleIcon'] == null ? "" : json['titleIcon'];
    iconColor = json['iconColor'] == null ? "" : json['iconColor'];
    iconSize = json['iconSize'];
    titleTooltip = json['titleTooltip'];
    widgetStyle = json['widgetStyle'] != null
        ? new WidgetStyle.fromJson(json['widgetStyle'])
        : null;
    useDashboardTimewindow = json['useDashboardTimewindow'];
    displayTimewindow = json['displayTimewindow'];
    showLegend = json['showLegend'];
    showOnMobile = json['showOnMobile'];
    actions = json['actions'] != null
        ? new WidgetStyle.fromJson(json['actions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.datasources != null) {
      data['datasources'] = this.datasources.map((v) => v.toJson()).toList();
    }
    if (this.timewindow != null) {
      data['timewindow'] = this.timewindow.toJson();
    }
    data['showTitle'] = this.showTitle;
    data['backgroundColor'] = this.backgroundColor;
    data['color'] = this.color;
    data['padding'] = this.padding;
    if (this.settings != null) {
      data['settings'] = this.settings.toJson();
    }
    data['title'] = this.title;
    data['dropShadow'] = this.dropShadow;
    data['enableFullscreen'] = this.enableFullscreen;
    if (this.titleStyle != null) {
      data['titleStyle'] = this.titleStyle.toJson();
    }
    data['mobileHeight'] = this.mobileHeight;
    data['showTitleIcon'] = this.showTitleIcon;
    data['titleIcon'] = this.titleIcon;
    data['iconColor'] = this.iconColor;
    data['iconSize'] = this.iconSize;
    data['titleTooltip'] = this.titleTooltip;
    if (this.widgetStyle != null) {
      data['widgetStyle'] = this.widgetStyle.toJson();
    }
    data['useDashboardTimewindow'] = this.useDashboardTimewindow;
    data['displayTimewindow'] = this.displayTimewindow;
    data['showLegend'] = this.showLegend;
    data['showOnMobile'] = this.showOnMobile;
    if (this.actions != null) {
      data['actions'] = this.actions.toJson();
    }
    return data;
  }
}

class Datasources {
  String type;
  List<DataKeys> dataKeys;
  String entityAliasId;

  Datasources({this.type, this.dataKeys, this.entityAliasId});

  Datasources.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['dataKeys'] != null) {
      dataKeys = new List<DataKeys>();
      json['dataKeys'].forEach((v) {
        dataKeys.add(new DataKeys.fromJson(v));
      });
    }
    entityAliasId = json['entityAliasId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.dataKeys != null) {
      data['dataKeys'] = this.dataKeys.map((v) => v.toJson()).toList();
    }
    data['entityAliasId'] = this.entityAliasId;
    return data;
  }
}

class DataKeys {
  String name;
  String type;
  String label;
  String color;
  DataKeySettings settings;
  double dHash;

  DataKeys(
      {this.name,
      this.type,
      this.label,
      this.color,
      this.settings,
      this.dHash});

  DataKeys.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    label = json['label'];
    color = json['color'];
    settings = json['settings'] != null
        ? new DataKeySettings.fromJson(json['settings'])
        : null;
    dHash = json['_hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type;
    data['label'] = this.label;
    data['color'] = this.color;
    if (this.settings != null) {
      data['settings'] = this.settings.toJson();
    }
    data['_hash'] = this.dHash;
    return data;
  }
}

class DataKeySettings {
  bool excludeFromStacking;
  bool hideDataByDefault;
  bool disableDataHiding;
  bool removeFromLegend;
  bool showLines;
  bool fillLines;
  bool showPoints;
  String showPointShape;
  String pointShapeFormatter;
  int showPointsLineWidth;
  int showPointsRadius;
  String tooltipValueFormatter;
  bool showSeparateAxis;
  String axisTitle;
  String axisPosition;
  String axisTicksFormatter;
  List<Thresholds> thresholds;
  ComparisonSettings comparisonSettings;

  DataKeySettings(
      {this.excludeFromStacking,
      this.hideDataByDefault,
      this.disableDataHiding,
      this.removeFromLegend,
      this.showLines,
      this.fillLines,
      this.showPoints,
      this.showPointShape,
      this.pointShapeFormatter,
      this.showPointsLineWidth,
      this.showPointsRadius,
      this.tooltipValueFormatter,
      this.showSeparateAxis,
      this.axisTitle,
      this.axisPosition,
      this.axisTicksFormatter,
      this.thresholds,
      this.comparisonSettings});

  DataKeySettings.fromJson(Map<String, dynamic> json) {
    excludeFromStacking = json['excludeFromStacking'];
    hideDataByDefault = json['hideDataByDefault'];
    disableDataHiding = json['disableDataHiding'];
    removeFromLegend = json['removeFromLegend'];
    showLines = json['showLines'];
    fillLines = json['fillLines'];
    showPoints = json['showPoints'];
    showPointShape = json['showPointShape'];
    pointShapeFormatter = json['pointShapeFormatter'];
    showPointsLineWidth = json['showPointsLineWidth'];
    showPointsRadius = json['showPointsRadius'];
    tooltipValueFormatter = json['tooltipValueFormatter'];
    showSeparateAxis = json['showSeparateAxis'];
    axisTitle = json['axisTitle'];
    axisPosition = json['axisPosition'];
    axisTicksFormatter = json['axisTicksFormatter'];
    if (json['thresholds'] != null) {
      thresholds = new List<Thresholds>();
      json['thresholds'].forEach((v) {
        thresholds.add(new Thresholds.fromJson(v));
      });
    }
    comparisonSettings = json['comparisonSettings'] != null
        ? new ComparisonSettings.fromJson(json['comparisonSettings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['excludeFromStacking'] = this.excludeFromStacking;
    data['hideDataByDefault'] = this.hideDataByDefault;
    data['disableDataHiding'] = this.disableDataHiding;
    data['removeFromLegend'] = this.removeFromLegend;
    data['showLines'] = this.showLines;
    data['fillLines'] = this.fillLines;
    data['showPoints'] = this.showPoints;
    data['showPointShape'] = this.showPointShape;
    data['pointShapeFormatter'] = this.pointShapeFormatter;
    data['showPointsLineWidth'] = this.showPointsLineWidth;
    data['showPointsRadius'] = this.showPointsRadius;
    data['tooltipValueFormatter'] = this.tooltipValueFormatter;
    data['showSeparateAxis'] = this.showSeparateAxis;
    data['axisTitle'] = this.axisTitle;
    data['axisPosition'] = this.axisPosition;
    data['axisTicksFormatter'] = this.axisTicksFormatter;
    if (this.thresholds != null) {
      data['thresholds'] = this.thresholds.map((v) => v.toJson()).toList();
    }
    if (this.comparisonSettings != null) {
      data['comparisonSettings'] = this.comparisonSettings.toJson();
    }
    return data;
  }
}

class Thresholds {
  String thresholdValueSource;

  Thresholds({this.thresholdValueSource});

  Thresholds.fromJson(Map<String, dynamic> json) {
    thresholdValueSource = json['thresholdValueSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['thresholdValueSource'] = this.thresholdValueSource;
    return data;
  }
}

class ComparisonSettings {
  bool showValuesForComparison;
  String comparisonValuesLabel;
  String color;

  ComparisonSettings(
      {this.showValuesForComparison, this.comparisonValuesLabel, this.color});

  ComparisonSettings.fromJson(Map<String, dynamic> json) {
    showValuesForComparison = json['showValuesForComparison'];
    comparisonValuesLabel = json['comparisonValuesLabel'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showValuesForComparison'] = this.showValuesForComparison;
    data['comparisonValuesLabel'] = this.comparisonValuesLabel;
    data['color'] = this.color;
    return data;
  }
}

class Timewindow {
  Realtime realtime;

  Timewindow({this.realtime});

  Timewindow.fromJson(Map<String, dynamic> json) {
    realtime = json['realtime'] != null
        ? new Realtime.fromJson(json['realtime'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.realtime != null) {
      data['realtime'] = this.realtime.toJson();
    }
    return data;
  }
}

class Realtime {
  int timewindowMs;

  Realtime({this.timewindowMs});

  Realtime.fromJson(Map<String, dynamic> json) {
    timewindowMs = json['timewindowMs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timewindowMs'] = this.timewindowMs;
    return data;
  }
}

class Settings {
  int shadowSize;
  String fontColor;
  int fontSize;
  Xaxis xaxis;
  Xaxis yaxis;
  Grid grid;
  bool stack;
  bool tooltipIndividual;
  String timeForComparison;
  XaxisSecond xaxisSecond;

  Settings(
      {this.shadowSize,
      this.fontColor,
      this.fontSize,
      this.xaxis,
      this.yaxis,
      this.grid,
      this.stack,
      this.tooltipIndividual,
      this.timeForComparison,
      this.xaxisSecond});

  Settings.fromJson(Map<String, dynamic> json) {
    shadowSize = json['shadowSize'];
    fontColor = json['fontColor'];
    fontSize = json['fontSize'];
    xaxis = json['xaxis'] != null ? new Xaxis.fromJson(json['xaxis']) : null;
    yaxis = json['yaxis'] != null ? new Xaxis.fromJson(json['yaxis']) : null;
    grid = json['grid'] != null ? new Grid.fromJson(json['grid']) : null;
    stack = json['stack'];
    tooltipIndividual = json['tooltipIndividual'];
    timeForComparison = json['timeForComparison'];
    xaxisSecond = json['xaxisSecond'] != null
        ? new XaxisSecond.fromJson(json['xaxisSecond'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shadowSize'] = this.shadowSize;
    data['fontColor'] = this.fontColor;
    data['fontSize'] = this.fontSize;
    if (this.xaxis != null) {
      data['xaxis'] = this.xaxis.toJson();
    }
    if (this.yaxis != null) {
      data['yaxis'] = this.yaxis.toJson();
    }
    if (this.grid != null) {
      data['grid'] = this.grid.toJson();
    }
    data['stack'] = this.stack;
    data['tooltipIndividual'] = this.tooltipIndividual;
    data['timeForComparison'] = this.timeForComparison;
    if (this.xaxisSecond != null) {
      data['xaxisSecond'] = this.xaxisSecond.toJson();
    }
    return data;
  }
}

class Xaxis {
  bool showLabels;
  String color;

  Xaxis({this.showLabels, this.color});

  Xaxis.fromJson(Map<String, dynamic> json) {
    showLabels = json['showLabels'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showLabels'] = this.showLabels;
    data['color'] = this.color;
    return data;
  }
}

class Grid {
  String color;
  String tickColor;
  bool verticalLines;
  bool horizontalLines;
  int outlineWidth;

  Grid(
      {this.color,
      this.tickColor,
      this.verticalLines,
      this.horizontalLines,
      this.outlineWidth});

  Grid.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    tickColor = json['tickColor'];
    verticalLines = json['verticalLines'];
    horizontalLines = json['horizontalLines'];
    outlineWidth = json['outlineWidth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['tickColor'] = this.tickColor;
    data['verticalLines'] = this.verticalLines;
    data['horizontalLines'] = this.horizontalLines;
    data['outlineWidth'] = this.outlineWidth;
    return data;
  }
}

class XaxisSecond {
  String axisPosition;
  bool showLabels;

  XaxisSecond({this.axisPosition, this.showLabels});

  XaxisSecond.fromJson(Map<String, dynamic> json) {
    axisPosition = json['axisPosition'];
    showLabels = json['showLabels'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['axisPosition'] = this.axisPosition;
    data['showLabels'] = this.showLabels;
    return data;
  }
}

class TitleStyle {
  String fontSize;
  int fontWeight;

  TitleStyle({this.fontSize, this.fontWeight});

  TitleStyle.fromJson(Map<String, dynamic> json) {
    fontSize = json['fontSize'];
    fontWeight = json['fontWeight'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fontSize'] = this.fontSize;
    data['fontWeight'] = this.fontWeight;
    return data;
  }
}

class WidgetStyle {
  WidgetStyle();

  WidgetStyle.fromJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

//
// class Config {
//   List<Datasources> datasources;
//   Timewindow timewindow;
//   bool showTitle;
//   String backgroundColor;
//   String color;
//   String padding;
//   Settings settings;
//   String title;
//   bool dropShadow;
//   bool enableFullscreen;
//   TitleStyle titleStyle;
//   String mobileHeight;
//   bool showTitleIcon;
//   String titleIcon;
//   String iconColor;
//   String iconSize;
//   String titleTooltip;
//   WidgetStyle widgetStyle;
//   bool useDashboardTimewindow;
//   bool displayTimewindow;
//   bool showLegend;
//   bool showOnMobile;
//   WidgetStyle actions;
//
//   Config(
//       {this.datasources,
//       this.timewindow,
//       this.showTitle,
//       this.backgroundColor,
//       this.color,
//       this.padding,
//       this.settings,
//       this.title,
//       this.dropShadow,
//       this.enableFullscreen,
//       this.titleStyle,
//       this.mobileHeight,
//       this.showTitleIcon,
//       this.titleIcon,
//       this.iconColor,
//       this.iconSize,
//       this.titleTooltip,
//       this.widgetStyle,
//       this.useDashboardTimewindow,
//       this.displayTimewindow,
//       this.showLegend,
//       this.showOnMobile,
//       this.actions});
//
//   Config.fromJson(Map<String, dynamic> json) {
//     if (json['datasources'] != null) {
//       datasources = new List<Datasources>();
//       json['datasources'].forEach((v) {
//         datasources.add(new Datasources.fromJson(v));
//       });
//     }
//     timewindow = json['timewindow'] != null
//         ? new Timewindow.fromJson(json['timewindow'])
//         : null;
//     showTitle = json['showTitle'];
//     backgroundColor = json['backgroundColor'];
//     color = json['color'];
//     padding = json['padding'];
//     settings = json['settings'] != null
//         ? new Settings.fromJson(json['settings'])
//         : null;
//     title = json['title'];
//     dropShadow = json['dropShadow'];
//     enableFullscreen = json['enableFullscreen'];
//     titleStyle = json['titleStyle'] != null
//         ? new TitleStyle.fromJson(json['titleStyle'])
//         : null;
//     mobileHeight = json['mobileHeight'];
//     showTitleIcon = json['showTitleIcon'];
//     titleIcon = json['titleIcon'];
//     iconColor = json['iconColor'];
//     iconSize = json['iconSize'];
//     titleTooltip = json['titleTooltip'];
//     widgetStyle = json['widgetStyle'] != null
//         ? new WidgetStyle.fromJson(json['widgetStyle'])
//         : null;
//     useDashboardTimewindow = json['useDashboardTimewindow'];
//     displayTimewindow = json['displayTimewindow'];
//     showLegend = json['showLegend'];
//     showOnMobile = json['showOnMobile'];
//     actions = json['actions'] != null
//         ? new WidgetStyle.fromJson(json['actions'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.datasources != null) {
//       data['datasources'] = this.datasources.map((v) => v.toJson()).toList();
//     }
//     if (this.timewindow != null) {
//       data['timewindow'] = this.timewindow.toJson();
//     }
//     data['showTitle'] = this.showTitle;
//     data['backgroundColor'] = this.backgroundColor;
//     data['color'] = this.color;
//     data['padding'] = this.padding;
//     if (this.settings != null) {
//       data['settings'] = this.settings.toJson();
//     }
//     data['title'] = this.title;
//     data['dropShadow'] = this.dropShadow;
//     data['enableFullscreen'] = this.enableFullscreen;
//     if (this.titleStyle != null) {
//       data['titleStyle'] = this.titleStyle.toJson();
//     }
//     data['mobileHeight'] = this.mobileHeight;
//     data['showTitleIcon'] = this.showTitleIcon;
//     data['titleIcon'] = this.titleIcon;
//     data['iconColor'] = this.iconColor;
//     data['iconSize'] = this.iconSize;
//     data['titleTooltip'] = this.titleTooltip;
//     if (this.widgetStyle != null) {
//       data['widgetStyle'] = this.widgetStyle.toJson();
//     }
//     data['useDashboardTimewindow'] = this.useDashboardTimewindow;
//     data['displayTimewindow'] = this.displayTimewindow;
//     data['showLegend'] = this.showLegend;
//     data['showOnMobile'] = this.showOnMobile;
//     if (this.actions != null) {
//       data['actions'] = this.actions.toJson();
//     }
//     return data;
//   }
// }
