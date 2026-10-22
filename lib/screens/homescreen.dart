import 'dart:async';

import 'package:flutter/material.dart';
import 'analyzescreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  int _selectedIndex = 0;

  // ============================================================
  // SAMPLE MEDIA CAROUSEL
  // ============================================================

  late final PageController _sampleController;
  Timer? _sampleTimer;

  int _currentSample = 0;

  final List<Map<String, dynamic>> _sampleMedia = [
    {
      'title': 'Real Image',
      'label': 'REAL',
      'image': 'assets/samples/real_1.jpg',
      'isFake': false,
    },
    {
      'title': 'AI Generated Image',
      'label': 'FAKE',
      'image': 'assets/samples/fake_1.jpg',
      'isFake': true,
    },
    {
      'title': 'Real Image',
      'label': 'REAL',
      'image': 'assets/samples/real_2.jpg',
      'isFake': false,
    },
    {
      'title': 'AI Generated Image',
      'label': 'FAKE',
      'image': 'assets/samples/fake_2.jpg',
      'isFake': true,
    },
  ];

  // ============================================================
  // DEMO HISTORY
  // ============================================================

  final List<Map<String, dynamic>> _history = [
    {
      'title': 'Image Analysis',
      'date': 'Today, 2:15 PM',
      'result': 'Likely Real',
      'isFake': false,
      'icon': Icons.image_outlined,
    },
    {
      'title': 'Video Analysis',
      'date': 'Yesterday, 7:42 PM',
      'result': 'Likely Fake',
      'isFake': true,
      'icon': Icons.videocam_outlined,
    },
    {
      'title': 'Image Analysis',
      'date': 'Sep 22, 11:20 AM',
      'result': 'Likely Real',
      'isFake': false,
      'icon': Icons.image_outlined,
    },
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _sampleController = PageController(
      viewportFraction: 0.88,
    );

    _sampleTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!_sampleController.hasClients) {
          return;
        }

        _currentSample++;

        if (_currentSample >= _sampleMedia.length) {
          _currentSample = 0;
        }

        _sampleController.animateToPage(
          _currentSample,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _sampleTimer?.cancel();
    _sampleController.dispose();

    super.dispose();
  }

  // ============================================================
  // OPEN ANALYZE SCREEN
  // ============================================================

  void _openAnalyzeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyzeScreen(),
      ),
    );
  }

  // ============================================================
  // HOME SCREEN
  // ============================================================

  Widget _buildHomeScreen(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final scale = (screenWidth / 390).clamp(0.90, 1.15);

    final horizontalPadding = 20.0 * scale;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 18 * scale,
        ),
        children: [
          // ======================================================
          // APP HEADER
          // ======================================================

          Row(
            children: [
              Container(
                height: 36 * scale,
                width: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F1EE),
                  borderRadius: BorderRadius.circular(
                    10 * scale,
                  ),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: const Color(0xFF216B5C),
                  size: 22 * scale,
                ),
              ),

              SizedBox(width: 10 * scale),

              Text(
                'DeepShield',
                style: TextStyle(
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF17201F),
                ),
              ),
            ],
          ),

          SizedBox(height: 42 * scale),

          // ======================================================
          // MAIN HEADING
          // ======================================================

          Text(
            'See the truth\nbehind the image.',
            style: TextStyle(
              fontSize: 31 * scale,
              height: 1.08,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF18201F),
            ),
          ),

          SizedBox(height: 14 * scale),

          // ======================================================
          // DESCRIPTION
          // ======================================================

          Text(
            'Detect AI-generated images and videos '
            'using advanced AI technology.',
            style: TextStyle(
              fontSize: 16 * scale,
              height: 1.45,
              color: const Color(0xFF6B7472),
            ),
          ),

          SizedBox(height: 30 * scale),

          // ======================================================
          // WHAT ARE DEEPFAKES CARD
          // ======================================================

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(17 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7F6),
              borderRadius: BorderRadius.circular(
                17 * scale,
              ),
              border: Border.all(
                color: const Color(0xFFE0E8E5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 29 * scale,
                  width: 29 * scale,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDCE7E4),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    size: 18 * scale,
                    color: const Color(0xFF60706C),
                  ),
                ),

                SizedBox(width: 12 * scale),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What are deepfakes?',
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF27302E),
                        ),
                      ),

                      SizedBox(height: 7 * scale),

                      Text(
                        'Deepfakes are AI-generated or manipulated '
                        'media that can make people appear to say '
                        'or do things they never did.',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          height: 1.45,
                          color: const Color(0xFF737C79),
                        ),
                      ),

                      SizedBox(height: 9 * scale),

                      GestureDetector(
                        onTap: () {
                          // Learn more functionality later.
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Learn more',
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF216B5C),
                              ),
                            ),
                            SizedBox(width: 5 * scale),
                            Icon(
                              Icons.arrow_forward,
                              size: 15 * scale,
                              color: const Color(0xFF216B5C),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // SAMPLE MEDIA
          // ======================================================

          SizedBox(height: 25 * scale),

          _buildSampleCarousel(scale),

          // ======================================================
          // ANALYZE MEDIA BUTTON
          // ======================================================

          SizedBox(height: 25 * scale),

          SizedBox(
            width: double.infinity,
            height: 54 * scale,
            child: ElevatedButton(
              onPressed: _openAnalyzeScreen,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF216B5C),
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    15 * scale,
                  ),
                ),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    size: 21 * scale,
                  ),

                  SizedBox(width: 9 * scale),

                  Text(
                    'Analyze Media',
                    style: TextStyle(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 8 * scale),

                  Icon(
                    Icons.arrow_forward,
                    size: 20 * scale,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: screenHeight * 0.04,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SAMPLE CAROUSEL
  // ============================================================

  Widget _buildSampleCarousel(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'See how DeepShield works',
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF27302E),
          ),
        ),

        SizedBox(height: 5 * scale),

        Text(
          'Sample real and AI-generated media',
          style: TextStyle(
            fontSize: 12.5 * scale,
            color: const Color(0xFF7A8380),
          ),
        ),

        SizedBox(height: 14 * scale),

        SizedBox(
          height: 215 * scale,
          child: PageView.builder(
            controller: _sampleController,
            itemCount: _sampleMedia.length,

            onPageChanged: (index) {
              setState(() {
                _currentSample = index;
              });
            },

            itemBuilder: (context, index) {
              final item = _sampleMedia[index];

              final bool isFake =
                  item['isFake'] as bool;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5 * scale,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F6),
                    borderRadius:
                        BorderRadius.circular(
                      18 * scale,
                    ),
                    border: Border.all(
                      color: const Color(0xFFE0E8E5),
                    ),
                  ),

                  clipBehavior: Clip.antiAlias,

                  child: Stack(
                    children: [
                      // IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          item['image'] as String,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              color: const Color(
                                0xFFE8EFED,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 50,
                                  color: Color(
                                    0xFF7A8380,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // OVERLAY
                      Positioned.fill(
                        child: Container(
                          decoration:
                              const BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment.topCenter,
                              end:
                                  Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black54,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // BADGE
                      Positioned(
                        left: 12 * scale,
                        top: 12 * scale,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal:
                                10 * scale,
                            vertical:
                                6 * scale,
                          ),

                          decoration:
                              BoxDecoration(
                            color: isFake
                                ? const Color(
                                    0xFFD9534F,
                                  )
                                : const Color(
                                    0xFF216B5C,
                                  ),

                            borderRadius:
                                BorderRadius.circular(
                              20 * scale,
                            ),
                          ),

                          child: Text(
                            item['label'] as String,

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11 * scale,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // TITLE
                      Positioned(
                        left: 14 * scale,
                        bottom: 12 * scale,
                        child: Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * scale,
                            fontWeight:
                                FontWeight.w700,
                            shadows: const [
                              Shadow(
                                blurRadius: 5,
                                color:
                                    Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 10 * scale),

        // INDICATORS
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: List.generate(
            _sampleMedia.length,
            (index) {
              final bool isActive =
                  index == _currentSample;

              return AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 250,
                ),

                margin:
                    EdgeInsets.symmetric(
                  horizontal: 3 * scale,
                ),

                height: 6 * scale,

                width: isActive
                    ? 18 * scale
                    : 6 * scale,

                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF216B5C)
                      : const Color(0xFFD2DBD8),

                  borderRadius:
                      BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY SCREEN
  // ============================================================

  Widget _buildHistoryScreen() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          10,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFE4F1EE,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),

                  child: const Icon(
                    Icons.history,
                    color: Color(
                      0xFF216B5C,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  'History',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.w700,
                    color: Color(
                      0xFF18201F,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            const Text(
              'Your previous media analysis results',

              style: TextStyle(
                fontSize: 14,
                color: Color(
                  0xFF737C79,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _history.isEmpty
                  ? const Center(
                      child: Text(
                        'No analysis history yet.',
                        style: TextStyle(
                          color: Color(
                            0xFF737C79,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount:
                          _history.length,

                      separatorBuilder:
                          (context, index) {
                        return const SizedBox(
                          height: 12,
                        );
                      },

                      itemBuilder:
                          (context, index) {
                        final item =
                            _history[index];

                        final bool isFake =
                            item['isFake']
                                as bool;

                        return _historyCard(
                          item: item,
                          isFake: isFake,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HISTORY CARD
  // ============================================================

  Widget _historyCard({
    required Map<String, dynamic> item,
    required bool isFake,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(
          0xFFF4F7F6,
        ),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(
            0xFFE0E8E5,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color: const Color(
                0xFFE4F1EE,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              item['icon'] as IconData,
              color: const Color(
                0xFF216B5C,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  item['title'] as String,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 14,
                    color: Color(
                      0xFF27302E,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item['date'] as String,

                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(
                      0xFF7A8380,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: isFake
                  ? const Color(
                      0xFFFDE8E7,
                    )
                  : const Color(
                      0xFFE4F1EE,
                    ),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              item['result'] as String,

              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,

                color: isFake
                    ? const Color(
                        0xFFC43D38,
                      )
                    : const Color(
                        0xFF216B5C,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION ITEM
  // ============================================================

  Widget _bottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool selected =
        _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 7,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(
                  0xFFE4F1EE,
                )
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(16),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              selected
                  ? activeIcon
                  : icon,

              size: 21,

              color: selected
                  ? const Color(
                      0xFF216B5C,
                    )
                  : const Color(
                      0xFF7A8380,
                    ),
            ),

            const SizedBox(height: 2),

            Text(
              label,

              style: TextStyle(
                fontSize: 10,

                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,

                color: selected
                    ? const Color(
                        0xFF216B5C,
                      )
                    : const Color(
                        0xFF7A8380,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _selectedIndex == 0
          ? _buildHomeScreen(context)
          : _buildHistoryScreen(),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 68,

          margin:
              const EdgeInsets.fromLTRB(
            70,
            0,
            70,
            12,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color: const Color(
                0xFFE0E8E5,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.06),

                blurRadius: 15,

                offset:
                    const Offset(0, 5),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,

            children: [
              _bottomNavItem(
                icon:
                    Icons.home_outlined,

                activeIcon:
                    Icons.home,

                label: 'Home',

                index: 0,
              ),

              _bottomNavItem(
                icon:
                    Icons.history_outlined,

                activeIcon:
                    Icons.history,

                label: 'History',

                index: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}