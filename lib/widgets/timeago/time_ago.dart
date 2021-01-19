import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class TimeAgo extends StatelessWidget {
  final DateTime lastTime;
  TimeAgo(this.lastTime);

  @override
  Widget build(BuildContext context) {
    final Locale myLocale= Localizations.localeOf(context);
    if (myLocale.languageCode == 'tr') timeAgo.setLocaleMessages(myLocale.languageCode, timeAgo.TrMessages());
    else timeAgo.setLocaleMessages(myLocale.languageCode, timeAgo.EnMessages());
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(5),
      child: Text(
        timeAgo.format(lastTime, locale: myLocale.languageCode),
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
