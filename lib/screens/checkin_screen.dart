import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../data/repositories/mock_repository.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final MockRepository _repository = MockRepository();
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrCode = barcodes.first.rawValue;
    if (qrCode == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final usuario = _repository.getUsuarioByQrCode(qrCode);

      if (usuario != null) {
        _repository.realizarCheckin(qrCode);
        _showResultDialog(
          isSuccess: true,
          message:
              '${AppStrings.checkinValido}\n\n${usuario.nome}\n${usuario.email}',
        );
      } else {
        _showResultDialog(
          isSuccess: false,
          message: AppStrings.inscricaoNaoEncontrada,
        );
      }
    } catch (e) {
      _showResultDialog(
        isSuccess: false,
        message: AppStrings.inscricaoNaoEncontrada,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isProcessing = false;
    });
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(isSuccess ? 'Sucesso' : 'Erro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accentGold, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  AppStrings.escaneieQrCode,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentGold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
