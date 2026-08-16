import 'package:flutter/material.dart';

void main() => runApp(const LayoutShowcaseApp());

class LayoutShowcaseApp extends StatelessWidget {
  const LayoutShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Row • Column • Stack',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C6BC0)),
      ),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _index = 0;
  final PageController _pageController = PageController();

  static const _titles = ['Profile', 'Post', 'Shop', 'Music'];
  static const _icons = [
    Icons.person_rounded,
    Icons.dynamic_feed_rounded,
    Icons.shopping_bag_rounded,
    Icons.music_note_rounded,
  ];
  static const _pages = [
    ProfileCardDemo(),
    SocialPostDemo(),
    ProductCardDemo(),
    MusicPlayerDemo(),
  ];

  void _goTo(int i) {
    setState(() => _index = i);
    _pageController.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_titles[_index]} UI'), centerTitle: true),
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _index = i),
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          for (var i = 0; i < _titles.length; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: _titles[i]),
        ],
      ),
    );
  }
}

class ProfileCardDemo extends StatelessWidget {
  const ProfileCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 340,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // STACK: banner + avatar that overflows below it
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFFAB47BC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -42, // negative → overlaps OUTSIDE the banner
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white, // acts as a border ring
                      child: const CircleAvatar(
                        radius: 41,
                        backgroundColor: Color(0xFF26A69A),
                        child: Text('IS',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 54), // room for the overflowing avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Ishaan Shaikh',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Icon(Icons.verified, size: 18, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 4),
              Text('Flutter Developer', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 18),
              const Divider(height: 1),
              // ROW of stats — each stat is its own small COLUMN
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _Stat(value: '128', label: 'Posts'),
                    _VerticalDivider(),
                    _Stat(value: '4.2K', label: 'Followers'),
                    _VerticalDivider(),
                    _Stat(value: '312', label: 'Following'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: Colors.grey[300]);
}

class SocialPostDemo extends StatelessWidget {
  const SocialPostDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER ROW: avatar | Column(name+time) | menu
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFFFCC80),
                      child: Text('NM', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Narendra Modi',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('2h ago · Delhi',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Golden hour from the rooftop today 🌇 Nothing beats coding with a view like this!',
                  style: TextStyle(fontSize: 14.5),
                ),
                const SizedBox(height: 12),
                // STACK: "photo" + Positioned badge on top
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF8A65), Color(0xFF8D6E63), Color(0xFF5D4037)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Icon(Icons.landscape, size: 70, color: Colors.white70),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tag, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('sunset',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // ACTION ROW with a Spacer pushing views to the right
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
                    const Text('248'),
                    const SizedBox(width: 12),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
                    const Text('36'),
                    const SizedBox(width: 12),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
                    const Spacer(),
                    Text('1.2K views',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductCardDemo extends StatelessWidget {
  const ProductCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 280,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STACK: image + two floating Positioned widgets
              Stack(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: const Icon(Icons.headphones_rounded,
                        size: 96, color: Color(0xFF5C6BC0)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('-25%',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aura Wireless Headphones',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Active noise cancelling · 30h battery',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey[600])),
                    const SizedBox(height: 10),
                    // PRICE ROW
                    Row(
                      children: [
                        const Text('\$89.99',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5C6BC0))),
                        const SizedBox(width: 8),
                        Text('\$119.99',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough)),
                        const Spacer(),
                        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                        const SizedBox(width: 3),
                        const Text('4.8', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // BUTTON + STEPPER ROW
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('Add to cart'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.remove, size: 18),
                                  visualDensity: VisualDensity.compact),
                              const Text('1',
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, size: 18),
                                  visualDensity: VisualDensity.compact),
                            ],
                          ),
                        ),
                      ],
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
}

class MusicPlayerDemo extends StatelessWidget {
  const MusicPlayerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // STACK: art + play button layered on top (alignment: center)
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7E57C2), Color(0xFFEC407A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.music_note_rounded,
                        size: 110, color: Colors.white24),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0x40FFFFFF), // white @ 25%
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 44, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Column(
              children: [
                Text('Midnight City',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("M83 · Hurry Up, We're Dreaming",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Slider(value: 0.35, onChanged: (_) {}),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1:24', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text('-2:36', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // CONTROLS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.shuffle_rounded, color: Colors.grey)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous_rounded, size: 34)),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.pause_rounded, size: 32),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next_rounded, size: 34)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.repeat_rounded, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
