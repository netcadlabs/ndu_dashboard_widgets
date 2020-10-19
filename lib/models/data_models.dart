class SocketData {
  final int value;
  final Map<String, List<dynamic>> datas;
  final int ts;

  SocketData(this.value, this.ts, this.datas);
}

class TimeSeriesGraphData {
  final DateTime time;
  final double value;

  TimeSeriesGraphData(this.time, this.value);
}
