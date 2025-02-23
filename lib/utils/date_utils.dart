
// am functina bakarahenin bo away katy estaman pe blet
// agar bangy kaynawaw hichy bo nanerin awaya rek am katay estaman ayate
//agarish offsetDays bo bnerinw har zhmarayaky bo bnerin awa am daqaya 7sabakat + aw zhmarayay ka nardwmana wata awana rozh dway esta
DateTime getDateWithOffset({int offsetDays = 0}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.add(Duration(days: offsetDays));
}
