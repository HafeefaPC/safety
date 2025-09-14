import 'package:flutter/material.dart';
import '../models/helpline_model.dart';
import '../services/call_service.dart';
import '../utils/constants.dart';

class HelplineCard extends StatelessWidget {
  final HelplineModel helpline;
  final VoidCallback? onTap;

  const HelplineCard({
    super.key,
    required this.helpline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4.0,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(AppConstants.primaryColorValue),
          child: Text(
            helpline.icon,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          helpline.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              helpline.number,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (helpline.description.isNotEmpty)
              Text(
                helpline.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              helpline.category,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.phone,
                color: Color(AppConstants.primaryColorValue),
              ),
              onPressed: () => _makeCall(context),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _makeCall(BuildContext context) async {
    try {
      final success = await CallService.makePhoneCall(helpline.number);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to make phone call'),
            backgroundColor: Color(AppConstants.primaryColorValue),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error making phone call'),
            backgroundColor: Color(AppConstants.primaryColorValue),
          ),
        );
      }
    }
  }
}
