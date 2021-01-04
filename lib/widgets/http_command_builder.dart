import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';

class HttpCommandBuilder {
  //private fields
  AliasController _aliasController;
  DashboardDetail _dashboardDetail;

  //getters
  DashboardDetail get dashboardDetail => _dashboardDetail;

  AliasController get aliasController => _aliasController;

  HttpCommandBuilder(this._aliasController, this._dashboardDetail);

  int commandId = 1;
  HttpCommandBuilder.build(){

  }
}
