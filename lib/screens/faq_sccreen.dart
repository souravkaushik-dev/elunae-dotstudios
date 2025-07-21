import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, String>> faqList = [
    {
      'question': 'How does Elunae work?',
      'answer': 'Elunae is a music app that uses YouTube APIs to stream songs, fetch recommendations, and provide a smooth and visually immersive music experience.',
    },
    {
      'question': 'Why does Elunae feel laggy or slow on some devices?',
      'answer': 'Elunae uses advanced visual libraries like Liquid Glass and Glassmorphic effects, which may be heavy on low-RAM devices. We’re actively working on optimizing performance to ensure smoother experience across all phones.',
    },
    {
      'question': 'Why does music playback or search feel slow sometimes?',
      'answer': 'Elunae relies on YouTube APIs for streaming and searching. Sometimes, high traffic or network delays on YouTube’s end can cause slower responses. We’re working to improve caching and responsiveness for a better experience.',
    }
  ];

  late List<bool> _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = List.generate(faqList.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 100,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'FAQ',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: faqList.length,
                  (context, index) {
                final faq = faqList[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isOpen[index] = !_isOpen[index];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 60,
                          borderRadius: 20,
                          blur: 20,
                          alignment: Alignment.center,
                          border: 1.5,
                          linearGradient: LinearGradient(
                            colors: isDark
                                ? [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ]
                                : [
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Center(
                                  child: Text(
                                    faq['question']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'regular',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isOpen[index]
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _isOpen[index]
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          borderRadius: 16,
                          blur: 15,
                          alignment: Alignment.center,
                          border: 1.5,
                          linearGradient: LinearGradient(
                            colors: isDark
                                ? [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ]
                                : [
                              Colors.white.withOpacity(0.35),
                              Colors.white.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          height: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontFamily: 'thin',
                                fontWeight: FontWeight.w100,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
