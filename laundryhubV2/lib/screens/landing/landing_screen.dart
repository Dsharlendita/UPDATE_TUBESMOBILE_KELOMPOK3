import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),

          child: Column(
            children: [

              /// HEADER
              const SizedBox(
                height: 24,
              ),

              Row(
                children: [

                  /// LOGO
                  Container(
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment
                                .bottomRight,

                        colors: [
                          Color(
                              0xff60A5FA),
                          Color(
                              0xff38BDF8),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xff60A5FA,
                          ).withOpacity(
                              .25),

                          blurRadius:
                              18,

                          offset:
                              const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
                    ),

                    child:
                        const Center(
                      child: FaIcon(
                        FontAwesomeIcons
                            .shirt,

                        color:
                            Colors.white,

                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Text(
                    "LaundryHub",

                    style:
                        GoogleFonts
                            .poppins(
                      fontSize:
                          22,

                      fontWeight:
                          FontWeight
                              .w700,

                      color:
                          const Color(
                        0xff111827,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 45,
              ),

              /// TITLE
              Align(
                alignment:
                    Alignment
                        .centerLeft,

                child: RichText(
                  text:
                      TextSpan(
                    children: [

                      TextSpan(
                        text:
                            "Cucian Bersih,\n",

                        style:
                            GoogleFonts
                                .poppins(
                          fontSize:
                              34,

                          fontWeight:
                              FontWeight
                                  .w700,

                          color:
                              const Color(
                            0xff111827,
                          ),

                          height:
                              1.15,
                        ),
                      ),

                      TextSpan(
                        text:
                            "Hidup Lebih\nMudah",

                        style:
                            GoogleFonts
                                .poppins(
                          fontSize:
                              34,

                          fontWeight:
                              FontWeight
                                  .w700,

                          color:
                              const Color(
                            0xff3B82F6,
                          ),

                          height:
                              1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              /// DESCRIPTION
              Text(
                "Nikmati layanan laundry modern dengan tracking realtime, pickup & delivery serta pembayaran online yang praktis.",

                style:
                    GoogleFonts
                        .poppins(
                  fontSize:
                      12,

                  color:
                      const Color(
                    0xff6B7280,
                  ),

                  height:
                      2,
                ),
              ),

              const Spacer(),

              /// IMAGE
              Image.asset(
                "assets/images/laundry.png",

                width: 300,

                fit:
                    BoxFit.contain,
              ),

              const Spacer(),

              /// BUTTON MASUK
              SizedBox(
                width:
                    double.infinity,

                height: 52,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator
                        .pushNamed(
                      context,
                      "/login",
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xff3B82F6,
                    ),

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),

                  child:
                      Text(
                    "Masuk",

                    style:
                        GoogleFonts
                            .poppins(
                      fontSize:
                          16,

                      fontWeight:
                          FontWeight
                              .w600,

                      color:
                          Colors
                              .white,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              /// BUTTON DAFTAR
              SizedBox(
                width:
                    double.infinity,

                height: 52,

                child:
                    OutlinedButton(
                  onPressed: () {
                    Navigator
                        .pushNamed(
                      context,
                      "/register",
                    );
                  },

                  style:
                      OutlinedButton.styleFrom(
                    side:
                        const BorderSide(
                      color:
                          Color(
                        0xffE5E7EB,
                      ),
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        30,
                      ),
                    ),
                  ),

                  child:
                      Text(
                    "Daftar",

                    style:
                        GoogleFonts
                            .poppins(
                      fontSize:
                          16,

                      fontWeight:
                          FontWeight
                              .w600,

                      color:
                          const Color(
                        0xff111827,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}