import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';

class DashboardStateNotifier with ChangeNotifier, DiagnosticableTreeMixin {
  // int _value = 33;
  // int get value => _value;
  // set setValue(int newVal) {
  //   _value = newVal;
  //   notifyListeners();
  // }

  DashboardStateNotifier();

  Map<String, dynamic> _latestData = {};
  Map<String, String> _widgetSubscriptionIds = {};

  Map<String, dynamic> get latestData => _latestData;

  Map<String, String> get widgetSubscriptionIds => _widgetSubscriptionIds;

  void appendLatestDataToGraph(String dataKey, int nextInt) {
    _latestData[dataKey] = SocketData(nextInt, DateTime.now().millisecondsSinceEpoch, null);
    notifyListeners();
  }

  void addDataToProvider(String subscriptionId, Map<String, List<dynamic>> data) {
    if (widgetSubscriptionIds.containsKey(subscriptionId)) {
      try {
        _latestData[widgetSubscriptionIds[subscriptionId]] =
            SocketData(0, DateTime.now().millisecondsSinceEpoch, data);
        notifyListeners();
      } catch (e) {
        print(e);
      }
    }
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(IntProperty('_value', _value));
  // }

  void setSubscriptionIds(Map<String, String> widgetCmdIds) {
    _widgetSubscriptionIds.addAll(widgetCmdIds);
  }

  void addSubscriptionId(String widgetId, String cmdId) {
    _widgetSubscriptionIds[cmdId] = widgetId;
  }
}
