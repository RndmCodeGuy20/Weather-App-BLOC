import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

part 'weather_event.dart';

part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<WeatherEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<GetWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        // final weather = await _fetchWeather(event.cityName);
        WeatherFactory wf = WeatherFactory(
          "f42e199bc1d4cac47c821a6f43f6ef1f",
          language: Language.ENGLISH,
        );

        final weather = await wf.currentWeatherByLocation(
          event.position.latitude,
          event.position.longitude,
        );

        emit(WeatherSuccess(weather));
      } catch (e) {
        emit(WeatherFailure('Failed to fetch weather'));
      }
    });
  }
}
