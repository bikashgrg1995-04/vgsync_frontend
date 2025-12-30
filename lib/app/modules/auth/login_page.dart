import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vgsync_frontend/utils/constants.dart';
import 'package:vgsync_frontend/utils/size_config.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey.shade300,
          height: SizeConfig.screenHeight,
          child: Row(
            children: [
              // Left side - Logo / Illustration
              Expanded(
                flex: 1,
                child: Center(
                  child: Image.asset(
                    AppConstants.logo,
                    width: SizeConfig.sw(0.25),
                    height: SizeConfig.sw(0.25),
                  ),
                ),
              ),

              // Right side - Login Card
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.sw(0.08)),
                  color: Colors.grey.shade100,
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.sw(0.06)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: SizeConfig.res(6),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: SizeConfig.sh(0.005)),
                            Text(
                              "Login to continue to vgsync_frontend",
                              style: TextStyle(
                                fontSize: SizeConfig.res(5),
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: SizeConfig.sh(0.03)),

                            // Username
                            _buildTextField(
                              controller.usernameController,
                              "Username",
                              Icons.person,
                            ),
                            SizedBox(height: SizeConfig.sh(0.02)),

                            // Password
                            _buildTextField(
                              controller.passwordController,
                              "Password",
                              Icons.lock,
                              obscureText: true,
                            ),
                            SizedBox(height: SizeConfig.sh(0.04)),

                            // Login Button
                            Obx(() {
                              return controller.isLoading.value
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      height: SizeConfig.sh(0.065),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () => controller.login(),
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: SizeConfig.res(6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                            }),
                            SizedBox(height: SizeConfig.sh(0.02)),
                          ],
                        ),
                      ),
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

  // ------------------ Helper ------------------
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade200,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
