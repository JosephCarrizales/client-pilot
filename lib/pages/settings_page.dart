import 'package:flutter/material.dart';
import 'package:client_pilot/pages/landing_page.dart';
import 'package:client_pilot/pages/change_password_page.dart';

// No Scaffold here — SettingsPage lives inside HomePage's Scaffold as a
// bottom nav tab, just like ContactsPage, TasksPage, and NotificationsPage.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  // Notification toggle states — all on by default.
  // These are local for now; a real app would persist them to device storage.
  bool _pushEnabled   = true;
  bool _taskReminders = true;
  bool _jobAlerts     = true;

  // ── Log Out ───────────────────────────────────────────────────────────────
  // Shows a confirmation dialog before doing anything — log out is irreversible.
  void _confirmLogOut() {
    showDialog(
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

              const Text('Log Out?',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              const Text('You will be returned to the login screen.',
                style: TextStyle(fontSize: 13.0, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24.0),

              // Confirm — red because it's a destructive action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // pushAndRemoveUntil clears the entire nav stack (HomePage,
                    // LoginPage, etc.) so the user can't swipe back in after logging out.
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LandingPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF87171),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
              const SizedBox(height: 8.0),

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

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Matches the outer padding used on TasksPage and NotificationsPage
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Page header — same style as every other tab page
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0, left: 8.0, right: 8.0),
            child: Text('Settings',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),

          // Wrap content in a scroll view so nothing clips on smaller screens
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Account ───────────────────────────────────────────────
                  _buildSectionLabel('Account'),
                  _buildSection([
                    // Profile row — avatar, name, email
                    _buildProfileRow(),
                    _buildDivider(),
                    _buildNavRow(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                      ),
                    ),
                    _buildDivider(),
                    // Log Out is red to signal it's a destructive action
                    _buildNavRow(
                      icon: Icons.logout,
                      label: 'Log Out',
                      iconColor: const Color(0xFFF87171),
                      labelColor: const Color(0xFFF87171),
                      onTap: _confirmLogOut,
                    ),
                  ]),

                  const SizedBox(height: 24.0),

                  // ── Notifications ─────────────────────────────────────────
                  _buildSectionLabel('Notifications'),
                  _buildSection([
                    _buildToggleRow(
                      icon: Icons.notifications_outlined,
                      label: 'Push Notifications',
                      value: _pushEnabled,
                      // Master switch — toggling this off greys out the rows below
                      onChanged: (val) => setState(() => _pushEnabled = val),
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      icon: Icons.assignment_outlined,
                      label: 'Task Due Reminders',
                      // Can only be changed when push is enabled — pass null to disable
                      value: _pushEnabled && _taskReminders,
                      onChanged: _pushEnabled
                          ? (val) => setState(() => _taskReminders = val)
                          : null,
                    ),
                    _buildDivider(),
                    _buildToggleRow(
                      icon: Icons.event_outlined,
                      label: 'Upcoming Job Alerts',
                      value: _pushEnabled && _jobAlerts,
                      onChanged: _pushEnabled
                          ? (val) => setState(() => _jobAlerts = val)
                          : null,
                    ),
                  ]),

                  const SizedBox(height: 24.0),

                  // ── Support ───────────────────────────────────────────────
                  _buildSectionLabel('Support'),
                  _buildSection([
                    _buildNavRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      // Version number shows on the right before the chevron
                      trailing: const Text('v1.0.0',
                        style: TextStyle(fontSize: 13.0, color: Color(0xFF64748B)),
                      ),
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildNavRow(
                      icon: Icons.feedback_outlined,
                      label: 'Send Feedback',
                      onTap: () {},
                    ),
                  ]),

                  // Bottom breathing room so the last card doesn't sit flush with
                  // the nav bar
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section helpers ───────────────────────────────────────────────────────

  // Small uppercase label above each group (e.g. 'ACCOUNT', 'NOTIFICATIONS').
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
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

  // Wraps a list of rows in one rounded surface card — same look as notification cards.
  Widget _buildSection(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13161E),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(children: rows),
    );
  }

  // Thin separator line between rows. Indent keeps it from touching the left edge.
  Widget _buildDivider() {
    return const Divider(
      height: 1.0,
      thickness: 1.0,
      color: Color(0xFF252836),
      indent: 16.0,
    );
  }

  // Profile row — shows the user's avatar initials, business name, and email.
  // No chevron because it's informational rather than a navigation target.
  Widget _buildProfileRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Circle avatar with initials — replace with a real image later
          Container(
            width: 44.0,
            height: 44.0,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1E2A),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('JC',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ADE80),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Joe's Landscaping",
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.0),
              Text('josephcarrizales13@gmail.com',
                style: TextStyle(fontSize: 12.0, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tappable row with an icon on the left and a chevron on the right.
  // 'trailing' lets callers slot in an optional widget before the chevron
  // (used for the version number on the About row).
  Widget _buildNavRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    Color iconColor  = const Color(0xFF64748B),
    Color labelColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, size: 20.0, color: iconColor),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(label,
                  style: TextStyle(fontSize: 14.0, color: labelColor),
                ),
              ),
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 4.0),
              ],
              // Chevron color matches the label so red rows stay fully red
              Icon(Icons.chevron_right, size: 18.0, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }

  // Row with a Switch on the right instead of a chevron.
  // onChanged is nullable — passing null disables the switch and greys it out.
  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    // Disabled when onChanged is null (e.g. push notifications is turned off)
    final active = onChanged != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0,
            // Greyed out further when the parent toggle is off
            color: active ? const Color(0xFF64748B) : const Color(0xFF3A3F4E),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(label,
              style: TextStyle(
                fontSize: 14.0,
                color: active ? Colors.white : const Color(0xFF3A3F4E),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            // Green when active, dim surface color when off
            activeThumbColor: const Color(0xFF4ADE80),
            inactiveTrackColor: const Color(0xFF1A1E2A),
          ),
        ],
      ),
    );
  }
}
