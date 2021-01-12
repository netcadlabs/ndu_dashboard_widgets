
import 'package:ndu_dashboard_widgets/widgets/socket/socket_models.dart';


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
