import 'package:flutter/material.dart';

void main() => runApp(const LayoutShowcaseApp());

class LayoutShowcaseApp extends StatelessWidget {
  const LayoutShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Responsive UI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
        ),
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
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_titles[_index]} UI'),
        centerTitle: true,
      ),
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
            NavigationDestination(
              icon: Icon(_icons[i]),
              label: _titles[i],
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE
// ------------------------------------------------------------

class ProfileCardDemo extends StatelessWidget {
  const ProfileCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = MediaQuery.of(context).size.width;
            final isLarge = width >= 600;

            final cardWidth = isLarge
                ? 420.0
                : constraints.maxWidth.clamp(280.0, 380.0);

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: cardWidth,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: isLarge ? 140 : 110,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF5C6BC0),
                                    Color(0xFFAB47BC),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -42,
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: Colors.white,
                                child: const CircleAvatar(
                                  radius: 41,
                                  backgroundColor: Color(0xFF26A69A),
                                  child: Text(
                                    'IS',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 54),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ishaan Shaikh',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.verified,
                              size: 18,
                              color: Colors.blue,
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Flutter Developer',
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        const SizedBox(height: 18),
                        const Divider(height: 1),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Flexible(
                                child: _Stat(
                                  value: '128',
                                  label: 'Posts',
                                ),
                              ),
                              const _VerticalDivider(),
                              const Flexible(
                                child: _Stat(
                                  value: '4.2K',
                                  label: 'Followers',
                                ),
                              ),
                              const _VerticalDivider(),
                              const Flexible(
                                child: _Stat(
                                  value: '312',
                                  label: 'Following',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.grey[300],
    );
  }
}

// ------------------------------------------------------------
// SOCIAL POST
// ------------------------------------------------------------

class SocialPostDemo extends StatelessWidget {
  const SocialPostDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth >= 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isLarge ? 30 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLarge ? 750 : 600,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isLarge ? 22 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFFFCC80),
                            child: Text(
                              'NM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Narendra Modi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '2h ago · Delhi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_horiz),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Golden hour from the rooftop today 🌇 '
                        'Nothing beats coding with a view like this!',
                        style: TextStyle(fontSize: 14.5),
                      ),

                      const SizedBox(height: 12),

                      AspectRatio(
                        aspectRatio: isLarge ? 16 / 7 : 16 / 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFF8A65),
                                      Color(0xFF8D6E63),
                                      Color(0xFF5D4037),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.landscape,
                                  size: 70,
                                  color: Colors.white70,
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tag,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'sunset',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                          ),
                          const Text('248'),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                            ),
                          ),
                          const Text('36'),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              '1.2K views',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// PRODUCT
// ------------------------------------------------------------

class ProductCardDemo extends StatelessWidget {
  const ProductCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLarge = constraints.maxWidth >= 600;

            if (isLarge) {
              return _buildLargeProductLayout(
                orientation,
              );
            }

            return _buildMobileProductLayout();
          },
        );
      },
    );
  }

  Widget _buildMobileProductLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _productCard(320),
      ),
    );
  }

  Widget _buildLargeProductLayout(Orientation orientation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: _productImage(),
              ),
              const SizedBox(width: 25),
              Flexible(
                flex: 4,
                child: _productDetails(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCard(double width) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productImage(),
            _productDetails(),
          ],
        ),
      ),
    );
  }

  Widget _productImage() {
    return Stack(
      children: [
        Container(
          height: 190,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFE8EAF6),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: const Icon(
            Icons.headphones_rounded,
            size: 96,
            color: Color(0xFF5C6BC0),
          ),
        ),

        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '-25%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
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
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _productDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aura Wireless Headphones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Active noise cancelling · 30h battery',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text(
                '\$89.99',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C6BC0),
                ),
              ),
              Text(
                '\$119.99',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const Icon(
                Icons.star_rounded,
                size: 18,
                color: Colors.amber,
              ),
              const Text(
                '4.8',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    size: 18,
                  ),
                  label: const Text('Add to cart'),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    const Text(
                      '1',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// MUSIC PLAYER
// ------------------------------------------------------------

class MusicPlayerDemo extends StatelessWidget {
  const MusicPlayerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isLarge = constraints.maxWidth >= 600;
            final isLandscape =
                orientation == Orientation.landscape;

            if (isLarge || isLandscape) {
              return _largeMusicLayout();
            }

            return _mobileMusicLayout();
          },
        );
      },
    );
  }

  Widget _mobileMusicLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _musicContent(),
        ),
      ),
    );
  }

  Widget _largeMusicLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Row(
            children: [
              Expanded(
                child: _musicArtwork(),
              ),
              const SizedBox(width: 30),
              Flexible(
                child: _musicControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _musicContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _musicArtwork(),
        const SizedBox(height: 24),
        _musicControls(),
      ],
    );
  }

  Widget _musicArtwork() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7E57C2),
                    Color(0xFFEC407A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 110,
                color: Colors.white24,
              ),
            ),
          ),

          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0x40FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _musicControls() {
    return Column(
      children: [
        const Text(
          'Midnight City',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "M83 · Hurry Up, We're Dreaming",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 10),

        Slider(
          value: 0.35,
          onChanged: (_) {},
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1:24'),
              Text('-2:36'),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.shuffle_rounded,
                color: Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.skip_previous_rounded,
                size: 34,
              ),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(
                Icons.pause_rounded,
                size: 32,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.skip_next_rounded,
                size: 34,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.repeat_rounded,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
