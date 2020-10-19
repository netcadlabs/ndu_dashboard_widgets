import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';

class DashboardStateNotifier with ChangeNotifier, DiagnosticableTreeMixin {
  int _value = 33;

  int get value => _value;

  var DATA = {};
  Map<String, GraphData> LATEST_DATA = {};
  Map<String, String> WIDGET_SUBSCRIPTION_IDS = {};

  set setValue(int newVal) {
    _value = newVal;
    notifyListeners();
  }

  void increment() {
    _value = _value + 1;
    notifyListeners();
  }

  void decrement() {
    _value = _value - 1;
    notifyListeners();
  }

  void appendDataToGraph(String dataKey, int nextInt) {
    _value = nextInt;
    if (!DATA.containsKey(dataKey)) {
      DATA[dataKey] = new List<GraphData>();
    }
    DATA[dataKey]
        .add(GraphData(_value, DateTime.now().millisecondsSinceEpoch, null));
    notifyListeners();
  }

  void appendLatestDataToGraph(String dataKey, int nextInt) {
    LATEST_DATA[dataKey] =
        GraphData(nextInt, DateTime.now().millisecondsSinceEpoch, null);
    notifyListeners();
  }

  void appendLatestDataToGraph2(String subscriptionId, List<dynamic> data) {
    if (WIDGET_SUBSCRIPTION_IDS.containsKey(subscriptionId)) {
      LATEST_DATA[WIDGET_SUBSCRIPTION_IDS[subscriptionId]] =
          GraphData(0, DateTime.now().millisecondsSinceEpoch, data);
      notifyListeners();
    }
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('_value', _value));
  }

  void setSubscriptionIds(Map<String, String> widgetCmdIds) {
    WIDGET_SUBSCRIPTION_IDS = widgetCmdIds;
  }
}
