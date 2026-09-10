import 'package:lettuce_travel/features/schools/domain/entities/route_stop.dart';

/// An ordered sequence of stops served by one bus, with one assigned supervisor.
class BusRoute {
  const BusRoute({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.busId,
    required this.supervisorId,
    required this.stops,
    this.isActive = true,
  });

  final String id;
  final String schoolId;
  final String name;
  final String busId;

  /// Only this supervisor may start a trip on this route.
  final String supervisorId;

  final List<RouteStop> stops;
  final bool isActive;

  /// Stops in travel order for a morning pickup (home stops, then school).
  List<RouteStop> get stopsInPickupOrder =>
      <RouteStop>[...stops]..sort((RouteStop a, RouteStop b) => a.order.compareTo(b.order));

  /// Afternoon drop-off visits the same stops in reverse.
  List<RouteStop> get stopsInDropOffOrder =>
      <RouteStop>[...stops]..sort((RouteStop a, RouteStop b) => b.order.compareTo(a.order));

  RouteStop? stopById(String stopId) {
    for (final RouteStop stop in stops) {
      if (stop.id == stopId) return stop;
    }
    return null;
  }

  BusRoute copyWith({
    String? name,
    String? busId,
    String? supervisorId,
    List<RouteStop>? stops,
    bool? isActive,
  }) =>
      BusRoute(
        id: id,
        schoolId: schoolId,
        name: name ?? this.name,
        busId: busId ?? this.busId,
        supervisorId: supervisorId ?? this.supervisorId,
        stops: stops ?? this.stops,
        isActive: isActive ?? this.isActive,
      );
}
