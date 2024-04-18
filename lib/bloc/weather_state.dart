part of 'weather_bloc.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();
}

final class WeatherInitial extends WeatherState {
  @override
  List<Object> get props => [];
}

final class WeatherLoading extends WeatherState {
  @override
  List<Object> get props => [];
}

final class WeatherFailure extends WeatherState {
  final String message;

  const WeatherFailure(this.message);

  @override
  List<Object> get props => [message];
}

final class WeatherSuccess extends WeatherState {
  final Weather weather;

  const WeatherSuccess(this.weather);

  @override
  List<Object> get props => [weather];
}
