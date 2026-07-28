/// Formats an ISO date string ("2026-04-12") into a friendlier display
/// form ("Apr 12, 2026"), without pulling in the intl package for this
/// one narrow use case.
library;

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatIsoDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;

  final year = parts[0];
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);

  if (month == null || day == null || month < 1 || month > 12) return iso;

  return '${_monthNames[month - 1]} $day, $year';
}

String formatDateRange(String startIso, String endIso) {
  return '${formatIsoDate(startIso)} – ${formatIsoDate(endIso)}';
}
