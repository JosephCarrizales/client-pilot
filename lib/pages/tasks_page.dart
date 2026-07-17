import 'package:client_pilot/pages/tasks_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:client_pilot/widgets/add_task_form.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {

  // 'final' is correct here — we never reassign the list variable itself,
  // we just call .add() on it. final + mutable list = safe.
  final List<Map<String, String>> tasks = [
    {
      'title':      'Follow up on payment',
      'clientName': 'Tom Harrington',
      'dueDate':    '2026-07-08',
      'priority':   'High',
      'status':     'Pending',
      'taskType':   'Call',
    },
    {
      'title':      'Send invoice',
      'clientName': 'Karen Mills',
      'dueDate':    '2026-07-10',
      'priority':   'Normal',
      'status':     'Pending',
      'taskType':   'Email',
    },
  ];

  // Lookup table so we can find a full client map by name when navigating
  // to the task detail page. Keyed by name because that's what the task map
  // stores. When you add a real database, this goes away entirely.
  final Map<String, Map<String, String>> _clients = {
    'Tom Harrington': {'name': 'Tom Harrington', 'phone': '555-999-0000', 'email': 'tomh@example.com', 'service': 'Lawn Mowing', 'schedule': 'Every Tuesday', 'price': '\$75', 'status': 'Overdue', 'address': '77 Ridgeline Rd', 'notes': 'Called twice — no response.'},
    'Karen Mills':    {'name': 'Karen Mills',    'phone': '555-222-3333', 'email': 'karen@example.com', 'service': 'Cleanup',     'schedule': 'Monthly',       'price': '\$90', 'status': 'Overdue', 'address': '31 Sunset Blvd',  'notes': 'Left voicemail.'},
  };

  String searchQuery = '';

  // Tasks use priority (High/Normal/Low), not payment status.
  // This helper maps priority to the right theme color.
  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'High':  return const Color(0xFFF87171); // red
      case 'Low':   return const Color(0xFF4ADE80); // green
      default:      return const Color(0xFFF59E0B); // amber for Normal
    }
  }

// Converts '2026-07-08' → 'Jul 8, 2026' for display.
  // DateTime.tryParse returns null if the string isn't a valid date,
  // so we fall back to showing the raw string rather than crashing.
  String _formatDueDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Searches on the fields that actually exist on a task map.
  List<Map<String, String>> get filteredTasks {
    if (searchQuery.isEmpty) return tasks;
    return tasks.where((task) {
      final titleMatch      = task['title']!.toLowerCase().contains(searchQuery.toLowerCase());
      final clientNameMatch = task['clientName']!.toLowerCase().contains(searchQuery.toLowerCase());
      return titleMatch || clientNameMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [

          // PAGE HEADER
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Row(
              children: [
                const Text('Tasks',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${tasks.length} total',
                  style: const TextStyle(fontSize: 12.0, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // SEARCH BAR + ADD BUTTON
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF13161E),
                    //borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFF252836), width: 1.0),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              GestureDetector(
                onTap: () async {
                  // Navigator.push returns whatever the form passes back via Navigator.pop.
                  // 'await' pauses here until the form closes, then newTask holds the result.
                  final newTask = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTaskForm()),
                  );
                  if (newTask != null) {
                    setState(() => tasks.add(newTask));
                  }
                },
                child: Container(
                  height: 45.0,
                  width: 45.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF0B0D12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // TASK LIST
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return _buildTaskCard(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(Map<String, String> task) {
    final clientName = task['clientName']!;
    final taskType   = task['taskType'];

    // Dialog uses a custom widget instead of AlertDialog so we can stack the
    // buttons vertically — the button text is long and would overflow a Row.
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF13161E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink-wrap to content, don't fill screen
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$taskType Task Completed?',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Would you like to add a $taskType activity to $clientName\'s timeline?',
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24.0),

              // Primary action — full width green button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: log activity to timeline when that feature is built
                    setState(() => tasks.remove(task));
                    Navigator.pop(ctx);
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

              // Secondary action — green border + text, no fill, so it reads as
              // a distinct choice from the primary without competing for attention
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => tasks.remove(task));
                    Navigator.pop(ctx);
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

              // Cancel — closes the dialog without doing anything
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

  Widget _buildTaskCard(Map<String, String> task) {
    final priorityColor = _priorityColor(task['priority']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13161E),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () {
            // Look up the full client map by the name stored on the task.
            // Falls back to an empty map if the name doesn't match anyone,
            // so the app doesn't crash if a task has a client we haven't added yet.
            final client = _clients[task['clientName']] ?? {};
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TasksDetailPage(task: task, client: client),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Tapping removes the task from the list after confirming in the dialog.
                // Material + InkWell gives the circular ripple on tap.
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showCompletionDialog(task),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF64748B),
                        size: 28.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task['title']!,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(task['clientName']!,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text('Due ${_formatDueDate(task['dueDate'])}',
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Priority pill on the right
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(task['priority']!,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
