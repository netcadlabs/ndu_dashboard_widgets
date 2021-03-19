import 'package:ndu_api_client/models/api_models.dart';

class StateController {
  StateParams params;

  StateParams getStateParams() {
    return this.params;
  }

  setStateParams(StateParams params) {
    this.params = params;
  }
}

class StateParams {
  String entityName;
  String entityLabel;
  String targetEntityParamName;
  EntityId entityId;
  var key;

  StateParams({this.entityName, this.entityLabel, this.targetEntityParamName, this.entityId, this.key});
}
