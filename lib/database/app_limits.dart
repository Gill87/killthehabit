class AppLimit {
  final String packageName;
  final int maxOpens; // e.g. 5
  final int minutesPerOpen; // e.g. 5
  int usedOpens; // track how many times opened today
  Duration usedTime; // track total active time today

  AppLimit({
    required this.packageName,
    required this.maxOpens,
    required this.minutesPerOpen,
    this.usedOpens = 0,
    this.usedTime = Duration.zero,
  });
}