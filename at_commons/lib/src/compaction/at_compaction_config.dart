class AtCompactionConfig {
  // -1 indicates storing for ever
  int sizeInKB = -1;
  // -1 indicates storing for ever
  int timeInDays = -1;
  // Percentage of logs to compact when the condition is met
  int compactionPercentage;
  // Frequency interval in which the logs are compacted
  int compactionFrequencyMins;

  AtCompactionConfig(int sizeInKB, int timeInDays, int compactionPercentage,
      int compactionFrequencyMins) {
    this.sizeInKB = sizeInKB;
    this.timeInDays = timeInDays;
    this.compactionPercentage = compactionPercentage;
    this.compactionFrequencyMins = compactionFrequencyMins;
  }

  bool timeBasedCompaction() {
    return timeInDays != -1;
  }

  bool sizeBasedCompaction() {
    return sizeInKB != -1;
  }
}
