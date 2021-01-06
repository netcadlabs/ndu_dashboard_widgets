 import 'package:ndu_api_client/models/dashboards/data_models.dart';
import 'package:ndu_api_client/models/dashboards/widget_config.dart';

class ChartHelper {
  static List<TimeSeriesGraphData> timeSeriesListUpdate(List<TimeSeriesGraphData> tsData,WidgetConfigConfig config) {
    tsData.sort((a,b) {
      return a.time.compareTo(b.time);
    });
    double minute = 0;
    if (config.timewindow.realtime != null &&
        config.timewindow.realtime.timewindowMs != null) {
      minute = (config.timewindow.realtime.timewindowMs *
          0.001) /
          60;
    }
    List<TimeSeriesGraphData> resultList = List();
    DateTime historyDateTime = DateTime(
        DateTime
            .now()
            .year,
        DateTime
            .now()
            .month,
        DateTime
            .now()
            .day,
        DateTime
            .now()
            .hour,
        DateTime
            .now()
            .minute - int.parse(minute.round().toString()),
        DateTime
            .now()
            .second);

    tsData.forEach((element) {
      if (historyDateTime.isBefore(element.time)) {
        resultList.add(element);
      }
    });
    return resultList;
  }
}