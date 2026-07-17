import 'package:flutter/material.dart';

// ClientDetailPage receives a Map<String, String> of client data.
// Any field that is absent from the map simply won't render — no crashes.
class ClientDetailPage extends StatelessWidget {
  final Map<String, String> client;

  const ClientDetailPage({super.key, required this.client});

  // Derives color from payment status string — used in avatar, pill, and section accents.
  Color _statusColor(String? status) {
    switch (status) {
      case 'Paid':    return const Color(0xFF4ADE80);
      case 'Pending': return const Color(0xFFF59E0B);
      case 'Overdue': return const Color(0xFFF87171);
      default:        return const Color(0xFF64748B);
    }
  }

  // Returns first letter of first and last name. 'Tom Harrington' → 'TH'
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  // Renders a section header label in the muted slate color used across the app.
  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Renders a single label + value row inside a section container.
  // Returns null if value is null or empty so callers can skip rendering.
  Widget? _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.0, // fixed width keeps all values left-aligned
            child: Text(label,
              style: const TextStyle(
                fontSize: 13.0,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wraps a list of info rows in the standard dark surface container.
  // Filters out null rows so missing fields leave no gap or empty space.
  Widget _sectionCard(String header, List<Widget?> rows) {
    // remove null entries (fields that weren't provided in the data map)
    final visibleRows = rows.whereType<Widget>().toList();
    if (visibleRows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13161E),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(header),
          // insert a thin divider between rows, but not after the last one
          ...visibleRows.asMap().entries.map((entry) {
            final isLast = entry.key == visibleRows.length - 1;
            return Column(
              children: [
                entry.value,
                if (!isLast)
                  const Divider(color: Color(0xFF252836), thickness: 1.0, height: 1.0),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = client['status'];
    final statusColor = _statusColor(status);
    final name = client['name'] ?? 'Unknown Client';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D12),
        // leading replaces the default back button with a styled circular icon
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Client Details',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /*  ── HERO HEADER: avatar + name + status pill ──────────────────  */

            Center(
              child: Column(
                children: [
                  // Large initials avatar — tinted with the status color
                  CircleAvatar(
                    radius: 36.0,
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Text(
                      _initials(name),
                      style: TextStyle(
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(name,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Payment status pill — same pill style used on list tiles
                  if (status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(status,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            /*  ── ACTION BUTTONS: Call / Text / Email ───────────────────────  */

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF13161E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(Icons.phone_outlined, 'Call'),
                  _verticalDivider(),
                  _actionButton(Icons.chat_bubble_outline, 'Text'),
                  _verticalDivider(),
                  _actionButton(Icons.mail_outline, 'Email'),
                ],
              ),
            ),

            const SizedBox(height: 12.0),

            /*  ── CONTACT INFO SECTION ──────────────────────────────────────  */

            _sectionCard('Contact Info', [
              _infoRow('Phone',   client['phone']),
              _infoRow('Email',   client['email']),
              _infoRow('Address', client['address']),
            ]),

            /*  ── SERVICE DETAILS SECTION ───────────────────────────────────  */

            _sectionCard('Service Details', [
              _infoRow('Service',  client['service']),
              _infoRow('Schedule', client['schedule']),
              _infoRow('Price',    client['price'] ?? client['amount']),
              _infoRow('Last Job', client['time']),
            ]),

            /*  ── NOTES SECTION ─────────────────────────────────────────────  */

            if (client['notes'] != null && client['notes']!.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF13161E),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('Notes'),
                    Text(client['notes']!,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Color(0xFF94A3B8),
                        height: 1.5, // line-height for readability on multi-line notes
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  // Builds one of the three circular action buttons (Call / Text / Email).
  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4ADE80), size: 22.0),
        ),
        const SizedBox(height: 6.0),
        Text(label,
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // Thin vertical line between action buttons — pure visual separator.
  Widget _verticalDivider() {
    return Container(
      width: 1.0,
      height: 40.0,
      color: const Color(0xFF252836),
    );
  }
}
