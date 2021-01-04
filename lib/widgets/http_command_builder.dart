import 'package:ndu_api_client/models/dashboards/dashboard_detail_model.dart';
import 'package:ndu_dashboard_widgets/api/alias_controller.js.dart';
import 'package:http/http.dart' as http;
import 'package:ndu_dashboard_widgets/widgets/socket_command_builder.dart';


enum RequestMethod {
  GET,
  HEAD,
  POST,
  PUT,
  PATCH,
  DELETE,
  OPTIONS,
  TRACE
}

class HttpCommandBuilder {

  final SubscriptionCommandResult subscriptionCommandResult;
  HttpCommandBuilder(this.subscriptionCommandResult);

  int commandId = 1;

  Future<HttpCommandResult> build() {
    Map<String, List<String>> widgetCommandIds = Map();
    //subscriptionCommandResult

    return Future.value(HttpCommandResult());
  }

}

class HttpCommandResult {
  Map<String, List<String>> widgetCommandIds;
  HttpCommandResult();
}

class HttpCommand {
  final String uri;
  final int commandId;
  final RequestMethod method;

  HttpCommand({this.method, this.uri, this.commandId});
}
