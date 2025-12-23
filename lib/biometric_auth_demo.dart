import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthDemo extends StatefulWidget {
  const BiometricAuthDemo({super.key});

  @override
  State<BiometricAuthDemo> createState() => _BiometricAuthDemoState();
}

class _BiometricAuthDemoState extends State<BiometricAuthDemo> {
  final LocalAuthentication auth = LocalAuthentication();

  List<BiometricType> availableBiometrics = [];  // Add this line to store available biometrics
  String authStatus = "Not Authenticated";

  @override
  void initState() {
    super.initState();
    _checkBiometrics();  // Check available biometrics on init  
  }


   Future<void> _checkBiometrics() async {
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {});  // Update UI
    } catch (e) {
      debugPrint("Biometrics check error: $e");
    }
  }



   Future<void> authenticateUser() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final biometrics = await auth.getAvailableBiometrics();

      if (!canCheck || !isSupported || biometrics.isEmpty) {
        setState(() {
          authStatus = "No biometric or FaceId authentication available";
        });
        return;
      }

      String biometricType = "Biometric";

      if (biometrics.contains(BiometricType.iris)) {               //iris scans the eyes and get authenticated for both face and fingerprint
        biometricType = "Iris Authentication";
      }
      // if (biometrics.contains(BiometricType.face)) {   //Fingerprint Authentication
      //   biometricType = "Face ID Authentication";
      // }
      // else if (biometrics.contains(BiometricType.fingerprint)) {   //Fingerprint Authentication
      //   biometricType = "Fingerprint Authentication";
      // }

      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate using $biometricType',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      setState(() {
        authStatus = authenticated
            ? "$biometricType Successful"
            : "$biometricType Failed";
      });
    } catch (e) {
      setState(() {
        authStatus = "Authentication error";
      });
      debugPrint("AUTH ERROR: $e");
    }
  }

  //Only using Face ID
  // Future<void> authenticateFaceOnly() async {
  //   try {
  //     final biometrics = await auth.getAvailableBiometrics();

  //     if (!biometrics.contains(BiometricType.face)) {
  //       setState(() {
  //         authStatus = "Face ID not available on this device";
  //       });
  //       return;
  //     }
  //     // Call authenticate() → will use Face ID because only Face is available/enrolled
  //     final authenticated = await auth.authenticate(
  //       localizedReason: 'Authenticate using Face ID',
  //       options: const AuthenticationOptions(
  //         biometricOnly: true,
  //         stickyAuth: true,
  //         useErrorDialogs: true,
  //       ),
  //     );

  //     setState(() {
  //       authStatus = authenticated ? "Face ID Successful" : "Face ID Failed";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       authStatus = "Authentication error: $e";
  //     });
  //     debugPrint("AUTH ERROR: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Auth Demo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(authStatus, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
    onPressed: authenticateUser,
    icon: Icon(biometricIcon(availableBiometrics)),  // Pass real biometrics
    label: const Text("Authenticate"),
  ),
          ],
        ),
      ),
    );
  }

  IconData biometricIcon(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return Icons.face;
    }
    return Icons.fingerprint;
  }
}
