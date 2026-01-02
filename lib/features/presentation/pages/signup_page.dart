import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'login_page.dart';
import '../../auth/domain/entities/auth_entity.dart';
import '../../auth/domain/usecases/signup_usecase.dart';
import '../../auth/data/datasources/auth_hive_datasource.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../../core/services/hive_services.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  static const Color _brandRed = Color(0xFFD32F2F);

  late SignUpUseCase signUpUseCase;

  @override
  void initState() {
    super.initState();
    final userBox = HiveService().userBox;
    final dataSource = AuthHiveDataSource(userBox);
    final repository = AuthRepositoryImpl(dataSource);
    signUpUseCase = SignUpUseCase(repository);
  }

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (email.isEmpty || password.isEmpty || !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and agree to terms')),
      );
      return;
    }

    final user = AuthEntity(
      id: const Uuid().v4(),
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
    );

    await signUpUseCase.execute(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Brand
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.build, size: 55, color: _brandRed);
                              },
                            ),
                            const SizedBox(width: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Fixhub ',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF222222)),
                                  ),
                                  TextSpan(
                                    text: 'Nepal',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: _brandRed),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign up to get started with Fixhub Nepal',
                        style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                      ),
                      const SizedBox(height: 24),

                      // First Name & Last Name
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('First Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    hintText: 'John',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Last Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    hintText: 'Doe',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Email
                      const Text('Email Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFAAAAAA)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      const Text('Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '9800000000',
                          prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFFAAAAAA)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Address
                      const Text('Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: 'Kathmandu, Nepal',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFFAAAAAA)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password
                      const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFAAAAAA)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Terms Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                            activeColor: _brandRed,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'I agree to the Terms of Service and Privacy Policy',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brandRed,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
