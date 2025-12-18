import 'package:flutter/material.dart';
import '../../theme/theme_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ================= HERO BANNER (FULL WIDTH) =================
  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/hero.png',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Vehicle Problems?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'FixHub brings mechanics to your doorstep',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SERVICE CARD =================
  Widget serviceCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(imagePath, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.25),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CUSTOMER REVIEW CARD =================
  Widget _customerReviewCard({
    required String name,
    required String review,
    required int rating,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              rating,
              (_) => const Icon(Icons.star,
                  color: Colors.amber, size: 18),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.brandRed, AppTheme.brandRedDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hello, Rehan! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Kathmandu, Nepal',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _buildHeroBanner(context),

          const SizedBox(height: 24),

          // SERVICES
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Our Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                serviceCard(
                  imagePath: 'assets/images/routine.png',
                  title: 'Routine Service',
                  subtitle: 'Regular bike & scooter maintenance',
                  onTap: () {},
                ),
                serviceCard(
                  imagePath: 'assets/images/emergency.png',
                  title: 'Emergency Repair',
                  subtitle: 'Urgent repair within 2 hours',
                  onTap: () {},
                ),
                serviceCard(
                  imagePath: 'assets/images/pickup.png',
                  title: 'Pick & Drop Service',
                  subtitle: 'We pick, service & drop your bike',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // TESTIMONIALS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'What Customers Say',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _customerReviewCard(
                  name: 'Ramesh Shrestha',
                  review:
                      'Very fast service. The mechanic arrived on time and fixed my bike quickly.',
                  rating: 5,
                ),
                _customerReviewCard(
                  name: 'Sita Karki',
                  review:
                      'Affordable and reliable. Pick and drop service was really helpful.',
                  rating: 4,
                ),
                _customerReviewCard(
                  name: 'Anil Thapa',
                  review:
                      'Good experience overall. Customer support was responsive.',
                  rating: 4,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
