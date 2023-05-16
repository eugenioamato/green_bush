class SystemPreferences {
  int maxDownloads = 25;
  int maxThreads = 50;
  int activeThreads = 0;
  int totalrenders = 0;

  int activeDownloads = 0;

  int errors = 0;
  int getActiveDownloads() => activeDownloads;

  int getActiveThreads() => activeThreads;

  int _range = 30;
  int getRange() => _range;
  void setRange(n) {
    _range = n;
  }
}
