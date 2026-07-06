import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum Mood {
  happy,
  sad,
  stressed,
  sick,
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {

  //-------------------------------------------------------
  // Placeholder values
  //-------------------------------------------------------

  final int weeksPregnant = 7;
  final String childSize = "grape";

  Mood? selectedMood;

  final Map<Mood, String> motivation = {
    Mood.happy:
        "We're glad you're feeling happy today. Keep smiling and enjoy every moment of your pregnancy journey.",

    Mood.sad:
        "It's okay to have difficult days. Take some time to rest, speak with someone you trust, and remember you're not alone.",

    Mood.stressed:
        "Take slow deep breaths. Even a few minutes of relaxation can make a meaningful difference for both you and your baby.",
  };

  //-------------------------------------------------------
  // Colors
  //-------------------------------------------------------

  static const Color primaryPink = Color(0xFFAB0A65);

  static const Color topGradient = Color(0xFFFFCAE1);

  static const Color bottomGradient = Color(0xFFFFE8F2);

  //-------------------------------------------------------
  // Calendar
  //-------------------------------------------------------

  late final List<DateTime> weekDays;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    weekDays = List.generate(
      7,
      (index) => today.add(
        Duration(days: index - 3),
      ),
    );
  }

  //-------------------------------------------------------
  // Text Styles
  //-------------------------------------------------------

  TextStyle get titleStyle => GoogleFonts.gentiumBookPlus(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: primaryPink,
      );

  TextStyle get dayNumberStyle => GoogleFonts.gentiumBookPlus(
        fontWeight: FontWeight.bold,
        fontSize: 20,
      );

  TextStyle get dayTextStyle => GoogleFonts.gentiumBookPlus(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      );

  TextStyle get navTextStyle => GoogleFonts.gentiumBookPlus(
        fontWeight: FontWeight.bold,
        fontSize: 13,
        color: primaryPink,
      );

  TextStyle get motivationalStyle => GoogleFonts.gentiumBookPlus(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: primaryPink,
      );

  //-------------------------------------------------------
  String _moodLabel(Mood mood) {
  switch (mood) {
    case Mood.happy:
      return "Happy";

    case Mood.sad:
      return "Sad";

    case Mood.stressed:
      return "Stressed";

    case Mood.sick:
      return "Sick";
  }
}

String _moodIcon(Mood mood) {
  switch (mood) {
    case Mood.happy:
      return "assets/icons/happy.svg";

    case Mood.sad:
      return "assets/icons/sad.svg";

    case Mood.stressed:
      return "assets/icons/stressed.svg";

    case Mood.sick:
      return "assets/icons/sick.svg";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topGradient,
              bottomGradient,
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),

            child: Column(
              children: [

                //-------------------------------------------------
                // SETTINGS BUTTON
                //-------------------------------------------------

                Align(
                  alignment: Alignment.topRight,

                  child: IconButton(
                    onPressed: () {},

                    icon: SvgPicture.asset(
                      "assets/icons/settings.svg",
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //-------------------------------------------------
                // FIRST CARD
                //-------------------------------------------------

                ClipRRect(
                  borderRadius: BorderRadius.circular(28),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),

                    child: Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: .18),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(28),

                        border: Border.all(
                          color: Colors.white.withValues(alpha: .4),
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          //-------------------------------------
                          // TITLE
                          //-------------------------------------

                          Text(
                            "Congrats! You're $weeksPregnant weeks in!",
                            style: titleStyle,
                          ),

                      const SizedBox(height: 18),

//-------------------------------------
// CALENDAR
//-------------------------------------

LayoutBuilder(
  builder: (context, constraints) {
    final itemWidth = (constraints.maxWidth - 18) / 7;

    return Row(
      children: List.generate(
        weekDays.length,
        (index) {
          final day = weekDays[index];
          final bool today = index == 3;

          return SizedBox(
            width: itemWidth,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 42,
                height: 66,
                decoration: BoxDecoration(
                  color: today
                      ? primaryPink
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: today
                      ? [
                          BoxShadow(
                            color: primaryPink.withValues(alpha: .25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      day.day.toString(),
                      style: dayNumberStyle.copyWith(
                        color: today
                            ? Colors.white
                            : primaryPink,
                      ),
                    ),
                    Text(
                      [
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat",
                        "Sun"
                      ][day.weekday - 1],
                      style: dayTextStyle.copyWith(
                        color: today
                            ? Colors.white
                            : primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  },
),

                          const SizedBox(height: 22),

                          //-------------------------------------
                          // BABY CARD
                          //-------------------------------------

                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.all(20),

                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(
                                Radius.circular(28),
                              ),

                              gradient: RadialGradient(
                                center: Alignment(0.05, -0.2),
                                radius: 1.75,

                                colors: [
                                  Color(0xFFFFD0D3),
                                  Color(0xFFEB88FF),
                                ],
                              ),
                            ),

                            child: Column(
                              children: [

                                Text(
                                  "Your child is now the size of a $childSize",

                                  textAlign: TextAlign.center,

                                  style: titleStyle,
                                ),

                                const SizedBox(height: 28),

                                SizedBox(
                                  height: 80,

                                  child: Image.asset(
                                    "/images/grape.png",
                                    fit: BoxFit.contain,

                                    errorBuilder:
                                        (context, error, stack) {
                                      return const Icon(
                                        Icons.eco,
                                        size: 90,
                                        color: Colors.orange,
                                      );
                                    },
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

                const SizedBox(height: 28),

                //-------------------------------------------------
                // SECOND CARD
                //-------------------------------------------------

                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: .18),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "How are you feeling today?",
                              style: titleStyle,
                            ),

                            const SizedBox(height: 22),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: Mood.values.map((mood) {
                                final bool isSelected =
                                    selectedMood == mood;

                                final bool hide =
                                    selectedMood != null &&
                                        selectedMood != mood;

                                return AnimatedOpacity(
                                  opacity: hide ? 0.0 : 1.0,
                                  duration: const Duration(
                                      milliseconds: 300),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeOut,
                                    alignment: isSelected
                                        ? Alignment.centerLeft
                                        : Alignment.center,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (mood == Mood.sick) {
                                          Navigator.pushNamed(
                                            context,
                                            "/symptom-input",
                                          );
                                          return;
                                        }

                                        setState(() {
                                          selectedMood = mood;
                                        });
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            _moodIcon(mood),
                                            width: 48,
                                            height: 48,
                                          ),

                                          const SizedBox(height: 8),

                                          Text(
                                            _moodLabel(mood),
                                            style: navTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 350),

                              child: selectedMood == null
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      key: ValueKey(selectedMood),
                                      padding:
                                          const EdgeInsets.only(top: 26),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            _moodIcon(selectedMood!),
                                            width: 52,
                                            height: 52,
                                          ),

                                          const SizedBox(width: 18),

                                          Expanded(
                                            child: Text(
                                              motivation[selectedMood]!,
                                              style:
                                                  motivationalStyle,
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
                  ),
                ),

                const SizedBox(height: 40),

                //-------------------------------------------------
                // BOTTOM NAVIGATION
                //-------------------------------------------------

                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [

                        //-----------------------------------
                        // HOME
                        //-----------------------------------

                        _buildBottomNavItem(
                          icon: "assets/icons/home.svg",
                          label: "Home",
                          selected: true,
                          onTap: () {},
                        ),

                        //-----------------------------------
                        // DIAGNOSIS
                        //-----------------------------------

                        _buildBottomNavItem(
                          icon: "assets/icons/diagnosis.svg",
                          label: "Diagnosis",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/symptom-input",
                            );
                          },
                        ),

                        //-----------------------------------
                        // GUIDES
                        //-----------------------------------

                        _buildBottomNavItem(
                          icon: "assets/icons/guides.svg",
                          label: "Guides",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/guides",
                            );
                          },
                        ),

                        //-----------------------------------
                        // PROFILE
                        //-----------------------------------

                        _buildBottomNavItem(
                          icon: "assets/icons/profile.svg",
                          label: "Profile",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/profile",
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-------------------------------------------------------
  // Bottom Navigation Item
  //-------------------------------------------------------

  Widget _buildBottomNavItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SvgPicture.asset(
              icon,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                selected
                    ? primaryPink
                    : primaryPink.withValues(alpha: .75),
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              label,
              style: navTextStyle.copyWith(
                color: selected
                    ? primaryPink
                    : primaryPink.withValues(alpha: .75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}