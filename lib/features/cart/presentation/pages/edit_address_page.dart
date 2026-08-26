import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // Sheet height tracking
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isExpanded = false;

  // Selected location
  String _selectedLocationName = 'Home';
  String _selectedLocationAddress = '123 Street, Phnom Penh, Cambodia';

  // Preset saved locations
  final List<Map<String, String>> _savedLocations = [
    {'name': 'Home', 'address': '123 Street, Phnom Penh, Cambodia'},
    {'name': 'Office', 'address': '456 Monivong Blvd, Phnom Penh'},
    {'name': 'University', 'address': 'Russian Blvd, Phnom Penh'},
    {'name': 'Gym', 'address': '789 Mao Tse Toung, Phnom Penh'},
    {'name': 'Coffee Shop', 'address': 'Norodom Blvd, BKK1, Phnom Penh'},
  ];

  @override
  void initState() {
    super.initState();
    _locationController.text = _selectedLocationAddress;

    // Listen to sheet position changes to toggle button text
    _sheetController.addListener(() {
      final isNowExpanded = _sheetController.size > 0.55;
      if (isNowExpanded != _isExpanded) {
        setState(() {
          _isExpanded = isNowExpanded;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _floorController.dispose();
    _instructionsController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppDimensions.md),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Select Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Scrollable location list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _savedLocations.length,
                      itemBuilder: (context, index) {
                        final location = _savedLocations[index];
                        final isSelected = location['address'] == _selectedLocationAddress;

                        return ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                          title: Text(
                            location['name']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          subtitle: Text(
                            location['address']!,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.primary)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedLocationName = location['name']!;
                              _selectedLocationAddress = location['address']!;
                              _locationController.text = _selectedLocationAddress;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onSave() {
    Get.back(result: {
      'name': _selectedLocationName,
      'address': _selectedLocationAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Static bounds: min ~35%, max ~90% of screen
    const double minChildSize = 0.35;
    const double maxChildSize = 0.90;
    const double initialChildSize = 0.45;

    return Scaffold(
      body: Stack(
        children: [
          // â”€â”€ Full-screen Map Placeholder â”€â”€
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8F5E9),
              child: Stack(
                children: [
                  // Simulated map grid lines
                  ...List.generate(10, (i) {
                    return Positioned(
                      top: i * (screenHeight / 10),
                      left: 0,
                      right: 0,
                      child: Container(height: 0.5, color: Colors.green.withValues(alpha: 0.2)),
                    );
                  }),
                  ...List.generate(6, (i) {
                    final width = MediaQuery.of(context).size.width;
                    return Positioned(
                      left: i * (width / 6),
                      top: 0,
                      bottom: 0,
                      child: Container(width: 0.5, color: Colors.green.withValues(alpha: 0.2)),
                    );
                  }),

                  // Center pin
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            _selectedLocationName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const Icon(Icons.location_on, color: Colors.red, size: 48),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Draggable Bottom Sheet â”€â”€
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppDimensions.lg),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // â”€â”€ Location TextField â”€â”€
                    // Row: map icon + current location text + edit icon
                    TextField(
                      controller: _locationController,
                      readOnly: true,
                      onTap: _showLocationPicker,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          onPressed: _showLocationPicker,
                        ),
                        hintText: 'current location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // â”€â”€ Floor TextField â”€â”€
                    TextField(
                      controller: _floorController,
                      decoration: InputDecoration(
                        hintText: 'floor',
                        prefixIcon: const Icon(Icons.layers_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // â”€â”€ Delivery Instructions TextField â”€â”€
                    TextField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Delivery instructions (e.g. ring the bell)',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.note_outlined),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // â”€â”€ Dynamic Button â”€â”€
                    // Scroll UP (expanded) â†’ "Save and Continue"
                    // Scroll DOWN (collapsed) â†’ "Apply Changes"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text(
                          _isExpanded ? 'Save and Continue' : 'Apply Changes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
