import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/control_rpc_button.dart';
import 'package:ndu_dashboard_widgets/widgets/not_implemented_widget.dart';

import 'base_dash_widget.dart';
import 'cards/cards.dart';
import 'charts//charts.dart';
import 'controls/controls.dart';

class DashboardWidgetHelper {
  static BaseDashboardWidget getImplementedWidget(
      WidgetConfig widgetConfig, DashboardDetailConfiguration dashboardConfiguration, AliasController aliasController) {
    BaseDashboardWidget baseDashboardWidget;

    if (widgetConfig != null) {
      if (widgetConfig.bundleAlias == "cards") {
        if (widgetConfig.typeAlias == "simple_card") {
          baseDashboardWidget = SimpleCardWidget(widgetConfig);
        }
      } else if (widgetConfig.bundleAlias == "charts") {
        if (widgetConfig.typeAlias == "basic_timeseries") {
          baseDashboardWidget = BasicTimeseriesChart(widgetConfig);
        } else if (widgetConfig.typeAlias == "timeseries_bars_flot") {
          baseDashboardWidget = TimeSeriesBarsFlot(widgetConfig);
        }
      } else if (widgetConfig.bundleAlias == "control_widgets") {
        if (widgetConfig.typeAlias == "update_attributes") {
          baseDashboardWidget = ControlUpdateAttributes(widgetConfig, dashboardConfiguration);
        } else if (widgetConfig.typeAlias == "rpcbutton") {
          baseDashboardWidget = ControlRPCButton(widgetConfig, dashboardConfiguration);
        }
      }
    }
    if (baseDashboardWidget != null) {
      baseDashboardWidget.aliasController = aliasController;
      return baseDashboardWidget;
    }

    return NotImplementedWidget(widgetConfig);
  }
}
