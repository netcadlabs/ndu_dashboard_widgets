import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:ndu_dashboard_widgets/graph_data.dart';

class DashboardStateNotifier with ChangeNotifier, DiagnosticableTreeMixin {
  int _value = 33;

  int get value => _value;

  var DATA = {};
  var LATEST_DATA = {};

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
    DATA[dataKey].add(GraphData(_value, DateTime.now().millisecondsSinceEpoch));
    notifyListeners();
  }

  void appendLatestDataToGraph(String dataKey, int nextInt) {
    LATEST_DATA[dataKey] =
        GraphData(nextInt, DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('_value', _value));
  }
}
