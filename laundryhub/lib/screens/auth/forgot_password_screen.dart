import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final emailController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {

    emailController.dispose();

    super.dispose();

  }

  Future<void> sendResetLink() async {

    FocusScope.of(context).unfocus();

    if (emailController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Email wajib diisi",
          ),

        ),

      );

      return;
    }

    setState(() {

      isLoading = true;

    });

    final result =
        await AuthService()
            .forgotPassword(

      email:
      emailController.text.trim(),

    );

    if (!mounted) return;

    setState(() {

      isLoading = false;

    });

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(

          result["message"],

        ),

      ),

    );

    if (result["success"]) {

      Future.delayed(

        const Duration(seconds: 1),

        () {

          if (mounted) {

            Navigator.pop(context);

          }

        },

      );

    }

  }

  InputDecoration fieldStyle({

    required String hint,

    required IconData icon,

  }) {

    return InputDecoration(

      hintText: hint,

      hintStyle:
      GoogleFonts.poppins(

        color:
        Colors.grey[500],

      ),

      prefixIcon: Icon(

        icon,

        color:
        Colors.grey[600],

      ),

      filled: true,

      fillColor:
      const Color(
          0xffF8FAFC),

      contentPadding:
      const EdgeInsets.symmetric(

        vertical: 20,

      ),

      border:

      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(18),

        borderSide:
        BorderSide.none,

      ),

      focusedBorder:

      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(18),

        borderSide:

        const BorderSide(

          color:
          Color(
              0xff3B82F6),

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.white,

      body:

      SafeArea(

        child:

        SingleChildScrollView(

          padding:
          const EdgeInsets.symmetric(

            horizontal: 24,

            vertical: 20,

          ),

          child:

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              IconButton(

                padding:
                EdgeInsets.zero,

                constraints:
                const BoxConstraints(),

                onPressed: () {

                  Navigator.pop(
                    context,
                  );

                },

                icon:
                const Icon(

                  Icons.arrow_back_ios_new_rounded,

                ),

              ),

              const SizedBox(
                height: 25,
              ),

              Row(

                children: [

                  Container(

                    width: 55,
                    height: 55,

                    decoration:
                    BoxDecoration(

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),

                      gradient:

                      const LinearGradient(

                        colors: [

                          Color(
                              0xff60A5FA),

                          Color(
                              0xff38BDF8),

                        ],

                      ),

                    ),

                    child:

                    const Center(

                      child:

                      FaIcon(

                        FontAwesomeIcons.shirt,

                        color:
                        Colors.white,

                        size: 22,

                      ),

                    ),

                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Text(

                    "LaundryHub",

                    style:

                    GoogleFonts.poppins(

                      fontSize: 28,

                      fontWeight:
                      FontWeight.w700,

                    ),

                  ),

                ],

              ),

              const SizedBox(
                height: 45,
              ),

              Text(

                "Lupa\nPassword",

                style:

                GoogleFonts.poppins(

                  fontSize: 40,

                  fontWeight:
                  FontWeight.bold,

                  height: 1.1,

                ),

              ),

              const SizedBox(
                height: 12,
              ),

              Text(

                "Masukkan email akun Anda. Kami akan mengirimkan link untuk mengatur ulang password.",

                style:

                GoogleFonts.poppins(

                  fontSize: 15,

                  height: 1.6,

                  color:
                  Colors.grey[600],

                ),

              ),

              const SizedBox(
                height: 35,
              ),

              TextField(

                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration:

                fieldStyle(

                  hint:
                  "Email",

                  icon:
                  Icons.email_outlined,

                ),

              ),

              const SizedBox(
                height: 35,
              ),

              SizedBox(

                width:
                double.infinity,

                height: 58,

                child:

                ElevatedButton(

                  onPressed:

                  isLoading
                      ? null
                      : sendResetLink,

                  style:

                  ElevatedButton.styleFrom(

                    backgroundColor:

                    const Color(
                        0xff3B82F6),

                    elevation: 0,

                    shape:

                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),

                    ),

                  ),

                  child:

                  isLoading

                      ? const SizedBox(

                    width: 25,
                    height: 25,

                    child:

                    CircularProgressIndicator(

                      color:
                      Colors.white,

                      strokeWidth:
                      2.5,

                    ),

                  )

                      : Text(

                    "Kirim Link Reset",

                    style:

                    GoogleFonts.poppins(

                      fontSize: 18,

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }
}