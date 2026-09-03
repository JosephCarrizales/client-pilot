import 'package:flutter/material.dart';

// Full-page form for changing the user's password.
// Has its own Scaffold because it's pushed on top of the nav stack,
// not embedded as a bottom nav tab.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  // GlobalKey lets us call _formKey.currentState!.validate() from the button,
  // which triggers all the validators at once and shows inline error messages.
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();

  // Controls whether each field hides or shows its text.
  // Each field has its own toggle so users can check one without revealing all.
  bool _currentObscured = true;
  bool _newObscured     = true;
  bool _confirmObscured = true;

  @override
  void dispose() {
    // Always dispose controllers — they hold resources outside Flutter's widget tree.
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    // validate() runs every field's validator and returns false if any fail.
    // If they all pass, proceed.
    if (!_formKey.currentState!.validate()) return;

    // TODO: call auth API to actually update the password
    // For now, show a success message and go back.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully'),
        backgroundColor: Color(0xFF4ADE80),
      ),
    );
    Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Back arrow is added automatically by Scaffold when you push this page
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        // Scrollable so the keyboard doesn't push content out of view
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Current password — required, no length check since we don't know
              // what their existing password looks like
              _buildPasswordField(
                controller: _currentController,
                label: 'Current Password',
                obscured: _currentObscured,
                onToggle: () => setState(() => _currentObscured = !_currentObscured),
                validator: (val) =>
                  (val == null || val.isEmpty) ? 'Please enter your current password' : null,
              ),
              const SizedBox(height: 24.0),

              // New password — must be at least 8 characters
              _buildPasswordField(
                controller: _newController,
                label: 'New Password',
                obscured: _newObscured,
                onToggle: () => setState(() => _newObscured = !_newObscured),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter a new password';
                  if (val.length < 8) return 'Must be at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              // Confirm — must match what was typed in the New Password field
              _buildPasswordField(
                controller: _confirmController,
                label: 'Confirm New Password',
                obscured: _confirmObscured,
                onToggle: () => setState(() => _confirmObscured = !_confirmObscured),
                validator: (val) => val != _newController.text
                    ? 'Passwords do not match'
                    : null,
              ),

              const SizedBox(height: 40.0),

              // Full-width save button — picks up the green style from main.dart's theme
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field helper ──────────────────────────────────────────────────────────
  // All three password fields look the same — only the label, controller,
  // obscured state, and validator differ, so we build them from one method.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscured,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscured,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        // Eye icon lets users reveal / hide the field individually
        suffixIcon: IconButton(
          icon: Icon(
            obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF64748B),
            size: 20.0,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
