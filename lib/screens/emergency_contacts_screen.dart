import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/emergency_action_button.dart';
import '../services/preferences_service.dart';
import '../services/telephony_service.dart';
import '../utils/constants.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<String> _contacts = [];
  final _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _loadContacts() {
    setState(() {
      _contacts = PreferencesService.getEmergencyContacts();
    });
  }

  Future<void> _addContact() async {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) return;

    if (!TelephonyService.isValidPhoneNumber(contact)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid phone number'),
            backgroundColor: Color(AppConstants.primaryColorValue),
          ),
        );
      }
      return;
    }

    final formattedContact = TelephonyService.formatPhoneNumber(contact);
    
    if (_contacts.contains(formattedContact)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact already exists'),
            backgroundColor: Color(AppConstants.warningColorValue),
          ),
        );
      }
      return;
    }

    setState(() {
      _contacts.add(formattedContact);
      _contactController.clear();
    });

    await PreferencesService.saveEmergencyContacts(_contacts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact added successfully'),
          backgroundColor: Color(AppConstants.successColorValue),
        ),
      );
    }
  }

  Future<void> _removeContact(int index) async {
    setState(() {
      _contacts.removeAt(index);
    });

    await PreferencesService.saveEmergencyContacts(_contacts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact removed'),
          backgroundColor: Color(AppConstants.primaryColorValue),
        ),
      );
    }
  }

  Future<void> _testSms() async {
    if (_contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contacts to test'),
            backgroundColor: Color(AppConstants.warningColorValue),
          ),
        );
      }
      return;
    }

    final success = await TelephonyService.sendCustomSms('Test message from Safe Haven app');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Test SMS sent successfully!' : 'Failed to send test SMS'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g., +1234567890 or 1234567890',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _contactController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addContact();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Emergency Contacts',
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              elevation: AppConstants.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add phone numbers that will receive emergency location and "I\'m Safe" messages.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: EmergencyActionButton.safe(
                            text: 'Add Contact',
                            icon: Icons.person_add,
                            onPressed: _showAddContactDialog,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: EmergencyActionButton.warning(
                            text: 'Test SMS',
                            icon: Icons.message,
                            onPressed: _testSms,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contacts List
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contacts,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No emergency contacts added',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap "Add Contact" to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          elevation: AppConstants.cardElevation,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(AppConstants.primaryColorValue),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text('Emergency Contact'),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeContact(index),
                            ),
                            onTap: () {
                              // Copy to clipboard
                              Clipboard.setData(ClipboardData(text: contact));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Phone number copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
