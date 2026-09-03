import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_pilot/pages/client_detail_page.dart';
import 'package:client_pilot/pages/add_task.dart';
import 'package:client_pilot/data/app_data.dart';
import 'package:client_pilot/widgets/task_completion_dialog.dart';

// StatefulWidget is used here even though we don't have state yet.
// We'll need it once we add interactive sections like the contact action buttons.
class TasksDetailPage extends StatefulWidget {

  // These are the fields this page OWNS — its inputs.
  // Every time someone navigates here, they must hand over these two maps.
  // Think of it like a function signature: this page can't run without them.
  final Map<String, String> task;
  final Map<String, String> client;

  // The constructor is what outside code calls to CREATE this page.
  // Without it, nobody could pass data in — the page would have no way to
  // receive the task and client it needs to display.
  //
  // 'const' means Flutter can cache and reuse this widget if its inputs haven't
  // changed — a small performance win.
  //
  // 'super.key' passes the key up to Flutter's widget system. Keys help Flutter
  // track widgets across rebuilds. You don't manage this yourself — just always
  // include it so Flutter can do its job.
  //
  // 'required' means the caller MUST provide this value. If they forget,
  // Dart refuses to compile — it's caught at build time, not at runtime.
  //
  // 'this.task' is shorthand for: take the 'task' parameter and assign it to
  // the 'task' field declared above. Same as writing: this.task = task;
  const TasksDetailPage({
    super.key,
    required this.task,
    required this.client,
  });

  @override
  State<TasksDetailPage> createState() => _TasksDetailPageState();
}

// The State class is where all the logic and UI live.
// It's separate from TasksDetailPage because Flutter needs to rebuild the UI
// without throwing away your data. The State object survives rebuilds;
// the widget object gets recreated constantly.
//
// 'extends State<TasksDetailPage>' tells Dart this state belongs to TasksDetailPage.
// That's what gives us access to 'widget.' — it's the bridge back to the widget.
class _TasksDetailPageState extends State<TasksDetailPage> {

  // 'static const' means these values belong to the class itself, not to any
  // instance. They're created once and shared. We use them as the "ID" for each
  // menu item so we can compare them in onSelected without hardcoding strings
  // in multiple places — one typo in a raw string would be a silent bug.
  static const _menuComplete   = 'complete';
  static const _menuEdit       = 'edit';
  static const _menuReschedule = 'reschedule';
  static const _menuContact    = 'contact';
  static const _menuArchive    = 'archive';

  // Called when the user picks an option from the three-dots menu.
  // Each case either pops with a result string so tasks_page can react,
  // or pushes a new page.
  void _onMenuSelected(String value) {
    switch (value) {

      // Show the same completion dialog as the task card on the tasks page.
      // onComplete pops this page with 'delete' so tasks_page removes the task.
      case _menuComplete:
        showTaskCompletionDialog(
          context: context,
          task: widget.task,
          onComplete: () => Navigator.pop(context, 'delete'),
        );
        break;

      // Open the AddTask form pre-filled with the current task data.
      // If the user saves, pop back with the updated task so tasks_page can replace it.
      case _menuEdit:
        _editTask();
        break;

      // Navigate to the linked contact's detail page
      case _menuContact:
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ClientDetailPage(client: widget.client),
        ));
        break;

      // Archive = delete for now. Pop with 'delete' and tasks_page removes it.
      case _menuArchive:
        Navigator.pop(context, 'delete');
        break;
    }
  }

  // Pushes AddTask in edit mode. If the user saves changes, we pop this page
  // with the updated task map so tasks_page can replace the old entry.
  Future<void> _editTask() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        // kContacts gives the full contacts list so the user can change the link
        builder: (_) => AddTask(contacts: kContacts, task: widget.task),
      ),
    );

    // Only pop if the user actually saved (didn't cancel)
    if (updated != null && mounted) {
      Navigator.pop(context, updated);
    }
  }

  // Maps priority text to a color. Urgent treated same as High —
  // both signal something needs immediate attention.
  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'Low':    return const Color(0xFF4ADE80);
      case 'High':
      case 'Urgent': return const Color(0xFFF87171);
      default:       return const Color(0xFFF59E0B); // Normal / anything else
    }
  }

  // Takes the task's due date string and returns the right status label.
  // Returns an empty string if there's no date or it's far in the future.
  String _dueDateLabel(String? dateStr) {

    // The '?' in String? means dateStr can be null — if no date was set on the
    // task, we just return an empty string instead of crashing.
    if (dateStr == null) return '';

    // DateTime.parse() converts a date string like '2026-07-08' into a real
    // DateTime object that Dart can do math on. Without this, we'd just have
    // a string and couldn't compare it to today's date.
    final due = DateTime.parse(dateStr);

    // .difference() gives us a Duration (the gap between two dates).
    // .inDays converts that duration into a plain integer number of days.
    // A negative number means the due date is in the past.
    // A positive number means it's in the future.
    final diff = due.difference(DateTime.now()).inDays;

    if (diff < 0)  return 'Past Due';  // already passed
    if (diff == 0) return 'Due Today'; // today is the day
    if (diff <= 7) return 'Due Soon';  // within the next week

    // If none of the above matched, the task is far enough out
    // that it doesn't need a warning label yet.
    return '';
  }

  Color _dueDateColor(String? dueDate) {
    switch (dueDate) {
      case 'Due Soon':    return const Color(0xFF4ADE80);
      case 'Due Today': return const Color(0xFFF59E0B);
      case 'Past Due': return const Color(0xFFF87171);
      default:       return const Color(0xFF64748B
      ); // Normal / anything else
    }
  }

  // Converts '2026-07-08' → 'Jul 8, 2026' so the date is readable on screen.
  // Falls back to the raw string if parsing fails, so we never show nothing.
  String _formatDueDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No date set';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildTaskNameSection() {
    final priority      = widget.task['priority'];
    final priorityColor = _priorityColor(priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label — muted, uppercase, same style used throughout the app
          const Text('TASK NAME',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                // Expanded lets the title take all available space,
                // which pushes the priority pill to the far right.
                child: Text(
                  widget.task['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              // Priority pill — only shown if the task actually has a priority set
              if (priority != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(priority,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateSection() {
    // Calculate the label and its color once so we can use both below.
    // The label tells us the status ('Due Today', 'Due Soon', 'Past Due').
    // The color is derived from that label — not from priority.
    final label      = _dueDateLabel(widget.task['dueDate']);
    final labelColor = _dueDateColor(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DUE DATE',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                // Pulls the due date from the task map and formats it for display
                child: Text(
                  _formatDueDate(widget.task['dueDate']),
                  style: const TextStyle(fontSize: 14.0),
                ),
              ),
              const SizedBox(width: 12.0),
              // Only show the status pill if there's actually a label to show.
              // If the task is far out, label is '' and we show nothing.
              if (label.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(label,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Hands the phone number URI to the OS, which shows the native "call?" prompt.
  // Marked async because launchUrl is a Future — it waits for the OS to respond.
  Future<void> _callContact() async {
    final phone = widget.client['phone'];
    if (phone == null || phone.isEmpty) return;

    // Uri(scheme: 'tel') is what tells the OS this is a phone call, not a web link.
    // The OS reads the scheme, finds the Phone app, and pre-fills the number.
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  // Shows a dialog with the contact's phone number.
  // Tapping the number itself triggers the OS call prompt via _callContact.
  void _showCallDialog() {
    final phone = widget.client['phone'];

    // No number on file — show a quick notice and skip the dialog entirely
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF13161E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // shrink the dialog to fit its content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Call',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),

              // The phone number itself is the tap target.
              // Green + underline signals to the user that it's tappable.
              GestureDetector(
                onTap: () {
                  // Close the dialog first, then open the dialer.
                  // If we open the dialer without closing first, the dialog
                  // would still be sitting behind the call screen.
                  Navigator.pop(ctx);
                  _callContact();
                },
                child: Text(phone,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4ADE80),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF4ADE80),
                  ),
                ),
              ),

              const SizedBox(height: 24.0),
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

  Widget _buildDescriptionSection() {
    // Pull the description out of the task map.
    // If nobody filled one in, we fall back to null and show a placeholder.
    final description = widget.task['description'];
    final hasDescription = description != null && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DESCRIPTION',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10.0),
          // Show the actual text if there is one, muted placeholder if not.
          // height: 1.6 adds extra line spacing so multi-line descriptions
          // are easier to read than the default tight line height.
          Text(
            hasDescription ? description : 'No description added',
            style: TextStyle(
              fontSize: 14.0,
              height: 1.6,
              // Muted color for the placeholder so it doesn't look like real content
              color: hasDescription ? null : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTagsSection() {
    final serviceStr = widget.client['service'];

    // The form joins selected services with ', ' before saving — split it back
    // into a list so we can render each tag as its own pill.
    final tags = (serviceStr != null && serviceStr.isNotEmpty)
        ? serviceStr.split(', ').where((t) => t.isNotEmpty).toList()
        : <String>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CONTACT'S TAGS",
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10.0),
          if (tags.isEmpty)
            // Contact has no services on file — show a placeholder instead of
            // an empty gap that would look like a broken section.
            const Text('No tags added',
              style: TextStyle(fontSize: 14.0, color: Color(0xFF64748B)),
            )
          else
            // Wrap is like a Row that knows how to wrap to the next line.
            // A Row would overflow if the pills don't all fit — Wrap just keeps going.
            Wrap(
              spacing: 8.0,    // horizontal gap between pills on the same line
              runSpacing: 8.0, // vertical gap when the pills spill onto a new line
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(tag,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4ADE80),
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _linkedContact() {
    final clientName = widget.client['name'] ?? widget.task['clientName'] ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LINKED CONTACT',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              // Material + InkWell makes just the text tappable with a ripple effect.
              // Without Material as a parent, InkWell has no surface to paint the
              // ripple on and it won't show up.
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6.0),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passes the full client map so ClientDetailPage has all its data
                      builder: (_) => ClientDetailPage(client: widget.client),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(clientName,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        // Green signals this is tappable, consistent with other links in the app
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Call icon — tapping opens the device phone dialer with the number pre-filled.
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _showCallDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_outlined,
                      color: Color(0xFF4ADE80),
                      size: 18.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D12),
        elevation: 0,
        // 'leading' is the slot on the LEFT side of the AppBar.
        // Flutter would put a default back arrow here, but we override it
        // so we control exactly what it looks like and does.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          // '??' is the null-safety fallback operator.
          // If task['title'] is null, use 'Task' instead of crashing.
          widget.task['title'] ?? 'Task',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // 'actions' is the slot on the RIGHT side of the AppBar.
        // It takes a list so you can have multiple buttons — we only need one.
        actions: [
          // PopupMenuButton is a built-in Flutter widget that renders the ⋮ icon
          // and handles showing/hiding the dropdown entirely on its own.
          //
          // The <String> in PopupMenuButton<String> is the type of 'value'
          // that each menu item holds. When the user picks one, Flutter takes
          // that item's value and passes it to onSelected.
          // Using String here means onSelected receives a String — we compare
          // it against our constants to know which option was picked.
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            color: const Color(0xFF1A1E2A),
            icon: const Icon(Icons.more_vert),
            // itemBuilder runs when the menu opens, not when the page loads.
            // It returns the list of options to display.
            itemBuilder: (context) => [
              const PopupMenuItem(value: _menuComplete,   child: Text('Complete Task')),
              const PopupMenuItem(value: _menuEdit,       child: Text('Edit')),
              const PopupMenuItem(value: _menuReschedule, child: Text('Reschedule')),
              const PopupMenuItem(value: _menuContact,    child: Text('View Contact')),
              const PopupMenuItem(value: _menuArchive,    child: Text('Archive')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskNameSection(),
            _buildDueDateSection(),
            _linkedContact(),
            _buildDescriptionSection(),
            _buildContactTagsSection(),
          ],
        ),
      ),
    );
  }
}
