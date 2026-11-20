import 'package:dentify_flutter/inventory/data/remote/services/log_entry_service.dart';
import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';
import 'package:dentify_flutter/inventory/domain/repositories/log_entry_repository.dart';

class LogEntryRepositoryImpl implements LogEntryRepository {
  final LogEntryService logEntryService;

  LogEntryRepositoryImpl(this.logEntryService);

  @override
  Future<List<LogEntry>> getAllLogEntries() async {
    final responses = await logEntryService.getAllLogEntries();
    return responses.map((r) => r.toDomain()).toList();
  }
}
