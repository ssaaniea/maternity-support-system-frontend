import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/providers/caregiver_provider.dart';
import 'package:provider/provider.dart';

class AvailabilityToggle extends StatefulWidget {
  const AvailabilityToggle({super.key});

  @override
  State<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends State<AvailabilityToggle> {
  bool _isUpdating = false;

  static const _primaryTeal = Color(0xFF009688);

  @override
  Widget build(BuildContext context) {
    return Consumer<CaregiverProvider>(
      builder: (context, provider, _) {
        final isAvailable = provider.profile?.availability ?? false;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isAvailable ? Iconsax.tick_circle : Iconsax.close_circle,
                      color: isAvailable ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: isAvailable,
                            onChanged: (value) =>
                                _toggleAvailability(value, provider),
                            activeColor: _primaryTeal,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Availability',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAvailable ? 'Accepting' : 'Unavailable',
                style: TextStyle(
                  fontSize: 11,
                  color: isAvailable ? Colors.green : Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleAvailability(
    bool value,
    CaregiverProvider provider,
  ) async {
    setState(() => _isUpdating = true);

    final success = await provider.updateProfile({'availability': value});

    setState(() => _isUpdating = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (value
                      ? 'You are now available for bookings'
                      : 'You are now unavailable')
                : provider.error ?? 'Failed to update availability',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
