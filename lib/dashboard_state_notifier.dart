import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ndu_dashboard_widgets/models/data_models.dart';

class DashboardStateNotifier with ChangeNotifier, DiagnosticableTreeMixin {
  int _value = 33;

  int get value => _value;

  var DATA = {};
  Map<String, dynamic> LATEST_DATA = {};
  Map<String, String> WIDGET_SUBSCRIPTION_IDS = {};

  set setValue(int newVal) {
    _value = newVal;
    notifyListeners();
  }

  void appendDataToGraph(String dataKey, int nextInt) {
    _value = nextInt;
    if (!DATA.containsKey(dataKey)) {
      DATA[dataKey] = new List<SocketData>();
    }
    DATA[dataKey].add(SocketData(_value, DateTime.now().millisecondsSinceEpoch, null));
    notifyListeners();
  }

  void appendLatestDataToGraph(String dataKey, int nextInt) {
    LATEST_DATA[dataKey] = SocketData(nextInt, DateTime.now().millisecondsSinceEpoch, null);
    notifyListeners();
  }

  void addDataToProvider(String subscriptionId, Map<String, List<dynamic>> data) {
    if (WIDGET_SUBSCRIPTION_IDS.containsKey(subscriptionId)) {
      try {
        LATEST_DATA[WIDGET_SUBSCRIPTION_IDS[subscriptionId]] = SocketData(0, DateTime.now().millisecondsSinceEpoch, data);
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
    WIDGET_SUBSCRIPTION_IDS = widgetCmdIds;
  }
}
