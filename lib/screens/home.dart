import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample news data
  final List<Map<String, String>> newsList = const [
    {
      'image': 'https://picsum.photos/800/400?random=1',
      'title': 'Breaking: Major Tech Company Announces Revolutionary AI Product',
      'description': 'The new AI-powered assistant promises to transform how we interact with technology in our daily lives.',
    },
    {
      'image': 'https://picsum.photos/800/400?random=2',
      'title': 'Scientists Discover New Species in Deep Ocean Expedition',
      'description': 'Researchers found several previously unknown marine creatures during their deep-sea exploration mission.',
    },
    {
      'image': 'https://picsum.photos/800/400?random=3',
      'title': 'Global Climate Summit Reaches Historic Agreement',
      'description': 'World leaders commit to ambitious carbon reduction targets in landmark environmental deal.',
    },
    {
      'image': 'https://picsum.photos/800/400?random=4',
      'title': 'Sports: Underdog Team Wins Championship Title',
      'description': 'In a stunning upset, the newcomers defeated the reigning champions in an thrilling final match.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_outlined),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: const Text('Home screen', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.grey[800],

          foregroundColor: Colors.black87,
        ),
        drawer: Drawer(
          backgroundColor: const Color(0xFFFDFDFD),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Profile Section (Google style)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFE8EAED),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'user@email.com',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                const SizedBox(height: 8),

                /// 🔹 Navigation Items
                _googleDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _googleDrawerItem(
                  icon: Icons.bookmark_border,
                  title: 'Saved',
                  onTap: () => Navigator.pop(context),
                ),
                _googleDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Navigator.pop(context),
                ),

                const Spacer(),

                const Divider(height: 1),

                _googleDrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Sign out',
                  isDanger: true,
                  onTap: () => Navigator.pop(context),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return NewsCard(
              imageUrl: news['image']!,
              title: news['title']!,
              description: news['description']!,
            );
          },
        ),
      );
  }

  Widget _googleDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isDanger ? Colors.red : Colors.black87,
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDanger ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const NewsCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            /// 🔹 Background Image (Darkened)
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.75),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            /// 🔹 Text Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
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