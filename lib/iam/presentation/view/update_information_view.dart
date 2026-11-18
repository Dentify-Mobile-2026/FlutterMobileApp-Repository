import 'package:dentify_flutter/iam/data/remote/dto/update_infomation_request.dart';
import 'package:dentify_flutter/iam/presentation/di/presentation_module.dart';
import 'package:dentify_flutter/iam/presentation/viewmodel/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateInformationView extends ConsumerWidget {
  final ProfileViewModel viewModel;

  const UpdateInformationView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final state = ref.watch(profileViewModelProvider);

    final fullNameParts = (state.userInfo?.fullName ?? '').split(" ");
    final firstNameController = TextEditingController(text: fullNameParts.firstOrNull ?? '');
    final lastNameController = TextEditingController(text: fullNameParts.length > 1 ? fullNameParts.last : '');
    final emailController = TextEditingController(text: state.userInfo?.email ?? '');
    final companyController = TextEditingController(text: state.userInfo?.companyName ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        title: const Text('Update Info', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Edit Profile Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            _buildInput("First Name", firstNameController),
            const SizedBox(height: 16),
            _buildInput("Last Name", lastNameController),
            const SizedBox(height: 16),
            _buildInput("Email", emailController),
            const SizedBox(height: 16),
            _buildInput("Company Name", companyController),
            const SizedBox(height: 24),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  "Error: ${state.errorMessage}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                await viewModel.updateInformation(
                  UpdateInformationRequest(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    companyName: companyController.text,
                  ),
                );
                if (ref.read(profileViewModelProvider).errorMessage == null && context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C3E50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2C3E50), width: 1.5),
        ),
      ),
    );
  }
}
