import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  // The contacts list comes from tasks_page so the user can link one.
  // When we have a real database this goes away — we'll just query it.
  final List<Map<String, String>> contacts;

  const AddTask({super.key, required this.contacts});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {

  // Controllers hold the text field values and survive rebuilds.
  // We dispose them when the page is removed to avoid memory leaks.
  final _nameController        = TextEditingController();
  final _descriptionController = TextEditingController();

  // Tracks whether the user has interacted with the name field.
  // We only show validation errors after the first attempt to save.
  bool _nameTouched = false;

  // Form state — plain instance variables, just setState to update them.
  String               _taskType        = 'Other';
  Map<String, String>? _linkedContact;   // null means no contact linked
  String               _priority        = 'Medium';
  DateTime?            _dueDate;
  TimeOfDay?           _dueTime;
  bool                 _repeats         = false;
  String               _repeatFrequency = 'Weekly'; // pre-selected when repeat is turned on

  static const _repeatOptions = ['Daily', 'Weekly', 'Bi-weekly', 'Monthly'];

  // Low = green, High/Urgent = red, everything else = amber
  Color _priorityColor(String p) {
    switch (p) {
      case 'Low':    return const Color(0xFF4ADE80);
      case 'High':
      case 'Urgent': return const Color(0xFFF87171);
      default:       return const Color(0xFFF59E0B);
    }
  }

  // 'Jul 21, 2026' — avoids importing the intl package just for date formatting
  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // '2:30 PM' — TimeOfDay.format() exists but requires a BuildContext;
  // this helper doesn't so it's easier to call from anywhere.
  String _formatTime(TimeOfDay t) {
    final hour   = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      // Match the app's dark surface colors — without this the picker shows
      // Flutter's default light theme which looks completely wrong here.
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary:   Color(0xFF4ADE80),
            onPrimary: Color(0xFF0B0D12),
            surface:   Color(0xFF13161E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  // Shows the iOS-style spinning wheel picker in a bottom sheet.
  // CupertinoDatePicker fires onDateTimeChanged on every scroll tick, so we
  // use a local variable to capture the final value and only commit it when
  // the user taps Done — avoiding a setState on every tiny movement.
  void _pickTime() {
    // Start the wheel at the currently selected time, or now if nothing is set yet.
    final initial = _dueTime != null
        ? DateTime.now().copyWith(
            hour: _dueTime!.hour,
            minute: _dueTime!.minute,
          )
        : DateTime.now();

    // Tracks what the wheel is showing as the user spins it
    DateTime selected = initial;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13161E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (ctx) => SizedBox(
        height: 300.0,
        child: Column(
          children: [
            // Done button row at the top of the sheet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Commit the final wheel position to the form state, then close
                      setState(() => _dueTime = TimeOfDay.fromDateTime(selected));
                      Navigator.pop(ctx);
                    },
                    child: const Text('Done',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The actual spinning wheel — mode.time shows hours, minutes, and AM/PM
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initial,
                onDateTimeChanged: (dt) => selected = dt,
                // backgroundColor matches the bottom sheet so it looks seamless
                backgroundColor: const Color(0xFF13161E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Opens a searchable dialog so the user can pick a contact to link.
  // Uses StatefulBuilder so the search field can rebuild just the dialog
  // without triggering a setState on the whole form page.
  void _showContactPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        String search = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final filtered = widget.contacts
                .where((c) => c['name']!.toLowerCase().contains(search.toLowerCase()))
                .toList();

            return Dialog(
              backgroundColor: const Color(0xFF13161E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Contact',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12.0),

                    // Search box inside the dialog
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0D12),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: const Color(0xFF252836)),
                      ),
                      child: TextField(
                        autofocus: true,
                        onChanged: (val) => setDialogState(() => search = val),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 18.0),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // ConstrainedBox caps the list height so the dialog doesn't
                    // grow taller than the screen when there are many contacts.
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280.0),
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('No contacts found',
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const Divider(
                                color: Color(0xFF252836),
                                height: 1.0,
                                thickness: 1.0,
                              ),
                              itemBuilder: (_, i) {
                                final c = filtered[i];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8.0),
                                    onTap: () {
                                      // Update the form's linked contact, then close
                                      setState(() => _linkedContact = c);
                                      Navigator.pop(ctx);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (c['service'] != null && c['service']!.isNotEmpty)
                                            Text(c['service']!,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 8.0),
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
            );
          },
        );
      },
    );
  }

  void _saveTask() {
    // Mark name as touched so the red border appears if it's empty
    setState(() => _nameTouched = true);

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task name is required'),
          backgroundColor: Color(0xFFF87171),
        ),
      );
      return;
    }

    // Format as YYYY-MM-DD so DateTime.parse() in tasks_detail_page can read it back.
    // We break out month/day first to avoid nested single quotes inside the string.
    String dueDateStr = '';
    if (_dueDate != null) {
      final m = _dueDate!.month.toString().padLeft(2, '0');
      final d = _dueDate!.day.toString().padLeft(2, '0');
      dueDateStr = '${_dueDate!.year}-$m-$d';
    }

    final newTask = {
      'title':       _nameController.text.trim(),
      'taskType':    _taskType,
      'clientName':  _linkedContact?['name'] ?? '',
      'description': _descriptionController.text.trim(),
      'priority':    _priority,
      'dueDate':     dueDateStr,
      'dueTime':     _dueTime != null ? _formatTime(_dueTime!) : '',
      'repeat':      _repeats ? _repeatFrequency : 'Do Not Repeat',
      'status':      'Pending',
    };

    // Pass the new task back to the tasks page, same pattern as AddContactForm
    Navigator.pop(context, newTask);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Uppercase muted label used above each field section.
  // Same style as every other section header in the app.
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Used for the Do Not Repeat / Repeat toggle and the frequency chips.
  // isSelected controls the green highlight; tapping always calls setState.
  Widget _selectableChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4ADE80).withValues(alpha: 0.15)
              : const Color(0xFF252836),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF4ADE80) : Colors.transparent,
          ),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 13.0,
            color: isSelected ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Task',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save',
              style: TextStyle(
                color: Color(0xFF4ADE80),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── TASK NAME ─────────────────────────────────────────────────────
            _sectionLabel('Task Name'),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                // Red border only after the user tries to save with an empty name
                border: Border.all(
                  color: _nameTouched && _nameController.text.trim().isEmpty
                      ? const Color(0xFFF87171)
                      : const Color(0xFF252836),
                ),
              ),
              child: TextField(
                controller: _nameController,
                onChanged: (_) => setState(() => _nameTouched = true),
                decoration: const InputDecoration(
                  hintText: 'Enter name...',
                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // ── TASK TYPE ─────────────────────────────────────────────────────
            _sectionLabel('Task Type'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF252836)),
              ),
              child: DropdownButton<String>(
                value: _taskType,
                onChanged: (val) => setState(() => _taskType = val!),
                dropdownColor: const Color(0xFF1A1E2A),
                underline: const SizedBox.shrink(), // hides the default underline
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 14.0),
                items: ['Call', 'Text', 'Other'].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
              ),
            ),

            const SizedBox(height: 20.0),

            // ── LINKED TO ─────────────────────────────────────────────────────
            _sectionLabel('Linked To'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF252836)),
              ),
              child: Row(
                children: [
                  // Shows "None" until a contact is picked, then their name
                  _linkedContact == null
                      ? const Text('None',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14.0,
                          ))
                      : Text(_linkedContact!['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          )),
                  const Spacer(),
                  // When a contact IS linked, tapping "Add / Remove" clears it back to None.
                  // When no contact is linked, it opens the picker dialog.
                  GestureDetector(
                    onTap: _linkedContact != null
                        ? () => setState(() => _linkedContact = null)
                        : _showContactPicker,
                    child: const Text('Add / Remove',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            // ── DESCRIPTION ───────────────────────────────────────────────────
            _sectionLabel('Description'),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF252836)),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Add details about this task...',
                  hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
            ),

            const SizedBox(height: 20.0),

            // ── PRIORITY ──────────────────────────────────────────────────────
            _sectionLabel('Priority'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF252836)),
              ),
              child: DropdownButton<String>(
                value: _priority,
                onChanged: (val) => setState(() => _priority = val!),
                dropdownColor: const Color(0xFF1A1E2A),
                underline: const SizedBox.shrink(),
                isExpanded: true,
                // selectedItemBuilder controls how the chosen value looks in the
                // closed dropdown button — colored text to reinforce priority visually.
                selectedItemBuilder: (context) => ['Low', 'Medium', 'High', 'Urgent']
                    .map((p) => Align(
                          alignment: Alignment.centerLeft,
                          child: Text(p,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: _priorityColor(p),
                            ),
                          ),
                        ))
                    .toList(),
                items: ['Low', 'Medium', 'High', 'Urgent'].map((p) {
                  final color = _priorityColor(p);
                  return DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        // Small dot so the color coding is visible even in the list
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(p, style: TextStyle(color: color, fontSize: 14.0)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20.0),

            // ── DUE DATE ──────────────────────────────────────────────────────
            _sectionLabel('Due Date'),
            Row(
              children: [
                // Date picker — left half
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13161E),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: const Color(0xFF252836)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16.0, color: Color(0xFF64748B)),
                          const SizedBox(width: 8.0),
                          Text(
                            _dueDate != null
                                ? _formatDate(_dueDate!)
                                : 'Select date',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: _dueDate != null
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                // Time picker — right half
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13161E),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: const Color(0xFF252836)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 16.0, color: Color(0xFF64748B)),
                          const SizedBox(width: 8.0),
                          Text(
                            _dueTime != null
                                ? _formatTime(_dueTime!)
                                : 'Select time',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: _dueTime != null
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20.0),

            // ── REPEAT ────────────────────────────────────────────────────────
            _sectionLabel('Repeat'),
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF252836)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle row — only two options so chips are simpler than a dropdown
                  Row(
                    children: [
                      _selectableChip('Do Not Repeat', !_repeats,
                          () => setState(() => _repeats = false)),
                      const SizedBox(width: 8.0),
                      _selectableChip('Repeat', _repeats,
                          () => setState(() => _repeats = true)),
                    ],
                  ),
                  // Frequency chips only appear when Repeat is on.
                  // The '...' spread operator flattens the list into the Column children.
                  if (_repeats) ...[
                    const SizedBox(height: 12.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _repeatOptions.map((opt) => _selectableChip(
                        opt,
                        _repeatFrequency == opt,
                        () => setState(() => _repeatFrequency = opt),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32.0),

            // Save button at the bottom so the user doesn't have to scroll back up
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: const Color(0xFF0B0D12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Save Task',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
