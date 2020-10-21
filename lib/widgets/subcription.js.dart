import 'package:ndu_api_client/models/dashboards/widget_config.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';

class Subscription {
  AliasController aliasController;

  SubscriptionOptions subscriptionOptions;

  Subscription(this.subscriptionOptions) {
    aliasController = AliasController();
  }

  initDataSubscription() {}
}

class SubscriptionOptions {
  List<Datasources> datasources;
  Timewindow timeWindowConfig;
  Timewindow dashboardTimewindow;
  bool useDashboardTimewindow;
  String type;

  SubscriptionOptions(
      {this.datasources, this.timeWindowConfig, this.dashboardTimewindow, this.useDashboardTimewindow, this.type});
}
