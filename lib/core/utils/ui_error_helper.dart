import 'package:flutter/material.dart';

import 'package:pos_machine/core/theme/app_theme.dart';

/// Classe auxiliar para exibir erros na interface do usuário de forma consistente
class UIErrorHelper {
  /// Exibe um SnackBar com mensagem de erro
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Exibe um diálogo de erro com botão para tentar novamente
  static Future<bool> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String retryButtonText = 'Tentar Novamente',
    String cancelButtonText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelButtonText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(retryButtonText),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}

/// Widget para exibir mensagens de erro com botão para tentar novamente
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryButtonText;

  const AppErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryButtonText = 'Tentar Novamente',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppTheme.errorColor, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text(retryButtonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir erros de rede com ilustração e botão para tentar novamente
class NetworkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryButtonText;

  const NetworkErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryButtonText = 'Tentar Novamente',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 20),
            Text(
              'Problema de conexão',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
