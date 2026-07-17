import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddContactForm extends StatefulWidget {
  const AddContactForm({super.key});

  @override
  State<AddContactForm> createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {

  // ── Basic info ──────────────────────────────────────────────────────────────
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _emailController   = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController   = TextEditingController();
  final _notesController   = TextEditingController();

  bool _nameTouched  = false;
  bool _phoneTouched = false;
  // (123) 456-7890 is exactly 14 chars after PhoneInputFormatter runs
  bool get _isPhoneComplete => _phoneController.text.length == 14;
  bool get _isNameValid     => _nameController.text.trim().isNotEmpty;

  // ── Service type ────────────────────────────────────────────────────────────
  // Stored in state for now; will move to a database later.
  // We mutate this list when the user creates a custom service so it persists
  // across multiple contacts added in the same session.
  final List<String> _masterServices = [
    'Lawn Mowing', 'Hedge Trimming', 'Leaf Cleanup',
    'Pressure Washing', 'Irrigation Check', 'Snow Removal',
  ];
  final List<String> _selectedServices = [];
  final _serviceSearchController = TextEditingController();
  final _serviceFocusNode        = FocusNode();
  bool _showServiceDropdown      = false;

  // Excludes already-selected services and filters by whatever is typed.
  List<String> get _filteredServices {
    final query = _serviceSearchController.text.toLowerCase();
    return _masterServices
        .where((s) => !_selectedServices.contains(s))
        .where((s) => query.isEmpty || s.toLowerCase().contains(query))
        .toList();
  }

  // When this is true the "Add as new service" option is hidden.
  bool get _typedServiceAlreadyExists {
    final query = _serviceSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return _masterServices.any((s) => s.toLowerCase() == query);
  }

  void _selectService(String service) {
    setState(() {
      _selectedServices.add(service);
      _serviceSearchController.clear();
      _showServiceDropdown = false;
    });
    _serviceFocusNode.unfocus();
  }

  void _addTypedService() {
    final name = _serviceSearchController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _masterServices.add(name);    // add to master list so it appears for future contacts
      _selectedServices.add(name);
      _serviceSearchController.clear();
      _showServiceDropdown = false;
    });
    _serviceFocusNode.unfocus();
  }

  void _removeService(String service) =>
      setState(() => _selectedServices.remove(service));

  // ── Schedule ────────────────────────────────────────────────────────────────
  static const _schedulePresets = ['Weekly', 'Bi-weekly', 'Monthly', 'One-time', 'Custom'];
  String?  _selectedSchedule;
  DateTime? _startDate;
  final _customScheduleController = TextEditingController();

  String get _scheduleDisplayText {
    if (_selectedSchedule == null) return '';
    final label = (_selectedSchedule == 'Custom' &&
            _customScheduleController.text.trim().isNotEmpty)
        ? _customScheduleController.text.trim()
        : _selectedSchedule!;
    if (_startDate == null) return label;
    return '$label starting ${_formatDate(_startDate!)}';
  }

  // Not using the intl package to avoid adding a dependency just for date formatting.
  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // theme the date picker to match the app's dark surface colors
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
    if (picked != null && mounted) {
      setState(() => _startDate = picked);
    }
  }

  // Sets the selected schedule first so the UI updates immediately,
  // then opens the date picker — they feel like one action to the user.
  Future<void> _selectSchedule(String schedule) async {
    setState(() => _selectedSchedule = schedule);
    await _pickDate();
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _serviceFocusNode.addListener(() {
      if (_serviceFocusNode.hasFocus) {
        setState(() => _showServiceDropdown = true);
      } else {
        // The 150ms delay gives a dropdown item's onTap time to fire before
        // the dropdown disappears — without it the dropdown hides on finger-down
        // and the tap never registers.
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showServiceDropdown = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _serviceSearchController.dispose();
    _serviceFocusNode.dispose();
    _customScheduleController.dispose();
    super.dispose();
  }

  // ── Save ────────────────────────────────────────────────────────────────────
  void _saveContact() {
    setState(() {
      _nameTouched  = true;
      _phoneTouched = true;
    });
    if (!_isNameValid || !_isPhoneComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Color(0xFFF87171),
        ),
      );
      return;
    }
    final newClient = {
      'name':     _nameController.text.trim(),
      'phone':    _phoneController.text,
      'email':    _emailController.text.trim(),
      'address':  _addressController.text.trim(),
      'service':  _selectedServices.join(', '),
      'schedule': _scheduleDisplayText,
      'price':    _priceController.text.trim(),
      'notes':    _notesController.text.trim(),
      'status':   'Pending',
    };
    Navigator.pop(context, newClient);
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Contact',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveContact,
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
            _buildBasicInfoSection(),
            const SizedBox(height: 24.0),
            _buildServiceSection(),
            const SizedBox(height: 24.0),
            _buildScheduleAndPriceSection(),
            const SizedBox(height: 24.0),
            _buildNotesSection(),
            const SizedBox(height: 32.0),
            _buildSaveButton(),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  // ── Section: Basic Information ──────────────────────────────────────────────
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Basic Information'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13161E),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              if (_nameTouched && !_isNameValid) _buildFieldError('Full name is required'),
              _buildDivider(),
              _buildPhoneField(),
              if (_phoneTouched && !_isPhoneComplete)
                _buildFieldError('Please enter a complete phone number'),
              _buildDivider(),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildDivider(),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      onChanged: (_) => setState(() => _nameTouched = true),
      decoration: InputDecoration(
        label: _requiredLabel('Full Name'),
        prefixIcon: Icon(
          Icons.person_outline,
          color: _nameTouched && !_isNameValid
              ? const Color(0xFFF87171)
              : const Color(0xFF64748B),
          size: 20.0,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [PhoneInputFormatter()],
      onChanged: (_) => setState(() => _phoneTouched = true),
      decoration: InputDecoration(
        label: _requiredLabel('Phone Number'),
        prefixIcon: Icon(
          Icons.phone_outlined,
          color: _phoneTouched && !_isPhoneComplete
              ? const Color(0xFFF87171)
              : const Color(0xFF64748B),
          size: 20.0,
        ),
        hintText: '(123) 456-7890',
        hintStyle: TextStyle(
          color: const Color(0xFF64748B).withValues(alpha: 0.5),
          fontSize: 14.0,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  // RichText lets us mix the grey label with the red asterisk in one widget.
  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFF87171), fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldError(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 52.0, bottom: 8.0),
      child: Text(message,
        style: const TextStyle(color: Color(0xFFF87171), fontSize: 11.0),
      ),
    );
  }

  // ── Section: Service Type ───────────────────────────────────────────────────
  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Service Type'),
        // Selected tags + search field live in the same surface container.
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13161E),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedServices.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: _selectedServices.map(_buildServiceTag).toList(),
                  ),
                ),
              TextField(
                controller: _serviceSearchController,
                focusNode: _serviceFocusNode,
                onChanged: (_) => setState(() {}), // refilter dropdown on each keystroke
                decoration: InputDecoration(
                  labelText: _selectedServices.isEmpty
                      ? 'Search or add services...'
                      : 'Add another service...',
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 20.0),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
              ),
            ],
          ),
        ),
        // Dropdown renders outside the container so it isn't clipped.
        if (_showServiceDropdown) _buildServiceDropdown(),
      ],
    );
  }

  Widget _buildServiceTag(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(service,
            style: const TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            onTap: () => _removeService(service),
            child: const Icon(Icons.close, size: 14.0, color: Color(0xFF4ADE80)),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDropdown() {
    final options  = _filteredServices;
    final query    = _serviceSearchController.text.trim();
    final showAdd  = !_typedServiceAlreadyExists && query.isNotEmpty;

    if (options.isEmpty && !showAdd) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E2A),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFF252836)),
      ),
      child: Column(
        children: [
          ...options.asMap().entries.map((entry) {
            final isLast = entry.key == options.length - 1 && !showAdd;
            return Column(
              children: [
                _buildDropdownRow(
                  label: entry.value,
                  icon: Icons.check_circle_outline,
                  onTap: () => _selectService(entry.value),
                ),
                if (!isLast) _buildDivider(),
              ],
            );
          }),
          if (showAdd) ...[
            if (options.isNotEmpty) _buildDivider(),
            _buildDropdownRow(
              label: 'Add "$query" as new service',
              icon: Icons.add_circle_outline,
              iconColor: const Color(0xFF4ADE80),
              textColor: const Color(0xFF4ADE80),
              onTap: _addTypedService,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 18.0, color: iconColor ?? const Color(0xFF64748B)),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(label,
                  style: TextStyle(fontSize: 14.0, color: textColor ?? Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section: Schedule & Price ───────────────────────────────────────────────
  Widget _buildScheduleAndPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Schedule & Price'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13161E),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frequency',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.0),
                    ),
                    const SizedBox(height: 10.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _schedulePresets.map(_buildSchedulePresetTag).toList(),
                    ),
                    // Only appears when the user picks "Custom".
                    if (_selectedSchedule == 'Custom') ...[
                      const SizedBox(height: 12.0),
                      _buildCustomScheduleInput(),
                    ],
                    // Shows the final composed label once a preset + date are chosen.
                    if (_scheduleDisplayText.isNotEmpty) ...[
                      const SizedBox(height: 12.0),
                      _buildScheduleResult(),
                    ],
                  ],
                ),
              ),
              _buildDivider(),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [PriceInputFormatter()],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedulePresetTag(String label) {
    final isSelected = _selectedSchedule == label;
    return GestureDetector(
      onTap: () => _selectSchedule(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4ADE80).withValues(alpha: 0.2)
              : const Color(0xFF252836),
          borderRadius: BorderRadius.circular(20.0),
          // border only appears when selected to signal the active state
          border: Border.all(
            color: isSelected ? const Color(0xFF4ADE80) : Colors.transparent,
          ),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomScheduleInput() {
    return TextField(
      controller: _customScheduleController,
      onChanged: (_) => setState(() {}), // update _scheduleDisplayText as user types
      decoration: InputDecoration(
        hintText: 'e.g. Every 3 weeks, Twice a month...',
        hintStyle: TextStyle(
          color: const Color(0xFF64748B).withValues(alpha: 0.7),
          fontSize: 13.0,
        ),
        filled: true,
        fillColor: const Color(0xFF0B0D12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF252836)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF252836)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF4ADE80)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      ),
    );
  }

  Widget _buildScheduleResult() {
    return Row(
      children: [
        const Icon(Icons.event_available_outlined,
          size: 16.0, color: Color(0xFF4ADE80)),
        const SizedBox(width: 6.0),
        Expanded(
          child: Text(_scheduleDisplayText,
            style: const TextStyle(
              color: Color(0xFF4ADE80),
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Lets the user correct the date without re-tapping the schedule preset.
        GestureDetector(
          onTap: _pickDate,
          child: Text(
            _startDate != null ? 'Change date' : 'Pick start date',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.0),
          ),
        ),
      ],
    );
  }

  // ── Section: Notes ──────────────────────────────────────────────────────────
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notes'),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13161E),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: _buildTextField(
            controller: _notesController,
            label: 'Add notes about this client...',
            icon: Icons.note_outlined,
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        onPressed: _saveContact,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ADE80),
          foregroundColor: const Color(0xFF0B0D12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        child: const Text('Save Contact',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14.0),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20.0),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Color(0xFF252836),
      thickness: 1.0,
      height: 1.0,
      indent: 16.0,
    );
  }
}

// Intercepts keypresses and reformats digits into (123) 456-7890 as the user types.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) return oldValue;

    String formatted = '';
    if (digits.isNotEmpty) {
      formatted = '(${digits.substring(0, digits.length >= 3 ? 3 : digits.length)}';
    }
    if (digits.length >= 3) {
      formatted += ') ${digits.substring(3, digits.length >= 6 ? 6 : digits.length)}';
    }
    if (digits.length >= 6) {
      formatted += '-${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Prepends $ automatically and strips any non-digit characters.
// Clears completely when the user deletes back to nothing — no orphaned $.
class PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = '\$$digits';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
