import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? colorText,
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = Get.context;
      if (context != null) {
        try {
          final messenger = ScaffoldMessenger.maybeOf(context);
          if (messenger != null) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorText ?? AppColors.white,
                        ),
                      ),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorText ?? AppColors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: backgroundColor ?? AppColors.secondaryGreen,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          debugPrint("Snackbar error: $e");
        }
      }
    });
  }

  static void success({required String message, String title = 'Success'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.secondaryGreen,
      colorText: AppColors.white,
    );
  }

  static void error({required String message, String title = 'Error'}) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }
}
