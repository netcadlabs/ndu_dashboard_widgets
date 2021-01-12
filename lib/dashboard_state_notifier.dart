import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ndu_api_client/models/dashboards/data_models.dart';

class DashboardStateNotifier with ChangeNotifier, DiagnosticableTreeMixin {
  DashboardStateNotifier();

  //SubscriptionId - Latest Data
  Map<String, Map<String, SocketData>> _latestData = {};

  //WidgetId - SubscriptionId
  Map<String, String> _widgetSubscriptionIds = {};

  //getters
  // Map<String, dynamic> get latestData => _latestData;
  // Map<String, String> get widgetSubscriptionIds => _widgetSubscriptionIds;

  List<SocketData> getWidgetData(String widgetId) {
    List<SocketData> list = List();
    if (_latestData.containsKey(widgetId))
      _latestData[widgetId].forEach((key, value) {
        list.add(value);
      });
    _latestData[widgetId] = {};
    return list;
  }

  void addDataToProvider(String subscriptionId, Map<String, List<dynamic>> data) {
    if (_widgetSubscriptionIds.containsKey(subscriptionId)) {
      try {
        String widgetId = _widgetSubscriptionIds[subscriptionId];
        if (!_latestData.containsKey(widgetId)) {
          _latestData[widgetId] = Map();
        }
        _latestData[widgetId][subscriptionId] = SocketData(0, DateTime.now().millisecondsSinceEpoch, data, subscriptionId);
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

  void addSubscriptionIds(Map<String, List<String>> widgetCmdIds) {
    widgetCmdIds.forEach((key, value) {
      value.forEach((element) {
        _widgetSubscriptionIds.putIfAbsent(element, () => key);
      });
    });
  }

  void addSubscriptionId(String widgetId, String cmdId) {
    _widgetSubscriptionIds[cmdId] = widgetId;
  }
}
