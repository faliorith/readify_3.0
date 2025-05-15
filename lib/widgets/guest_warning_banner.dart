import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class GuestWarningBanner extends StatelessWidget {
  const GuestWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      width: double.infinity,
      color: Colors.amber[100],
      child: Row(
        children: [
          const Icon(Icons.warning_amber, size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.guestWarningMessage,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/register'),
            child: Text(
              l10n.register,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}