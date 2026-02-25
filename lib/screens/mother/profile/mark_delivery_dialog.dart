import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';

class MarkDeliveryDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const MarkDeliveryDialog({super.key, required this.onSuccess});

  @override
  State<MarkDeliveryDialog> createState() => _MarkDeliveryDialogState();
}

class _MarkDeliveryDialogState extends State<MarkDeliveryDialog> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Delivery details
  DateTime _deliveryDate = DateTime.now();
  String _deliveryType = 'normal';

  // Baby details
  final _babyNameController = TextEditingController();
  String _babyGender = 'male';
  final _birthWeightController = TextEditingController();
  final _birthLengthController = TextEditingController();

  @override
  void dispose() {
    _babyNameController.dispose();
    _birthWeightController.dispose();
    _birthLengthController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_babyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter baby name')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Mark delivery
      final deliveryRes = await ApiService().post(
        '/mother/me/mark-delivery',
        body: {
          'actual_delivery_date': _deliveryDate.toIso8601String(),
          'delivery_type': _deliveryType,
        },
      );

      if (deliveryRes.statusCode != 200) {
        throw Exception('Failed to mark delivery');
      }

      // Step 2: Create baby profile
      final babyRes = await ApiService().post(
        '/baby/create',
        body: {
          'name': _babyNameController.text.trim(),
          'gender': _babyGender,
          'birth_date': _deliveryDate.toIso8601String(),
          'birth_weight': int.tryParse(_birthWeightController.text) ?? 0,
          'birth_length': double.tryParse(_birthLengthController.text) ?? 0,
        },
      );

      if (babyRes.statusCode != 200 && babyRes.statusCode != 201) {
        throw Exception('Failed to create baby profile');
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text('🎉', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Your baby has arrived!',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Steps indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Delivery'),
                  Container(
                    width: 40,
                    height: 2,
                    color: _currentStep >= 1 ? Colors.pink : Colors.grey[300],
                  ),
                  _buildStepIndicator(1, 'Baby'),
                ],
              ),
              const SizedBox(height: 24),

              // Step content
              if (_currentStep == 0) _buildDeliveryStep(),
              if (_currentStep == 1) _buildBabyStep(),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_currentStep == 0) {
                                setState(() => _currentStep = 1);
                              } else {
                                _submit();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_currentStep == 0 ? 'Next' : 'Complete'),
                    ),
                  ),
                ],
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.pink : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? Colors.pink : Colors.grey[500],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Date',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _deliveryDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _deliveryDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, color: Colors.pink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_deliveryDate),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Delivery Type',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeChip('normal', 'Natural', Iconsax.heart),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeChip(' -section', 'C-Section', Iconsax.hospital),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _deliveryType == value;
    return GestureDetector(
      onTap: () => setState(() => _deliveryType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.pink : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.pink : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Baby Name *',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _babyNameController,
          decoration: InputDecoration(
            hintText: 'Enter baby\'s name',
            prefixIcon: const Icon(Iconsax.user),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderChip('male', 'Boy', '👦'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderChip('female', 'Girl', '👧'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Birth Weight (g)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _birthWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 3200',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Length (cm)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _birthLengthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 50',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderChip(String value, String label, String emoji) {
    final isSelected = _babyGender == value;
    return GestureDetector(
      onTap: () => setState(() => _babyGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'male' ? Colors.blue : Colors.pink).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (value == 'male' ? Colors.blue : Colors.pink)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (value == 'male' ? Colors.blue : Colors.pink)
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
