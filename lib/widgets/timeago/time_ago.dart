import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimeAgo extends StatelessWidget {
  Locale myLocale;
  DateTime lastTime;

  TimeAgo(this.lastTime);

  @override
  Widget build(BuildContext context) {
    myLocale = Localizations.localeOf(context);
    if (myLocale.languageCode == 'tr') timeago.setLocaleMessages(myLocale.languageCode, timeago.TrMessages());
    else timeago.setLocaleMessages(myLocale.languageCode, timeago.EnMessages());
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.all(5),
      child: Text(
        timeago.format(lastTime, locale: myLocale.languageCode),
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}
