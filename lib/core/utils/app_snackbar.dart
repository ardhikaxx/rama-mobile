import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

/// Centralized notification & snackbar helper using awesome_snackbar_content
class AppSnackBar {
  const AppSnackBar._();

  /// Shows a success snackbar (green)
  static void showSuccess(
    BuildContext context, {
    String title = 'Berhasil!',
    required String message,
    Duration duration = const Duration(seconds: 3),
    ScaffoldMessengerState? messenger,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.success,
      duration: duration,
      messenger: messenger,
    );
  }

  /// Shows a warning snackbar (yellow/amber)
  static void showWarning(
    BuildContext context, {
    String title = 'Perhatian!',
    required String message,
    Duration duration = const Duration(seconds: 3),
    ScaffoldMessengerState? messenger,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.warning,
      duration: duration,
      messenger: messenger,
    );
  }

  /// Shows an error snackbar (red)
  static void showError(
    BuildContext context, {
    String title = 'Terjadi Kesalahan!',
    required String message,
    Duration duration = const Duration(seconds: 4),
    ScaffoldMessengerState? messenger,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.failure,
      duration: duration,
      messenger: messenger,
    );
  }

  /// Shows an informational snackbar (blue)
  static void showInfo(
    BuildContext context, {
    String title = 'Informasi',
    required String message,
    Duration duration = const Duration(seconds: 3),
    ScaffoldMessengerState? messenger,
  }) {
    _show(
      context,
      title: title,
      message: message,
      contentType: ContentType.help,
      duration: duration,
      messenger: messenger,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
    required Duration duration,
    ScaffoldMessengerState? messenger,
  }) {
    final effectiveMessenger = messenger ?? ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    effectiveMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
