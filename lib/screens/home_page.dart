import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _showedWelcome = false;

  static const Color brandRed = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showedWelcome) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Fixhub Nepal')));
        _showedWelcome = true;
      }
    });
  }

  Widget serviceCard({required IconData leadingIcon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: brandRed.withOpacity(0.95), borderRadius: BorderRadius.circular(10)),
                child: Icon(leadingIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              // (no trailing icon — card itself is tappable)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Welcome, Rehan!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                SizedBox(height: 8),
                Text('Kathmandu, Nepal', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 6),
                Text('Your trusted wheeler service partner', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text('What can we help you with?', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          serviceCard(
            leadingIcon: Icons.build,
            title: 'Routine Service',
            subtitle: 'Regular bike & scooter maintenance',
            onTap: () {},
          ),
          serviceCard(
            leadingIcon: Icons.flash_on,
            title: 'Emergency Repair',
            subtitle: 'Urgent two-wheeler repair within 2 hours',
            onTap: () {},
          ),
          serviceCard(
            leadingIcon: Icons.local_shipping,
            title: 'Pick & Drop Service',
            subtitle: 'We pick up, service, and drop your bike',
            onTap: () {},
          ),

          // testimonials removed per request
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('Bookings', style: TextStyle(fontSize: 18))));
      case 2:
        return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('Tracking', style: TextStyle(fontSize: 18))));
      case 3:
        return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('Profile', style: TextStyle(fontSize: 18))));
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: brandRed,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Home'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: brandRed,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Tracking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
