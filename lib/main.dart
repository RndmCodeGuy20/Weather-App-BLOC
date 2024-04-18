import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app_bloc/bloc/weather_bloc.dart';
import 'package:weather_app_bloc/screens/home_screen.dart';
import 'services/location.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      home: FutureBuilder(
        future: determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return BlocProvider(
              create: (context) =>
                  WeatherBloc()..add(GetWeather(snapshot.data as Position)),
              child: HomeScreen(
                position: snapshot.data as Position,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.black,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
