
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/data/cities.dart';
import 'package:locora/types/index.dart';
import 'package:locora/utils/firebase/actions.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/utils/user_picture.dart';

class ProfileTab extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const ProfileTab({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final user = FirebaseAuth.instance.currentUser;
  City? _selectedCity;
  bool isLoading = true;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = user?.displayName ?? 'Traveler';
    _fetchCity();
  }

  Future<void> _fetchCity() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    final cityName = doc.data()?['city'];
    if (cityName != null) {
      _selectedCity = pakistaniCities.firstWhere(
        (c) => c.name.toLowerCase() == cityName.toLowerCase(),
        orElse: () => pakistaniCities[0],
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateCity(City city) async {
    if (user == null) return;
    setState(() => _selectedCity = city);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'city': city.name,
    });

    await saveSelectedCity(city);

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/');
    }
  }

  void _openEditName() {
    final controller = TextEditingController(text: _displayName);

    showFDialog(
      context: context,
      builder: (context, style, animation) => FDialog(
        style: style,
        animation: animation,
        direction: Axis.vertical,
        title: const Text('Edit display name'),
        body: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: FTextField(
            control: .managed(controller: controller),
            hint: 'Your name',
            autofocus: true,
          ),
        ),
        actions: [
          FButton(
            variant: .outline,
            onPress: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FButton(
            onPress: () async {
              final name = controller.text.trim();
              if (name.isEmpty || user == null) return;
              Navigator.pop(context);
              await updateUserDisplayName(name, user!.uid);
              setState(() => _displayName = name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openCityPicker() {
    final theme = FTheme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select City',
                                  style: theme.typography.xl.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose where you want to explore.',
                                  style: theme.typography.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            variant: FButtonVariant.ghost,
                            onPress: () => Navigator.pop(context),
                            child: const Icon(FIcons.x, size: 18),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: theme.colors.border.withValues(alpha: 0.5),
                    ),

                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: pakistaniCities.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final city = pakistaniCities[i];
                          final isSelected = _selectedCity?.name == city.name;

                          return FCard(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _updateCity(city);
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FBadge(
                                      variant: isSelected
                                          ? FBadgeVariant.secondary
                                          : FBadgeVariant.outline,
                                      child: Icon(
                                        isSelected
                                            ? FIcons.check
                                            : FIcons.building2,
                                        size: 14,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            city.name,
                                            style: theme.typography.sm.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isSelected
                                                  ? theme.colors.primary
                                                  : theme.colors.foreground,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            city.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.typography.xs.copyWith(
                                              height: 1.45,
                                              color:
                                                  theme.colors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colors.foreground,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(theme),
              const SizedBox(height: 28),
              _buildAvatar(theme),
              const SizedBox(height: 28),
              _buildDivider(theme),
              const SizedBox(height: 24),
              _buildCityCard(theme),
              const SizedBox(height: 24),
              _buildDivider(theme),
              const SizedBox(height: 24),
              _buildSettings(theme),
              const SizedBox(height: 24),
              _buildDivider(theme),
              const SizedBox(height: 24),
              _buildMenu(theme),
              const SizedBox(height: 32),
              _buildLogout(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(FThemeData theme) {
    return Row(
      children: [
        Text(
          'Profile',
          style: theme.typography.xl2.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(FThemeData theme) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colors.muted,
            border: Border.all(color: theme.colors.border, width: 1.5),
          ),
          child: ClipOval(child: getUserPicture(_displayName, user!.email!)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                style: theme.typography.xl.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                user?.email ?? '',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _openEditName,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: theme.colors.border, width: 0.8),
            ),
            child: Icon(
              FIcons.pencil,
              size: 15,
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard(FThemeData theme) {
    final city = _selectedCity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Your City', theme: theme),
        const SizedBox(height: 14),

        FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (city != null) ...[
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/onboarding/2.jpeg',
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.58),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: FButton(
                          variant: FButtonVariant.secondary,
                          onPress: _openCityPicker,
                          child: const Text('Change'),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FBadge(
                              variant: .outline,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(FIcons.building2, size: 14),
                                  const SizedBox(width: 6),
                                  Text(city.name),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              city.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.sm.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      FBadge(
                        variant: .outline,
                        child: Icon(FIcons.building2, size: 14),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No city selected',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your city to personalize recommendations and attractions.',
                        textAlign: TextAlign.center,
                        style: theme.typography.sm.copyWith(
                          height: 1.45,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FButton(
                        onPress: _openCityPicker,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FIcons.mapPin, size: 16),
                            SizedBox(width: 8),
                            Text('Select City'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Preferences', theme: theme),
        const SizedBox(height: 14),

        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.isDarkMode ? FIcons.moon : FIcons.sun,
                    size: 18,
                    color: theme.colors.foreground,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isDarkMode ? 'Dark mode' : "Light mode",
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.foreground,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        widget.isDarkMode
                            ? 'Dark appearance enabled'
                            : 'Light appearance enabled',
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),

                FSwitch(
                  value: widget.isDarkMode,
                  onChange: (t) => widget.onThemeToggle(t),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(FThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'Account', theme: theme),
        const SizedBox(height: 14),
        _MenuItem(
          icon: FIcons.heart,
          label: 'Saved Places',
          theme: theme,
          onTap: () {},
        ),
        _MenuDivider(theme: theme),
        _MenuItem(
          icon: FIcons.bellRing,
          label: 'Notifications',
          theme: theme,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLogout(FThemeData theme) {
    return FButton(
      onPress: () => logoutUser(context),
      variant: .destructive,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FIcons.logOut, size: 16),
          const SizedBox(width: 8),
          const Text('Log out'),
        ],
      ),
    );
  }

  Widget _buildDivider(FThemeData theme) =>
      Divider(height: 1, color: theme.colors.border);
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final FThemeData theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: theme.typography.xs.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colors.mutedForeground,
      letterSpacing: 1.1,
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final FThemeData theme;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colors.foreground),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colors.foreground,
              ),
            ),
          ),
          Icon(
            FIcons.chevronRight,
            size: 16,
            color: theme.colors.mutedForeground,
          ),
        ],
      ),
    ),
  );
}

class _MenuDivider extends StatelessWidget {
  final FThemeData theme;
  const _MenuDivider({required this.theme});

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 32,
    color: theme.colors.border.withValues(alpha: 0.5),
  );
}
