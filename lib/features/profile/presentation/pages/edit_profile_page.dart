import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('edit_profile'.tr),
      ),
      body: Obx(() {
        final user = controller.user.value;
        return _EditProfileBody(
          user: user,
          onSaveProfile: (name, email, phone) {
            if (user != null) {
              final updated = User(
                id: user.id,
                name: name.isNotEmpty ? name : user.name,
                email: email.isNotEmpty ? email : user.email,
                phone: phone.isNotEmpty ? phone : user.phone,
                avatar: user.avatar,
                role: user.role,
                createdAt: user.createdAt,
              );
              controller.user.value = updated;
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().currentUser.value = updated;
              }
            }
            Helpers.showSuccess('profile_edit_notice'.tr);
          },
        );
      }),
    );
  }
}

class _EditProfileBody extends StatefulWidget {
  final User? user;
  final void Function(String name, String email, String phone) onSaveProfile;

  const _EditProfileBody({
    required this.user,
    required this.onSaveProfile,
  });

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        const SizedBox(height: AppDimensions.lg),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: ClipOval(
                  child: (user?.avatar != null && user!.avatar!.isNotEmpty)
                      ? AppNetworkImage(
                          imageUrl: user.avatar,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorWidget: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Helpers.showWarning('update_avatar_hint'.tr),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.xl),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'name'.tr),
        ),
        const SizedBox(height: AppDimensions.md),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: 'email'.tr),
        ),
        const SizedBox(height: AppDimensions.md),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(labelText: 'phone'.tr),
        ),
        const SizedBox(height: AppDimensions.xl),
        ElevatedButton(
          onPressed: () {
            widget.onSaveProfile(
              _nameController.text.trim(),
              _emailController.text.trim(),
              _phoneController.text.trim(),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              double.infinity,
              AppDimensions.buttonHeight,
            ),
          ),
          child: Text('save_changes'.tr),
        ),
      ],
    );
  }
}
