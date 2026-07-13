import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/modules/registration/registration_controller.dart';

class RegistrationScreen extends GetView<RegistrationController> {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkBlue),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOutExpo,
          builder: (context, double value, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildAnimatedWidget(
                      delay: 0.2,
                      value: value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign up to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.grey.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildAnimatedWidget(
                      delay: 0.3,
                      value: value,
                      child: CustomTextField(
                        controller: controller.firstNameController,
                        hintText: 'First Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        validator: controller.validateFirstName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedWidget(
                      delay: 0.4,
                      value: value,
                      child: CustomTextField(
                        controller: controller.lastNameController,
                        hintText: 'Last Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        validator: controller.validateLastName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedWidget(
                      delay: 0.5,
                      value: value,
                      child: CustomTextField(
                        controller: controller.emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryBlue),
                        validator: controller.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedWidget(
                      delay: 0.6,
                      value: value,
                      child: CustomTextField(
                        controller: controller.mobileController,
                        hintText: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: controller.validateMobile,
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 12),
                            CountryCodePicker(
                              onChanged: (countryCode) {
                                controller.countryCode.value = countryCode.dialCode ?? '+91';
                              },
                              initialSelection: 'IN',
                              favorite: const ['+91', 'IN'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              padding: EdgeInsets.zero,
                              showDropDownButton: true,
                              flagWidth: 24,
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(width: 1, height: 24, color: Colors.grey.shade300),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedWidget(
                      delay: 0.7,
                      value: value,
                      child: Obx(() => CustomTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: controller.validatePassword,
                      )),
                    ),
                    const SizedBox(height: 12),
                    _buildAnimatedWidget(
                      delay: 0.8,
                      value: value,
                      child: Obx(() => CustomTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        validator: controller.validateConfirmPassword,
                      )),
                    ),
                    const SizedBox(height: 25),
                    _buildAnimatedWidget(
                      delay: 0.9,
                      value: value,
                      child: Obx(() => CustomButton(
                        text: 'Register',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.register,
                      )),
                    ),
                    const SizedBox(height: 20),
                    _buildAnimatedWidget(
                      delay: 0.95,
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedWidget({
    required double delay,
    required double value,
    required Widget child,
  }) {
    double opacity = (value - delay).clamp(0.0, 1.0) / (1.0 - delay);
    return Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, 30 * (1 - opacity)),
        child: child,
      ),
    );
  }
}
