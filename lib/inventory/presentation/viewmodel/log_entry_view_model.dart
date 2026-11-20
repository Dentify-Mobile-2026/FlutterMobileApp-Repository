import 'package:dentify_flutter/inventory/domain/model/log_entry.dart';
import 'package:dentify_flutter/inventory/domain/usecases/get_all_log_entries_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogEntryViewModel extends StateNotifier<AsyncValue<List<LogEntry>>> {
  final GetAllLogEntriesUseCase getAllLogEntriesUseCase;

  LogEntryViewModel(this.getAllLogEntriesUseCase)
      : super(const AsyncValue.loading());

  Future<void> getAllLogEntries() async {
    state = const AsyncValue.loading();
    try {
      final entries = await getAllLogEntriesUseCase();
      entries.sort((a, b) {
        final da = a.createdAtDate;
        final db = b.createdAtDate;
        if (da != null && db != null) {
          return db.compareTo(da);
        }
        return b.id.compareTo(a.id);
      });
      state = AsyncValue.data(entries);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
