import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const CimaLearnApp());
}

class CimaLearnApp extends StatelessWidget {
  const CimaLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CIMA Learn Hub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBE0000), // Red primary
          primary: const Color(0xFFBE0000),
          onPrimary: Colors.white,
          secondary: const Color(0xFF2E2E2E), // Dark gray accent
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF2E2E2E),
        ),
        textTheme: TextTheme(
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2E2E2E),
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBE0000),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFBE0000),
            side: const BorderSide(color: Color(0xFFBE0000)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        cardTheme: const CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          margin: EdgeInsets.all(8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2E2E2E),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E2E2E),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }
        return MaterialPageRoute(builder: (_) => const NotFoundPage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String activeCategory = 'all';
  bool showMore = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool get isMobile => MediaQuery.of(context).size.width < 768;

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    showToast('Welcome to CIMA Learn Hub!');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = getFilteredCourses(activeCategory);
    final displayedCourses = showMore ? filteredCourses : filteredCourses.take(6).toList();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Header(isMobile: isMobile),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const HeroSection(),
          ),
          const SizedBox(height: 24),
          CourseCategories(
            activeCategory: activeCategory,
            onCategoryChange: (category) {
              setState(() {
                activeCategory = category;
                showMore = false;
                _controller.reset();
                _controller.forward();
              });
            },
            isMobile: isMobile,
          ),
          const SizedBox(height: 24),
          Text(
            activeCategory == 'all' ? 'Featured Courses' : '${activeCategory[0].toUpperCase()}${activeCategory.substring(1)} Courses',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Learn from internationally recognized experts and build your expertise in dispute resolution.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayedCourses.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: CourseCard(course: displayedCourses[index]),
              );
            },
          ),
          const SizedBox(height: 16),
          if (filteredCourses.length > 6)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showMore = !showMore;
                  _controller.reset();
                  _controller.forward();
                });
              },
              child: Text(showMore ? 'Show Less' : 'View All ${filteredCourses.length} Courses'),
            ),
          const SizedBox(height: 24),
          const Footer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showToast('Button clicked!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
        shape: const CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Page not found',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;

  const Header({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Text('C', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('CIMA Learn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              Text('Dispute Resolution Training', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
            ],
          ),
        ],
      ),
      actions: isMobile
          ? [
              IconButton(
                icon: const Icon(Icons.menu, size: 24),
                onPressed: () {},
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search, size: 24),
                onPressed: () {},
                color: Theme.of(context).colorScheme.onSurface,
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 24),
                onPressed: () {},
                color: Theme.of(context).colorScheme.onSurface,
              ),
              TextButton(
                onPressed: () {},
                child: Text('Log In', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14)),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Sign Up'),
              ),
            ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/hero-legal-training.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x99000000), BlendMode.srcOver),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Master International Dispute Resolution',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Learn from world-class arbitrators and mediators.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Start Learning Today'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Explore Courses'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCategories extends StatelessWidget {
  final String activeCategory;
  final Function(String) onCategoryChange;
  final bool isMobile;

  const CourseCategories({super.key, required this.activeCategory, required this.onCategoryChange, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'all', 'name': 'All Courses', 'icon': Icons.public, 'count': 500},
      {'id': 'arbitration', 'name': 'International Arbitration', 'icon': Icons.gavel, 'count': 145},
      {'id': 'mediation', 'name': 'Mediation', 'icon': Icons.people, 'count': 89},
      {'id': 'commercial-law', 'name': 'Commercial Law', 'icon': Icons.description, 'count': 124},
      {'id': 'corporate-disputes', 'name': 'Corporate Disputes', 'icon': Icons.business, 'count': 67},
      {'id': 'compliance', 'name': 'Compliance & Ethics', 'icon': Icons.balance, 'count': 75},
    ];

    return SingleChildScrollView(
      scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
      padding: EdgeInsets.zero,
      child: isMobile
          ? Row(
              children: categories.map((cat) {
                bool isActive = activeCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(cat['icon'] as IconData, size: 18, color: isActive ? Colors.white : Theme.of(context).colorScheme.primary),
                    label: Text('${cat['name']} (${cat['count']})', style: TextStyle(fontSize: 14)),
                    onPressed: () => onCategoryChange(cat['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.white,
                      foregroundColor: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                );
              }).toList(),
            )
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((cat) {
                bool isActive = activeCategory == cat['id'];
                return ElevatedButton.icon(
                  icon: Icon(cat['icon'] as IconData, size: 18, color: isActive ? Colors.white : Theme.of(context).colorScheme.primary),
                  label: Text('${cat['name']} (${cat['count']})', style: TextStyle(fontSize: 14)),
                  onPressed: () => onCategoryChange(cat['id'] as String),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.white,
                    foregroundColor: isActive ? Colors.white : Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class Course {
  final String id;
  final String title;
  final String instructor;
  final double rating;
  final int reviewCount;
  final String duration;
  final int studentCount;
  final double price;
  final double? originalPrice;
  final String category;
  final String level;
  final String image;
  final bool isPopular;
  final bool isBestseller;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.studentCount,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.level,
    required this.image,
    this.isPopular = false,
    this.isBestseller = false,
  });
}

List<Course> getFilteredCourses(String category) {
  final allCourses = [
    Course(
      id: '1',
      title: 'International Commercial Arbitration: London Practice',
      instructor: 'Dr. Sarah Mitchell, QC',
      rating: 4.9,
      reviewCount: 2847,
      duration: '16 hours',
      studentCount: 12450,
      price: 299,
      originalPrice: 599,
      category: 'arbitration',
      level: 'Advanced',
      image: 'assets/images/arbitration-london.jpg',
      isPopular: true,
      isBestseller: true,
    ),
    Course(
      id: '2',
      title: 'Mediation Fundamentals for Business Disputes',
      instructor: 'Prof. Michael Chen',
      rating: 4.8,
      reviewCount: 1923,
      duration: '12 hours',
      studentCount: 8765,
      price: 199,
      originalPrice: 399,
      category: 'mediation',
      level: 'Beginner',
      image: 'assets/images/mediation-fundamentals.jpg',
      isPopular: true,
    ),
    Course(
      id: '3',
      title: 'Dubai International Arbitration Center (DIAC) Rules',
      instructor: 'Ahmed Al-Rashid, Esq.',
      rating: 4.7,
      reviewCount: 1456,
      duration: '10 hours',
      studentCount: 5432,
      price: 249,
      category: 'arbitration',
      level: 'Intermediate',
      image: 'assets/images/diac-rules.jpg',
    ),
    Course(
      id: '4',
      title: 'Commercial Law Essentials for Non-Lawyers',
      instructor: 'Lisa Thompson, LLB',
      rating: 4.6,
      reviewCount: 2134,
      duration: '14 hours',
      studentCount: 9876,
      price: 179,
      originalPrice: 299,
      category: 'commercial-law',
      level: 'Beginner',
      image: 'assets/images/commercial-law.jpg',
    ),
    Course(
      id: '5',
      title: 'Advanced Mediation Techniques',
      instructor: 'Dr. Aisha Patel',
      rating: 4.7,
      reviewCount: 987,
      duration: '18 hours',
      studentCount: 3456,
      price: 399,
      category: 'mediation',
      level: 'Advanced',
      image: 'assets/images/advanced-mediation.jpg',
    ),
    Course(
      id: '6',
      title: 'Corporate Compliance & Risk Management',
      instructor: 'Robert Williams, CPA',
      rating: 4.5,
      reviewCount: 1678,
      duration: '20 hours',
      studentCount: 6543,
      price: 329,
      originalPrice: 549,
      category: 'compliance',
      level: 'Intermediate',
      image: 'assets/images/compliance-risk.jpg',
    ),
    Course(
      id: '7',
      title: 'International Investment Arbitration',
      instructor: 'Prof. Elena Rodriguez',
      rating: 4.8,
      reviewCount: 892,
      duration: '22 hours',
      studentCount: 2987,
      price: 449,
      category: 'arbitration',
      level: 'Advanced',
      image: 'assets/images/investment-arbitration.jpg',
      isPopular: true,
    ),
    Course(
      id: '8',
      title: 'Construction Dispute Resolution',
      instructor: 'David Kumar, PE',
      rating: 4.7,
      reviewCount: 1245,
      duration: '15 hours',
      studentCount: 4321,
      price: 279,
      category: 'corporate-disputes',
      level: 'Intermediate',
      image: 'assets/images/construction-dispute.jpg',
    ),
    Course(
      id: '9',
      title: 'Ethics in International Arbitration',
      instructor: 'Dr. Marie Dubois',
      rating: 4.6,
      reviewCount: 756,
      duration: '8 hours',
      studentCount: 2165,
      price: 159,
      category: 'compliance',
      level: 'Beginner',
      image: 'assets/images/ethics-arbitration.jpg',
    ),
  ];

  if (category == 'all') return allCourses;
  return allCourses.where((course) => course.category == category).toList();
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(course.image, height: 180, width: double.infinity, fit: BoxFit.cover),
                if (course.isBestseller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      label: const Text('Bestseller'),
                      backgroundColor: Colors.yellow.withOpacity(0.9),
                      labelStyle: const TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.w500),
                    ),
                  ),
                if (course.isPopular)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      label: const Text('Popular'),
                      backgroundColor: Colors.green.withOpacity(0.9),
                      labelStyle: const TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('By ${course.instructor}', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${course.rating} (${course.reviewCount})', style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      const Icon(Icons.people, size: 16),
                      const SizedBox(width: 4),
                      Text('${course.studentCount}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(course.duration, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${course.price}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          if (course.originalPrice != null)
                            Text(
                              '\$${course.originalPrice}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(decoration: TextDecoration.lineThrough, color: Color(0xFF666666)),
                            ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Enroll Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Text(
            '© 2025 CIMA Learn Hub. All rights reserved.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Privacy Policy', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: Text('Terms of Service', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}