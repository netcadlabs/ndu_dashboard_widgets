import 'package:ndu_dashboard_widgets/models/widget_config.dart';
import 'package:ndu_dashboard_widgets/widgets/cards/ndu_widget_cards_simple_card.dart';
import 'package:ndu_dashboard_widgets/widgets/not_implemented_widget.dart';

import 'base_dash_widget.dart';
import 'charts/ndu_widget_charts_basic_timeseries.dart';

class DashboardWidgetHelper {
  static BaseDashboardWidget getImplementedWidget(WidgetConfig widgetConfig) {
    if (widgetConfig != null) {
      if (widgetConfig.bundleAlias == "cards") {
        if (widgetConfig.typeAlias == "simple_card") return SimpleCardWidget(widgetConfig);
      }
      if (widgetConfig.bundleAlias == "charts") {
        if (widgetConfig.typeAlias == "basic_timeseries") return BasicTimeseriesChart(widgetConfig);
      }
    }
    return NotImplementedWidget(widgetConfig);
  }
}
