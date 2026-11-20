import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';
import 'package:dentify_flutter/inventory/domain/repositories/log_entry_repository.dart';

class GetAllLogEntriesUseCase {
  final LogEntryRepository repository;

  GetAllLogEntriesUseCase(this.repository);

  Future<List<LogEntry>> call() {
    return repository.getAllLogEntries();
  }
}
