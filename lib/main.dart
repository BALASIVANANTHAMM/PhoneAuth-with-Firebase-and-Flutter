import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAlymuiTUAXIB49gesGtuU2MvlJCAkKxnk",
          appId: "1:84679574390:web:e599c5d4b0d285438af057",
          messagingSenderId: "84679574390",
          projectId: "phoneauth-7175b"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Otp(),
    );
  }
}

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  // String? verificationID;
  final phoneNo = TextEditingController();
  bool visible = true;
  bool visibleButton = false;

  // get verificationID => null;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP AUTH'),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.height / 2.8,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 7,
              ),
              Text(
                'Phone No Authentication',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.height / 3,
                  child: TextFormField(
                    controller: phoneNo,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: 'Enter Your Phone No',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9))),
                  )),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shadowColor: Colors.black38),
                    onPressed: () async {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: '+91 ${phoneNo.text}',
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException exception) {
                          print("Exception: $exception");
                        },
                        codeSent: (String verificationID, int? resendToken) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                        verificationID: verificationID,
                                      )));
                        },
                        codeAutoRetrievalTimeout: (String verificationID) {},
                      );
                    },
                    child: Text(
                      'Send Otp',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String verificationID;
  const OtpScreen({required this.verificationID, super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpControllers = List.generate(6, (index) => TextEditingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => otpTextField(context, index)),
          ),
          SizedBox(
            height: 25,
          ),
          SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shadowColor: Colors.black38),
                  onPressed: () async {
                    try {
                      String otp = otpControllers
                          .map((controller) => controller.text)
                          .join();
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: widget.verificationID,
                        smsCode: otp,
                      );
                      await FirebaseAuth.instance
                          .signInWithCredential(credential)
                          .then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      });
                    } catch (ex) {
                      print('Error For Your OTP : $ex');
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  )))
        ],
      ),
    );
  }

  Widget otpTextField(BuildContext context, int index) {
    return Form(
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 8,
        width: MediaQuery.of(context).size.width / 8,
        child: TextFormField(
          controller: otpControllers[index],
          onChanged: (value) {
            if (value.length == 1) {
              FocusScope.of(context).nextFocus();
            }
          },
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome to Phone Auth'),
      ),
    );
  }
}
