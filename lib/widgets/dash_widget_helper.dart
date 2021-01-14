import 'package:flutter/material.dart';
import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:ndu_dashboard_widgets/widgets/analogue_gauges/gauge_canvas_gauges.dart';
import 'package:ndu_dashboard_widgets/widgets/cards/ndu_widget_cards_entities_table.dart';
import 'package:ndu_dashboard_widgets/widgets/charts/charts.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/control_knob.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/control_led_indicator.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/control_rpc_button.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/control_switch_button.dart';
import 'package:ndu_dashboard_widgets/widgets/controls/ndu_control_slider.dart';
import 'package:ndu_dashboard_widgets/widgets/digital_gauges/gauge_justgage.dart';
import 'package:ndu_dashboard_widgets/widgets/not_implemented_widget.dart';
import 'package:ndu_dashboard_widgets/widgets/socket/socket_command_builder.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'base_dash_widget.dart';
import 'cards/cards.dart';
import 'cards/ndu_widget_cards_base64_viewer.dart';
import 'charts/ndu_widget_charts_basic_timeseries.dart';
import 'cards/ndu_widget_entity_widget.dart';
import 'controls/control_update_attributes.dart';

class DashboardWidgetHelper {
  static BaseDashboardWidget getImplementedWidget(WidgetConfig widgetConfig, DashboardDetailConfiguration dashboardConfiguration,
      AliasController aliasController, WebSocketChannel webSocketChannel, SocketCommandBuilder socketCommandBuilder) {
    BaseDashboardWidget baseDashboardWidget;

    if (widgetConfig != null) {
      if (widgetConfig.bundleAlias == "cards") {
        if (widgetConfig.typeAlias == "simple_card") {
          baseDashboardWidget = SimpleCardWidget(widgetConfig,);
        } else if (widgetConfig.typeAlias == "label_widget") {
          baseDashboardWidget = LabelCardWidget(widgetConfig);
        } else if (widgetConfig.typeAlias == "entity_icon") {
          baseDashboardWidget = EntityCardWidget(widgetConfig);
        } else if (widgetConfig.typeAlias == "base64_viewer") {
          baseDashboardWidget = Base64ViewerWidget(widgetConfig);
        } else if (widgetConfig.typeAlias == "entities_table") {
          baseDashboardWidget = EntitiesTableWidget(widgetConfig);
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
        } else if (widgetConfig.typeAlias == "switch_control") {
          baseDashboardWidget = ControlSwitchButton(widgetConfig, dashboardConfiguration);
        } else if (widgetConfig.typeAlias == "round_switch") {
          baseDashboardWidget = ControlSwitchButton(widgetConfig, dashboardConfiguration, isRoundButton: true);
        } else if (widgetConfig.typeAlias == "led_indicator") {
          baseDashboardWidget = ControlLedIndicator(widgetConfig, dashboardConfiguration);
        } else if (widgetConfig.typeAlias == "knob_control") {
          baseDashboardWidget = NduControlKnob(widgetConfig, dashboardConfiguration);
        }
      } else if (widgetConfig.bundleAlias == "ndu_control_widgets") {
        if (widgetConfig.typeAlias == "slider_control") {
          baseDashboardWidget = NduControlSlider(widgetConfig, dashboardConfiguration);
        }
        /*if (widgetConfig.typeAlias == "entity_status_icon") {
          baseDashboardWidget = NduControlEntityStatusIcon(widgetConfig, dashboardConfiguration);
        }*/
      } else if (widgetConfig.bundleAlias == "digital_gauges") {
        if (widgetConfig.typeAlias == "gauge_justgage" || widgetConfig.typeAlias == "mini_gauge_justgage") {
          baseDashboardWidget = GaugeJustgageWidget(widgetConfig, dashboardConfiguration);
        }
      } else if (widgetConfig.bundleAlias == "analogue_gauges") {
        if (widgetConfig.typeAlias == "temperature_radial_gauge_canvas_gauges" || widgetConfig.typeAlias == "speed_gauge_canvas_gauges") {
          baseDashboardWidget = GaugeCanvasGaugeWidget(widgetConfig, dashboardConfiguration);
        }
      }
    }
    if (baseDashboardWidget != null) {
      baseDashboardWidget.aliasController = aliasController;
      baseDashboardWidget.webSocketChannel = webSocketChannel;
      baseDashboardWidget.socketCommandBuilder = socketCommandBuilder;
      return baseDashboardWidget;
    }

    return NotImplementedWidget(widgetConfig);
  }
}
