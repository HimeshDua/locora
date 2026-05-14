import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/screens/essentials/tabs/map_tab.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';

class MapTabWrapper extends StatefulWidget {
  final City city;

  const MapTabWrapper({super.key, required this.city});

  @override
  State<MapTabWrapper> createState() => _MapTabWrapperState();
}

class _MapTabWrapperState extends State<MapTabWrapper> {
  late Future<List<Place>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = fetchPlacesByCity(widget.city.name);
  }

  Future<void> _refresh() async {
    setState(() {
      _placesFuture = fetchPlacesByCity(widget.city.name);
    });

    await _placesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return FutureBuilder<List<Place>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _MapStatusView(
            icon: FIcons.map,
            title: 'Loading map',
            message: 'Finding places in ${widget.city.name}...',
            theme: theme,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          );
        }

        if (snapshot.hasError) {
          return _MapStatusView(
            icon: FIcons.mapPinOff,
            title: 'Map unavailable',
            message: 'Could not load places for ${widget.city.name}.',
            theme: theme,
            child: FButton(onPress: _refresh, child: const Text('Retry')),
          );
        }

        return MapTab(city: widget.city, places: snapshot.data ?? const []);
      },
    );
  }
}

class _MapStatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final FThemeData theme;
  final Widget child;

  const _MapStatusView({
    required this.icon,
    required this.title,
    required this.message,
    required this.theme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colors.border, width: 0.8),
              ),
              child: Icon(icon, color: theme.colors.mutedForeground),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
