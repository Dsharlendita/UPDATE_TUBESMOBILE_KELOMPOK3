import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/auth_service.dart';

import '../dashboard/owner_dashboard.dart';
import '../../customer_screen/customer_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading=false;
  bool hidePassword=true;

  @override
  void dispose(){

    emailController.dispose();

    passwordController.dispose();

    super.dispose();

  }

  Future<void> login() async {

    FocusScope.of(
      context,
    ).unfocus();

    if(
    emailController.text.isEmpty ||
    passwordController.text.isEmpty
    ){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Email dan Password wajib diisi",
          ),

        ),

      );

      return;

    }

    setState(() {

      isLoading=true;

    });

    final result=
    await AuthService()
        .login(

      email:
      emailController.text.trim(),

      password:
      passwordController.text.trim(),

    );

    if(!mounted) return;

    setState(() {

      isLoading=false;

    });

    if(result["success"]){

      final user=
      await AuthService()
          .getUser();

      if(!mounted)return;

      if(user==null){

        ScaffoldMessenger.of(
            context
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "Data user tidak ditemukan",
            ),

          ),

        );

        return;

      }

      ScaffoldMessenger.of(
          context
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "Login berhasil",
          ),

        ),

      );

      /// OWNER

      if(
      user["role"]=="owner"
      ){

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder:(_)=>

            const OwnerDashboard(),

          ),

        );

      }

      /// CUSTOMER

      else{

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder:(_)=>

            const CustomerDashboardScreen(),

          ),

        );

      }

    }

    else{

      ScaffoldMessenger.of(
          context
      ).showSnackBar(

        SnackBar(

          content: Text(

            result["message"],

          ),

        ),

      );

    }

  }

  InputDecoration fieldStyle({

    required String hint,

    required IconData icon,

    Widget? suffix,

  }){

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

      suffixIcon:
      suffix,

      filled:true,

      fillColor:
      const Color(
          0xffF8FAFC
      ),

      contentPadding:
      const EdgeInsets.symmetric(

        vertical:20,

      ),

      border:

      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        borderSide:
        BorderSide.none,

      ),

      focusedBorder:

      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        borderSide:

        const BorderSide(

          color:
          Color(
              0xff3B82F6
          ),

        ),

      ),

    );

  }

  @override
  Widget build(
      BuildContext context
      ){

    return Scaffold(

      resizeToAvoidBottomInset:
      true,

      backgroundColor:
      Colors.white,

      body:

      SafeArea(

        child:

        SingleChildScrollView(

          padding:

          const EdgeInsets.symmetric(

            horizontal:24,

            vertical:20,

          ),

          child:

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children:[

              IconButton(

                padding:
                EdgeInsets.zero,

                constraints:
                const BoxConstraints(),

                onPressed:(){

                  Navigator.pop(
                      context
                  );

                },

                icon:

                const Icon(

                  Icons
                      .arrow_back_ios_new_rounded,

                ),

              ),

              const SizedBox(
                height:25,
              ),

              Row(

                children:[

                  Container(

                    width:55,
                    height:55,

                    decoration:
                    BoxDecoration(

                      borderRadius:
                      BorderRadius.circular(
                          18
                      ),

                      gradient:

                      const LinearGradient(

                        colors:[

                          Color(
                              0xff60A5FA
                          ),

                          Color(
                              0xff38BDF8
                          ),

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

                        size:22,

                      ),

                    ),

                  ),

                  const SizedBox(
                    width:14,
                  ),

                  Text(

                    "LaundryHub",

                    style:

                    GoogleFonts.poppins(

                      fontSize:28,

                      fontWeight:
                      FontWeight.w700,

                    ),

                  )

                ],

              ),

              const SizedBox(
                height:45,
              ),

              Text(

                "Selamat\nDatang",

                style:

                GoogleFonts.poppins(

                  fontSize:40,

                  fontWeight:
                  FontWeight.bold,

                  height:1.1,

                ),

              ),

              const SizedBox(
                height:12,
              ),

              Text(

                "Masuk untuk mengakses akun LaundryHub dan kelola aktivitas laundry dengan mudah.",

                style:

                GoogleFonts.poppins(

                  fontSize:15,

                  height:1.6,

                  color:
                  Colors.grey[600],

                ),

              ),

              const SizedBox(
                height:35,
              ),

              TextField(

                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                textInputAction:
                TextInputAction.next,

                decoration:

                fieldStyle(

                  hint:
                  "Email",

                  icon:
                  Icons.email_outlined,

                ),

              ),

              const SizedBox(
                height:20,
              ),

              TextField(

                controller:
                passwordController,

                obscureText:
                hidePassword,

                textInputAction:
                TextInputAction.done,

                onSubmitted:(_){

                  login();

                },

                decoration:

                fieldStyle(

                  hint:
                  "Password",

                  icon:
                  Icons.lock_outline,

                  suffix:

                  IconButton(

                    onPressed:(){

                      setState(() {

                        hidePassword=
                        !hidePassword;

                      });

                    },

                    icon:

                    Icon(

                      hidePassword

                          ? Icons.visibility_off

                          : Icons.visibility,

                    ),

                  ),

                ),

              ),

              Align(

                alignment: Alignment.centerRight,

                child: TextButton(

                  onPressed: () {

                    Navigator.pushNamed(

                      context,

                      '/forgot-password',

                    );

                  },

                  child: Text(

                    "Lupa Password?",

                    style: GoogleFonts.poppins(

                      color: const Color(0xff3B82F6),

                      fontWeight: FontWeight.w500,

                    ),

                  ),

                ),

              ),


              const SizedBox(
                height:35,
              ),

              SizedBox(

                width:
                double.infinity,

                height:58,

                child:

                ElevatedButton(

                  onPressed:

                  isLoading
                      ? null
                      : login,

                  style:

                  ElevatedButton
                      .styleFrom(

                    backgroundColor:

                    const Color(
                        0xff3B82F6
                    ),

                    elevation:0,

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

                    width:25,
                    height:25,

                    child:

                    CircularProgressIndicator(

                      color:
                      Colors.white,

                      strokeWidth:
                      2.5,

                    ),

                  )

                      :

                  Text(

                    "Masuk",

                    style:

                    GoogleFonts.poppins(

                      fontSize:18,

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                ),

              ),

              const SizedBox(
                height:30,
              ),

              Center(

                child:

                GestureDetector(

                  onTap:(){

                    Navigator.pushNamed(

                      context,

                      "/register",

                    );

                  },

                  child:

                  RichText(

                    text:

                    TextSpan(

                      children:[

                        TextSpan(

                          text:
                          "Belum punya akun? ",

                          style:

                          GoogleFonts.poppins(

                            color:
                            Colors.grey,

                          ),

                        ),

                        TextSpan(

                          text:
                          "Daftar",

                          style:

                          GoogleFonts.poppins(

                            color:

                            const Color(
                                0xff3B82F6
                            ),

                            fontWeight:
                            FontWeight.w600,

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

              )

            ],

          ),

        ),

      ),

    );

  }
}