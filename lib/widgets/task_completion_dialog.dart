import 'package:flutter/material.dart';

// Shared completion dialog used by both the task card (tasks_page) and
// the task detail page. onComplete fires when the user confirms — the caller
// decides what to actually DO (remove from list, pop the page, etc).
Future<void> showTaskCompletionDialog({
  required BuildContext context,
  required Map<String, String> task,
  required VoidCallback onComplete,
}) {
  final clientName = (task['clientName'] ?? '').isNotEmpty
      ? task['clientName']!
      : 'this client';
  final taskType = task['taskType'] ?? 'Task';

  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: const Color(0xFF13161E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$taskType Task Completed?',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Would you like to add a $taskType activity to $clientName\'s timeline?',
              style: const TextStyle(fontSize: 13.0, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24.0),

            // Primary action — logs an activity AND completes (TODO: log when timeline is built)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: const Color(0xFF0B0D12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Add a $taskType Activity and mark as complete'),
              ),
            ),
            const SizedBox(height: 8.0),

            // Secondary action — just removes the task, no activity logged
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onComplete();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4ADE80),
                  side: const BorderSide(color: Color(0xFF4ADE80)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('Mark as complete only'),
              ),
            ),

            // Cancel — closes dialog without doing anything
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
