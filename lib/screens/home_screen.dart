import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app_bloc/services/date_time.dart';

import '../bloc/weather_bloc.dart';

class HomeScreen extends StatefulWidget {
  final Position position;

  const HomeScreen({
    super.key,
    required this.position,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationWidth;
  late Animation<AlignmentDirectional> _animationAlignment;
  double _width = 0.0;

  Position get position => widget.position;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animationWidth = Tween<double>(
      begin: 10,
      end: 350,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _animationAlignment = Tween<AlignmentDirectional>(
      begin: const AlignmentDirectional(0, 0),
      end: const AlignmentDirectional(3, -1.3),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          40,
          0,
          40,
          0,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(seconds: 1),
                alignment: const AlignmentDirectional(1, -0.1),
                child: AnimatedContainer(
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(seconds: 1),
                  width: _animationWidth.value,
                  height: _animationWidth.value,
                  decoration: const BoxDecoration(
                    color: Color(0xff673ab7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(seconds: 1),
                alignment: _animationAlignment.value,
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                  width: 500,
                  height: _animationWidth.value,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFAB40),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherSuccess) {
                    DateTimeService dateTimeService = DateTimeService();

                    DateTime now = DateTime.now();
                    DateTime sunrise = state.weather.sunrise!;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _width =
                            (now.difference(sunrise).inSeconds / 86400) * 350;
                      });
                    });
                    return RefreshIndicator(
                      color: const Color(0xFFFFAB40),
                      backgroundColor: Colors.black,
                      onRefresh: () {
                        BlocProvider.of<WeatherBloc>(context).add(
                          GetWeather(position),
                        );
                        return Future.value();
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height +
                              1.2 * kToolbarHeight,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 1.2 * kToolbarHeight),
                              Text(
                                '📍 ${state.weather.areaName}, ${state.weather.country}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontFamily:
                                      GoogleFonts.spaceGrotesk().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${dateTimeService.getGreetings()},',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  fontFamily:
                                      GoogleFonts.spaceGrotesk().fontFamily,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: Image.asset(
                                  'assets/${state.weather.weatherConditionCode! ~/ 100}.png',
                                  height: 200,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${state.weather.temperature!.celsius!.roundToDouble()}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: GoogleFonts.spaceGrotesk()
                                              .fontFamily,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          '°C', // TODO: make dynamic
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 24,
                                            fontWeight: FontWeight.w300,
                                            fontFamily:
                                                GoogleFonts.spaceGrotesk()
                                                    .fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    state.weather.weatherDescription!
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          GoogleFonts.spaceGrotesk().fontFamily,
                                    ),
                                  ),
                                  Text(
                                    // 'Feels like ${state.weather.tempFeelsLike!.celsius!.roundToDouble()}°C',
                                    "${dateTimeService.getFormattedDate()} · ${dateTimeService.getFormattedTime()}",
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      fontFamily:
                                          GoogleFonts.spaceGrotesk().fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/11.png',
                                        height: 50,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Sunrise',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Text(
                                            dateTimeService
                                                .getFormattedTimeforAPI(
                                                    state.weather.sunrise!),
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/12.png',
                                        height: 50,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Sunset',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Text(
                                            dateTimeService
                                                .getFormattedTimeforAPI(
                                              state.weather.sunset!,
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  AnimatedContainer(
                                    curve: Curves.easeInOut,
                                    duration: const Duration(seconds: 1),
                                    width: _width,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/11.png',
                                    height: 25,
                                  ),
                                  AnimatedContainer(
                                    curve: Curves.easeInOut,
                                    duration: const Duration(seconds: 1),
                                    width: MediaQuery.of(context).size.width -
                                        _width -
                                        105,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 15,
                                ),
                                child: Divider(
                                  color: Colors.grey[700],
                                  thickness: 0.5,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/13.png',
                                        height: 50,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Max Temp',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.weather.tempMax!.celsius!
                                                    .roundToDouble()
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  fontFamily:
                                                      GoogleFonts.spaceGrotesk()
                                                          .fontFamily,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  ' °C',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: GoogleFonts
                                                            .spaceGrotesk()
                                                        .fontFamily,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/14.png',
                                        height: 50,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Min Temp',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.weather.tempMin!.celsius!
                                                    .roundToDouble()
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  fontFamily:
                                                      GoogleFonts.spaceGrotesk()
                                                          .fontFamily,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  '°C',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: GoogleFonts
                                                            .spaceGrotesk()
                                                        .fontFamily,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 15,
                                ),
                                child: Divider(
                                  color: Colors.grey[700],
                                  thickness: 0.5,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/9.png',
                                        height: 50,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Wind Speed',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.weather.windSpeed!
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  fontFamily:
                                                      GoogleFonts.spaceGrotesk()
                                                          .fontFamily,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  ' km/h',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: GoogleFonts
                                                            .spaceGrotesk()
                                                        .fontFamily,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/8.png',
                                        height: 40,
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Feels Like',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              fontFamily:
                                                  GoogleFonts.spaceGrotesk()
                                                      .fontFamily,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                state.weather.tempFeelsLike!
                                                    .celsius!
                                                    .roundToDouble()
                                                    .toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                  fontFamily:
                                                      GoogleFonts.spaceGrotesk()
                                                          .fontFamily,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  '°C',
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w300,
                                                    fontFamily: GoogleFonts
                                                            .spaceGrotesk()
                                                        .fontFamily,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is WeatherFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Sit tight, we are fetching the weather for you!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
