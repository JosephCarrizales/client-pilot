import 'package:flutter/material.dart';
import 'package:client_pilot/pages/tasks_detail_page.dart';
import 'package:client_pilot/pages/client_detail_page.dart';
import 'package:client_pilot/data/app_data.dart';

// ── Data model ──────────────────────────────────────────────────────────────
// isRead is NOT final so we can flip it after the user views the linked page.
class NotificationItem {
  final String id;
  final String type;   // 'task_due' | 'job_upcoming'
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  // Set when the notification links to a task — passed straight to TasksDetailPage.
  final Map<String, String>? linkedTask;

  // Set when the notification links to a client (e.g. upcoming job).
  // We store the name and look up the full map from kContacts at navigation time.
  final String? linkedClientName;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.linkedTask,
    this.linkedClientName,
  });
}

// ── Page ─────────────────────────────────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

// No Scaffold here — NotificationsPage lives inside HomePage's Scaffold as a
// bottom nav tab, just like ContactsPage and TasksPage. Using our own Scaffold
// would stack two AppBars and create a big dead zone at the top of the screen.
class _NotificationsPageState extends State<NotificationsPage> {

  // Hardcoded sample notifications. Timestamps are relative to today (2026-09-02)
  // so the 'Today' / 'Yesterday' labels work correctly.
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: 'task_due',
      title: 'Task Due Today',
      body: 'Follow up on payment for Tom Harrington is due today.',
      timestamp: DateTime(2026, 9, 2, 9, 0),
      linkedTask: {
        'title':      'Follow up on payment',
        'clientName': 'Tom Harrington',
        'dueDate':    '2026-09-02',
        'priority':   'High',
        'status':     'Pending',
        'taskType':   'Call',
      },
    ),
    NotificationItem(
      id: '2',
      type: 'task_due',
      title: 'Task Due Soon',
      body: 'Send invoice for Karen Mills is due in 2 days.',
      timestamp: DateTime(2026, 9, 2, 8, 15),
      linkedTask: {
        'title':      'Send invoice',
        'clientName': 'Karen Mills',
        'dueDate':    '2026-09-04',
        'priority':   'Normal',
        'status':     'Pending',
        'taskType':   'Email',
      },
    ),
    NotificationItem(
      id: '3',
      type: 'job_upcoming',
      title: 'Upcoming Job',
      body: 'Lawn Mowing scheduled for Marcus Webb - Every Monday.',
      timestamp: DateTime(2026, 9, 1, 10, 0),
      linkedClientName: 'Marcus Webb',
    ),
    NotificationItem(
      id: '4',
      type: 'job_upcoming',
      title: 'Upcoming Job',
      body: 'Hedge Trimming scheduled for Sandra Torres - Every Wednesday.',
      timestamp: DateTime(2026, 9, 1, 9, 30),
      linkedClientName: 'Sandra Torres',
    ),
    NotificationItem(
      id: '5',
      type: 'task_due',
      title: 'Task Overdue',
      body: 'Pressure washing quote for Derek Liu was due on August 30th.',
      timestamp: DateTime(2026, 8, 30, 8, 0),
      linkedTask: {
        'title':      'Send pressure washing quote',
        'clientName': 'Derek Liu',
        'dueDate':    '2026-08-30',
        'priority':   'Normal',
        'status':     'Pending',
        'taskType':   'Email',
      },
    ),
  ];

  // Computed views — filtered from the single source of truth above.
  // Flutter recalculates these on every rebuild, so they're always in sync.
  List<NotificationItem> get _unread => _notifications.where((n) => !n.isRead).toList();
  List<NotificationItem> get _read   => _notifications.where((n) =>  n.isRead).toList();

  // Opens whatever the notification links to. 'await' pauses until the user
  // pops back, then marks as read so it moves to the Read tab.
  Future<void> _openNotification(NotificationItem n) async {
    if (n.linkedTask != null) {
      // Task notification → open the task detail page
      final client = kContacts.firstWhere(
        (c) => c['name'] == n.linkedTask!['clientName'],
        orElse: () => <String, String>{},
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TasksDetailPage(task: n.linkedTask!, client: client),
        ),
      );
    } else if (n.linkedClientName != null) {
      // Job notification → open the client's detail page
      final client = kContacts.firstWhere(
        (c) => c['name'] == n.linkedClientName,
        orElse: () => <String, String>{},
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientDetailPage(client: client),
        ),
      );
    }

    // Mark as read after the user returns — triggers rebuild to move tabs
    if (mounted && !n.isRead) {
      setState(() => n.isRead = true);
    }
  }

  // ── Date helpers ─────────────────────────────────────────────────────────
  // Groups a flat list into a map keyed by date label, sorted newest-first.
  // Map insertion order is preserved in Dart so the order stays correct.
  Map<String, List<NotificationItem>> _groupByDate(List<NotificationItem> items) {
    final grouped = <String, List<NotificationItem>>{};
    final sorted  = [...items]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final item in sorted) {
      final label = _dateLabel(item.timestamp);
      // putIfAbsent adds the key only if it isn't already there
      grouped.putIfAbsent(label, () => []).add(item);
    }

    return grouped;
  }

  // 'Today', 'Yesterday', or 'August 30th'
  String _dateLabel(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(dt.year, dt.month, dt.day);

    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'January', 'February', 'March',     'April',   'May',      'June',
      'July',    'August',   'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}${_ordinal(dt.day)}';
  }

  // The 'th'/'st'/'nd'/'rd' suffix for a day number
  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th'; // 11th, 12th, 13th are exceptions
    switch (n % 10) {
      case 1:  return 'st';
      case 2:  return 'nd';
      case 3:  return 'rd';
      default: return 'th';
    }
  }

  // '9:05 AM', '2:30 PM'
  String _timeLabel(DateTime dt) {
    final hour   = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // DefaultTabController manages the tab state for us — no manual controller
    // needed. TabBar and TabBarView inside it find it automatically.
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Page header — same style as ContactsPage and TasksPage
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
              child: Row(
                children: [
                  const Text('Notifications',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // Unread count in the top-right corner
                  if (_unread.isNotEmpty)
                    Text('${_unread.length} unread',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),

            // Tab bar — sits flush against a thin border line underneath
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF252836), width: 1.0),
                ),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(
                    fontSize: 14.0, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 14.0),
                indicatorColor: const Color(0xFF4ADE80),
                indicatorWeight: 2.0,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Unread'),
                        if (_unread.isNotEmpty) ...[
                          const SizedBox(width: 6.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ADE80),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text('${_unread.length}',
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B0D12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Tab(text: 'Read'),
                ],
              ),
            ),

            // Tab content fills the rest of the available space
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(_unread),
                  _buildList(_read),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a scrollable list for one tab, grouped by date with headers.
  Widget _buildList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Nothing here',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
        ),
      );
    }

    final grouped = _groupByDate(items);

    // Flatten the grouped map into a mixed list of headers + cards
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        for (final entry in grouped.entries) ...[
          _buildDateHeader(entry.key),
          ...entry.value.map(_buildCard),
        ],
      ],
    );
  }

  // Date section header — 'TODAY', 'YESTERDAY', 'AUGUST 30TH'
  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Single notification card
  Widget _buildCard(NotificationItem n) {
    // Icon and color are based on the notification type
    final isTaskDue  = n.type == 'task_due';
    final iconData   = isTaskDue ? Icons.assignment_outlined : Icons.event_outlined;
    final iconColor  = isTaskDue ? const Color(0xFFF59E0B) : const Color(0xFF4ADE80);
    final isTappable = n.linkedTask != null || n.linkedClientName != null;
    final tapHint    = n.linkedTask != null ? 'Tap to view task' : 'Tap to view contact';

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
          // Only tappable if there's a linked task to navigate to
          onTap: isTappable ? () => _openNotification(n) : null,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Type icon in a colored circle
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, size: 18.0, color: iconColor),
                ),
                const SizedBox(width: 12.0),

                // Title, body, and optional tap hint
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(n.title,
                              style: TextStyle(
                                fontSize: 14.0,
                                // Bold for unread, normal for read
                                fontWeight: n.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(_timeLabel(n.timestamp),
                            style: const TextStyle(
                              fontSize: 11.0,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(n.body,
                        style: const TextStyle(
                          fontSize: 13.0,
                          color: Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                      if (isTappable) ...[
                        const SizedBox(height: 6.0),
                        Text(tapHint,
                          style: const TextStyle(
                            fontSize: 11.0,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Green dot on the right edge signals unread
                if (!n.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8.0, top: 2.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
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
