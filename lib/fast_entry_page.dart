import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_dot/pin_dot.dart';
import 'package:pin_keyboard/pin_keyboard.dart';
import 'package:task11_app/home_page.dart';

class FastEntryPage extends StatefulWidget {
  @override
  _FastEntryPageState createState() => _FastEntryPageState();
}

class _FastEntryPageState extends State<FastEntryPage> {
  String pin_code = '';
  late Size size;

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
    if (authenticated == true) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 147),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Быстрый вход',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF47536D),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Введите код доступа к приложению',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF47536D),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 31,
                ),
                PinDot(
                  size: 17,
                  length: 4,
                  text: pin_code,
                  activeColor: Colors.blue[700],
                  borderColor: Colors.yellow[700],
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              // alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(
                  // top: size.height * 0.65,
                  left: size.width * 0.15,
                  right: size.width * 0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PinKeyboard(
                    length: 4,
                    enableBiometric: true,
                    iconBiometricColor: Colors.blue[400],
                    onChange: (pin) {
                      setState(() {
                        pin_code = pin;
                      });
                    },
                    onConfirm: (pin) {
                      if (pin_code == '0023') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }
                    },
                    onBiometric: () {
                      _authenticateWithBiometrics();
                      print('Use Biometric');
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
