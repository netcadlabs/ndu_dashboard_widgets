import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/not_implemented_widget.dart';

import 'base_dash_widget.dart';
import 'cards/cards.dart';
import 'charts//charts.dart';
import 'controls/controls.dart';

class DashboardWidgetHelper {
  static BaseDashboardWidget getImplementedWidget(
      WidgetConfig widgetConfig, DashboardDetailConfiguration dashboardConfiguration) {
    if (widgetConfig != null) {
      if (widgetConfig.bundleAlias == "cards") {
        if (widgetConfig.typeAlias == "simple_card") return SimpleCardWidget(widgetConfig);
      } else if (widgetConfig.bundleAlias == "charts") {
        if (widgetConfig.typeAlias == "basic_timeseries") return BasicTimeseriesChart(widgetConfig);
        if (widgetConfig.typeAlias == "timeseries_bars_flot") return TimeSeriesBarsFlot(widgetConfig);
      } else if (widgetConfig.bundleAlias == "control_widgets") {
        if (widgetConfig.typeAlias == "update_attributes")
          return ControlUpdateAttributes(widgetConfig, dashboardConfiguration);
      }
    }
    return NotImplementedWidget(widgetConfig);
  }
}
