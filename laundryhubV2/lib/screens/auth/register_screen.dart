import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  // USER
  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  // OWNER
  final laundryNameController =
      TextEditingController();

  final laundryAddressController =
      TextEditingController();

  final laundryPhoneController =
      TextEditingController();

  final laundryEmailController =
      TextEditingController();

  final laundryDescriptionController =
      TextEditingController();

  bool hidePassword=true;
  bool hideConfirm=true;

  bool agree=false;
  bool isLoading=false;

  String role="customer";

  @override
  void dispose(){

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();

    laundryNameController.dispose();
    laundryAddressController.dispose();
    laundryPhoneController.dispose();
    laundryEmailController.dispose();
    laundryDescriptionController.dispose();

    super.dispose();
  }

  Future<void> register() async {

  // Validasi checkbox

    if (!agree) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Setujui syarat & ketentuan",
          ),
        ),
      );

      return;
    }

    // Validasi field wajib

    if (

        nameController.text.isEmpty ||

        phoneController.text.isEmpty ||

        emailController.text.isEmpty ||

        passwordController.text.isEmpty ||

        confirmController.text.isEmpty

    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Semua data wajib diisi",
          ),
        ),
      );

      return;
    }

    // Validasi password

    if (

        passwordController.text !=

        confirmController.text

    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Konfirmasi password tidak sesuai",
          ),
        ),
      );

      return;
    }

    // Validasi owner

    if (role == "owner") {

      if (

          laundryNameController.text.isEmpty ||

          laundryAddressController.text.isEmpty ||

          laundryPhoneController.text.isEmpty

      ) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Data laundry wajib diisi",
            ),
          ),
        );

        return;
      }
    }

    setState(() {

      isLoading = true;

    });

    final result =
        await AuthService().register(

      // USER

      name:
          nameController.text,

      email:
          emailController.text,

      phone:
          phoneController.text,

      password:
          passwordController.text,

      passwordConfirmation:
          confirmController.text,

      role:
          role,

      terms:
          agree,

      // OWNER

      laundryName:
          role == "owner"
              ? laundryNameController.text
              : null,

      laundryAddress:
          role == "owner"
              ? laundryAddressController.text
              : null,

      laundryPhone:
          role == "owner"
              ? laundryPhoneController.text
              : null,

      laundryEmail:
          role == "owner"
              ? laundryEmailController.text
              : null,

      laundryDescription:
          role == "owner"
              ? laundryDescriptionController.text
              : null,
    );

    setState(() {

      isLoading = false;

    });

    if (result["success"] == true) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
              Colors.green,

          content: Text(
            result["message"],
          ),
        ),
      );

      Future.delayed(

        const Duration(
          seconds: 2,
        ),

        () {

          Navigator.pushReplacementNamed(
            context,
            '/login',
          );

        },
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            result["message"],
          ),
        ),
      );
    }
  }

  Widget roleCard({

    required String title,
    required String subtitle,
    required String value,
    required IconData icon,

  }){

    bool selected=
        role==value;

    return Expanded(

      child: GestureDetector(

        onTap:(){

          setState(() {

            role=value;

          });

        },

        child: AnimatedContainer(

          duration:
          const Duration(
              milliseconds:300),

          height:130,

          decoration:
          BoxDecoration(

            color:

            selected

                ? value=="customer"

                ? Colors.green.shade50
                : Colors.blue.shade50

                : Colors.white,

            borderRadius:
            BorderRadius.circular(25),

            border:
            Border.all(

              width:2,

              color:

              selected

                  ? value=="customer"

                  ? Colors.green
                  : Colors.blue

                  : Colors.grey.shade300,
            ),
          ),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children:[

              Icon(

                icon,

                size:35,

                color:

                selected

                    ? value=="customer"

                    ? Colors.green
                    : Colors.blue

                    : Colors.grey,
              ),

              const SizedBox(height:10),

              Text(

                title,

                style:
                GoogleFonts.poppins(

                  fontWeight:
                  FontWeight.bold,

                  fontSize:18,
                ),
              ),

              const SizedBox(height:5),

              Text(

                subtitle,

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.poppins(

                  fontSize:12,

                  color:
                  Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration input(
      String hint){

    return InputDecoration(

      hintText:hint,

      filled:true,

      fillColor:
      const Color(
          0xffF8FAFC),

      contentPadding:
      const EdgeInsets.symmetric(
          horizontal:20,
          vertical:18),

      border:
      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(18),

        borderSide:
        BorderSide(
            color:
            Colors.grey.shade300),
      ),
    );
  }

  Widget phoneInput({
  required TextEditingController controller,
}) {

  return Row(
    children: [

      Container(

        height: 58,

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),

        decoration: const BoxDecoration(

          gradient: LinearGradient(
            colors: [
              Color(0xff0ea5e9),
              Color(0xff06b6d4),
            ],
          ),

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
        ),

        alignment: Alignment.center,

        child: const Text(
          "62",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      Expanded(
        child: TextField(

          controller: controller,

          keyboardType:
              TextInputType.phone,

          decoration: const InputDecoration(

            hintText: "81234567890",

            filled: true,

            fillColor:
                Color(0xffF8FAFC),

            contentPadding:
                EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.only(

                topRight:
                    Radius.circular(18),

                bottomRight:
                    Radius.circular(18),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  @override
  Widget build(
      BuildContext context){

    return Scaffold(

      backgroundColor:
      const Color(
          0xffF4F8FD),

      body:
      SafeArea(

        child:
        SingleChildScrollView(

          padding:
          const EdgeInsets.all(
              25),

          child:
          Column(

            children:[

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xff1E293B),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff60A5FA),
                          Color(0xff38BDF8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.shirt,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    "LaundryHub",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                  height:35),

              Text(

                "Buat Akun Baru",

                style:
                GoogleFonts.poppins(

                  fontSize:30,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height:10),

              Text(

                "Bergabung dengan LaundryHub dan nikmati layanan laundry digital",
                textAlign: TextAlign.center,

                style:
                GoogleFonts.poppins(

                  color:
                  Colors.grey,
                ),
              ),

              const SizedBox(height:30),

              Row(

                children:[

                  roleCard(

                    title:"Pelanggan",

                    subtitle:
                    "Mencari layanan laundry",

                    value:"customer",

                    icon:
                    Icons.person,
                  ),

                  const SizedBox(width:15),

                  roleCard(

                    title:"Pemilik Laundry",

                    subtitle:
                    "Mendaftarkan usaha laundry",

                    value:"owner",

                    icon:
                    Icons.store,
                  ),
                ],
              ),

              if(role=="owner")...[

                const SizedBox(height:20),

                Container(

                  padding:
                  const EdgeInsets.all(15),

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.blue.shade50,

                    borderRadius:
                    BorderRadius.circular(15),
                  ),

                  child: Row(

                    children:[

                      const Icon(
                        Icons.info,
                        color:
                        Colors.blue,
                      ),

                      const SizedBox(width:10),

                      Expanded(

                        child: Text(

                          "Setelah mendaftar akun Anda akan diverifikasi oleh admin sebelum dapat mulai menggunakan layanan.",

                          style:
                          GoogleFonts.poppins(
                              fontSize:12),
                        ),
                      )
                    ],
                  ),
                )
              ],

              const SizedBox(height:25),

              TextField(
                controller: nameController,
                decoration: input("Nama Lengkap"),
              ),

              const SizedBox(height: 16),

              phoneInput(
                controller: phoneController,
              ),

              const SizedBox(height:15),

              TextField(
                controller: emailController,

                keyboardType:
                    TextInputType.emailAddress,

                decoration: input(
                  "Email",
                ),
              ),

              const SizedBox(height:15),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: input("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: confirmController,
                obscureText: hideConfirm,
                decoration: input("Konfirmasi Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      hideConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hideConfirm = !hideConfirm;
                      });
                    },
                  ),
                ),
              ),
              if(role=="owner")...[

                const SizedBox(height:30),

                const Divider(),

                const SizedBox(height:20),

                Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    "Informasi Laundry",
                    style:
                    GoogleFonts.poppins(
                      fontSize:20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height:20),

                TextField(
                  controller:
                  laundryNameController,
                  decoration:
                  input("Nama Laundry"),
                ),

                const SizedBox(height:15),

                TextField(
                  controller:
                  laundryAddressController,
                  maxLines:4,
                  decoration:
                  input("Alamat Laundry"),
                ),
                const SizedBox(
                  height: 15,
                ),

                phoneInput(
                  controller: laundryPhoneController,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: laundryEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: input(
                    "Email Laundry (Opsional)",
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextField(

                  controller:
                      laundryDescriptionController,

                  maxLines: 4,

                  decoration: input(
                    "Deskripsi Laundry",
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [

                  Transform.scale(
                    scale: 1.05,
                    child: Checkbox(
                      value: agree,
                      activeColor: const Color(0xff3B82F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (value) {
                        setState(() {
                          agree = value!;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [

                          TextSpan(
                            text: "Saya menyetujui ",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),

                          TextSpan(
                            text: "Syarat & Ketentuan",
                            style: GoogleFonts.poppins(
                              color: const Color(0xff3B82F6),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(

                  onPressed: isLoading
                      ? null
                      : register,

                  style: ElevatedButton.styleFrom(

                    elevation: 0,

                    backgroundColor:
                        const Color(0xff3B82F6),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: isLoading

                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )

                      : Text(
                          "Daftar Sekarang",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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