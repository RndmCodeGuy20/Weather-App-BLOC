part of 'weather_bloc.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class GetWeather extends WeatherEvent {
  final Position position;

  const GetWeather(this.position);

  @override
  List<Object> get props => [position];
}
