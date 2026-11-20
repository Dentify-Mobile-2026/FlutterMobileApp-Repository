import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';

abstract class LogEntryRepository {
  Future<List<LogEntry>> getAllLogEntries();
}
