import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/repositories/settings_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() {
    return _SettingsViewState();
  }
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _patronNumberController = TextEditingController();
  bool _receiveNewsletter = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    // controllers must be disposed to free their resources
    _addressController.dispose();
    _emailController.dispose();
    _patronNumberController.dispose();
    super.dispose();
  }

  // fill the form with the last saved settings
  void _loadSaved() {
    final UserSettings saved = SettingsRepository.instance.settings;
    _addressController.text = saved.address;
    _emailController.text = saved.email;
    _patronNumberController.text = saved.patronNumber;
    _receiveNewsletter = saved.receiveNewsletter;
  }

  void _saveSettings() {
    SettingsRepository.instance.save(
      UserSettings(
        // no name field on this form, so keep whatever name is already saved
        name: SettingsRepository.instance.settings.name,
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        receiveNewsletter: _receiveNewsletter,
        patronNumber: _patronNumberController.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  void _cancel() {
    // throw away unsaved changes
    setState(() {
      _loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Settings',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Address'),
            TextField(
              key: const Key('address-field'),
              controller: _addressController,
              minLines: 4,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              style: _fieldTextStyle,
              decoration: _fieldDecoration.copyWith(
                suffixIcon: IconButton(
                  key: const Key('clear-address'),
                  icon: const Icon(Icons.close, color: cinemaFontMuted),
                  onPressed: () {
                    _addressController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Email Address'),
            TextField(
              key: const Key('email-field'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: _fieldTextStyle,
              decoration: _fieldDecoration,
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Patron Number'),
            TextField(
              key: const Key('patron-number-field'),
              controller: _patronNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: _fieldTextStyle,
              decoration: _fieldDecoration,
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Preferences'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Receive news by email',
                  style: TextStyle(color: cinemaFontWhite, fontSize: 16),
                ),
                Switch(
                  value: _receiveNewsletter,
                  activeThumbColor: cinemaBrand,
                  onChanged: (bool value) {
                    setState(() {
                      _receiveNewsletter = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cinemaSurface,
                      foregroundColor: cinemaFontWhite,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // square corners
                      ),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  height: 48,
                  child: PrimaryButton(
                    label: 'SAVE SETTINGS',
                    onPressed: _saveSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _fieldTextStyle = TextStyle(
  color: cinemaFontWhite,
  fontSize: 18,
  height: 1.5,
);

const InputDecoration _fieldDecoration = InputDecoration(
  filled: true,
  fillColor: cinemaSurface,
  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: Color(0xFF3A4050)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: cinemaBrand),
  ),
);

// grey heading above each field, e.g. "Address"
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: cinemaFontMuted,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
