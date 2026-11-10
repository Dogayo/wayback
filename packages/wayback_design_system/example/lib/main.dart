import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

void main() => runApp(const WaybackDesignSystemDemo());

class WaybackDesignSystemDemo extends StatefulWidget {
  const WaybackDesignSystemDemo({super.key});
  @override
  State<WaybackDesignSystemDemo> createState() =>
      _WaybackDesignSystemDemoState();
}

class _WaybackDesignSystemDemoState extends State<WaybackDesignSystemDemo> {
  ThemeMode _themeMode = ThemeMode.light;
  TargetPlatform _platform = TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Wayback design system',
    debugShowCheckedModeBanner: false,
    theme: WbTheme.light.copyWith(platform: _platform),
    darkTheme: WbTheme.dark.copyWith(platform: _platform),
    themeMode: _themeMode,
    home: _Catalog(
      themeMode: _themeMode,
      platform: _platform,
      onThemeChanged: (value) => setState(() => _themeMode = value),
      onPlatformChanged: (value) => setState(() => _platform = value),
    ),
  );
}

class _Catalog extends StatefulWidget {
  const _Catalog({
    required this.themeMode,
    required this.platform,
    required this.onThemeChanged,
    required this.onPlatformChanged,
  });
  final ThemeMode themeMode;
  final TargetPlatform platform;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<TargetPlatform> onPlatformChanged;
  @override
  State<_Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<_Catalog> {
  bool keepScreen = true;
  bool haptics = true;
  String units = 'metric';
  WbPointType pointType = WbPointType.car;
  bool carChip = true;
  int tab = 0;
  int nav = 0;

  void update(VoidCallback change) => setState(change);

  final sections = const [
    ('Foundations', Icons.grid_view_outlined),
    ('Actions', Icons.touch_app_outlined),
    ('Forms', Icons.edit_note_outlined),
    ('Content', Icons.view_agenda_outlined),
    ('Navigation', Icons.navigation_outlined),
    ('Wayfinding', Icons.explore_outlined),
    ('Feedback', Icons.notifications_none),
    ('Motion', Icons.animation_outlined),
  ];

  final sectionKeys = <String, GlobalKey>{
    'Foundations': GlobalKey(),
    'Actions': GlobalKey(),
    'Forms': GlobalKey(),
    'Content': GlobalKey(),
    'Navigation': GlobalKey(),
    'Wayfinding': GlobalKey(),
    'Feedback': GlobalKey(),
    'Motion': GlobalKey(),
  };

  Future<void> _scrollToSection(String section) async {
    final targetContext = sectionKeys[section]?.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: WbMotion.slow,
      curve: WbMotion.standard,
      alignment: .02,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.wbColors.surfaceContainer,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 840;
          return Row(
            children: [
              if (desktop)
                SizedBox(
                  width: 236,
                  child: _Sidebar(
                    sections: sections,
                    themeMode: widget.themeMode,
                    platform: widget.platform,
                    onThemeChanged: widget.onThemeChanged,
                    onPlatformChanged: widget.onPlatformChanged,
                    onSectionSelected: _scrollToSection,
                  ),
                ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (!desktop)
                      SliverAppBar(
                        pinned: true,
                        title: const _BrandLockup(),
                        actions: [
                          IconButton(
                            onPressed: () => widget.onThemeChanged(
                              widget.themeMode == ThemeMode.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light,
                            ),
                            tooltip: 'Сменить тему',
                            icon: Icon(
                              widget.themeMode == ThemeMode.light
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                            ),
                          ),
                          PopupMenuButton<TargetPlatform>(
                            tooltip: 'Платформа',
                            initialValue: widget.platform,
                            onSelected: widget.onPlatformChanged,
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: TargetPlatform.iOS,
                                child: Text('iOS'),
                              ),
                              PopupMenuItem(
                                value: TargetPlatform.android,
                                child: Text('Android'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        desktop ? 44 : 16,
                        32,
                        desktop ? 44 : 16,
                        96,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'WAYBACK DESIGN SYSTEM',
                                  style: context.wbText.labelMedium?.copyWith(
                                    color: context.wbColors.brand600,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Компоненты',
                                  style: context.wbText.displaySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Одна система для точного и спокойного интерфейса в пути. Переключите тему и платформу — механика изменится, бренд останется.',
                                  style: context.wbText.bodyLarge?.copyWith(
                                    color: context.wbColors.contentSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                KeyedSubtree(
                                  key: sectionKeys['Foundations'],
                                  child: _FoundationsSection(),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Actions'],
                                  child: _ActionsSection(
                                    onSave: _showSaved,
                                    onDelete: _showDelete,
                                  ),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Forms'],
                                  child: _FormsSection(state: this),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Content'],
                                  child: _ContentSection(state: this),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Navigation'],
                                  child: _NavigationSection(state: this),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Wayfinding'],
                                  child: const _WayfindingSection(),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Feedback'],
                                  child: _FeedbackSection(
                                    onDialog: _showDelete,
                                    onSheet: _showSheet,
                                  ),
                                ),
                                KeyedSubtree(
                                  key: sectionKeys['Motion'],
                                  child: const _MotionSection(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  void _showSaved() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Точка сохранена · точность ±8 м'),
      action: SnackBarAction(label: 'Переименовать', onPressed: _noop),
    ),
  );
  static void _noop() {}
  Future<void> _showDelete() => WbDialogs.confirm(
    context,
    title: 'Удалить «Машина»?',
    message: 'Вы потеряете сохранённое местоположение.',
    confirmLabel: 'Удалить',
    destructive: true,
  );
  void _showSheet() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => WbBottomSheet(
      title: 'Машина',
      child: Column(
        children: const [
          WbListItem(
            title: 'Вести к точке',
            leading: Icon(Icons.near_me_outlined),
            showDivider: true,
          ),
          WbListItem(
            title: 'Переименовать',
            leading: Icon(Icons.edit_outlined),
            showDivider: true,
          ),
          WbListItem(
            title: 'Удалить точку',
            leading: Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.sections,
    required this.themeMode,
    required this.platform,
    required this.onThemeChanged,
    required this.onPlatformChanged,
    required this.onSectionSelected,
  });
  final List<(String, IconData)> sections;
  final ThemeMode themeMode;
  final TargetPlatform platform;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<TargetPlatform> onPlatformChanged;
  final ValueChanged<String> onSectionSelected;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.wbColors.surfaceElevated,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandLockup(),
          const SizedBox(height: 32),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: TextButton.icon(
                key: ValueKey('sidebar-${section.$1}'),
                onPressed: () => onSectionSelected(section.$1),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: context.wbColors.contentSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: WbRadius.small,
                  ),
                ),
                icon: Icon(section.$2, size: 18),
                label: Text(section.$1, style: context.wbText.labelMedium),
              ),
            ),
          const Spacer(),
          Text(
            'ТЕМА',
            style: context.wbText.bodySmall?.copyWith(
              color: context.wbColors.contentTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          WbSegmentedTabs(
            items: const {ThemeMode.light: 'Light', ThemeMode.dark: 'Dark'},
            value: themeMode,
            onChanged: onThemeChanged,
          ),
          const SizedBox(height: 16),
          Text(
            'ПЛАТФОРМА',
            style: context.wbText.bodySmall?.copyWith(
              color: context.wbColors.contentTertiary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          WbSegmentedTabs(
            items: const {
              TargetPlatform.iOS: 'iOS',
              TargetPlatform.android: 'Android',
            },
            value: platform,
            onChanged: onPlatformChanged,
          ),
        ],
      ),
    ),
  );
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: context.wbColors.actionPrimaryBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset(
          WbAssets.logo,
          colorFilter: ColorFilter.mode(
            context.wbColors.contentOnBrand,
            BlendMode.srcIn,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          'WAYBACK',
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: context.wbText.titleLarge?.copyWith(letterSpacing: 1.5),
        ),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.components,
    required this.children,
  });
  final String title;
  final String components;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(title, style: context.wbText.headlineSmall),
            Text(
              components,
              style: context.wbText.bodySmall?.copyWith(
                color: context.wbColors.contentTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: context.wbColors.borderSubtle),
        const SizedBox(height: 14),
        Wrap(spacing: 14, runSpacing: 14, children: children),
      ],
    ),
  );
}

class _Specimen extends StatelessWidget {
  const _Specimen({required this.title, required this.child, this.width = 500});
  final String title;
  final Widget child;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: MediaQuery.sizeOf(context).width < 840 ? double.infinity : width,
    child: WbCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: context.wbText.bodySmall?.copyWith(
              color: context.wbColors.contentTertiary,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );
}

class _FoundationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    return _Section(
      title: 'Foundations',
      components: 'Color · Type · Spacing · Shape',
      children: [
        _Specimen(
          title: 'Семантические цвета',
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            children: [
              _Swatch('brand', colors.brand600),
              _Swatch('surface', colors.surfaceContainer),
              _Swatch('content', colors.contentPrimary),
              _Swatch('positive', colors.positive),
              _Swatch('warning', colors.warning),
              _Swatch('negative', colors.negative),
            ],
          ),
        ),
        _Specimen(
          width: 1014,
          title: 'Типографика · полная шкала',
          child: Column(
            children: [
              _TypographySample(
                name: 'displayLarge',
                specs: '88 / 96 · 700',
                sample: '640 м',
                style: context.wbText.displayLarge,
              ),
              _TypographySample(
                name: 'displaySmall',
                specs: '34 / 40 · 700',
                sample: '1.4 км',
                style: context.wbText.displaySmall,
              ),
              _TypographySample(
                name: 'headlineSmall',
                specs: '24 / 30 · 700',
                sample: 'Машина',
                style: context.wbText.headlineSmall,
              ),
              _TypographySample(
                name: 'titleLarge',
                specs: '20 / 26 · 600',
                sample: 'Удалить «Машина»?',
                style: context.wbText.titleLarge,
              ),
              _TypographySample(
                name: 'titleMedium',
                specs: '16 / 22 · 600',
                sample: 'Сохранённые точки',
                style: context.wbText.titleMedium,
              ),
              _TypographySample(
                name: 'bodyLarge',
                specs: '16 / 24 · 400',
                sample: 'Вы почти у цели — держите это направление.',
                style: context.wbText.bodyLarge,
              ),
              _TypographySample(
                name: 'bodyMedium',
                specs: '14 / 20 · 400',
                sample: '640 м · точность GPS ±8 м',
                style: context.wbText.bodyMedium,
              ),
              _TypographySample(
                name: 'labelLarge',
                specs: '15 / 20 · 600',
                sample: 'Сохранить местоположение',
                style: context.wbText.labelLarge,
              ),
              _TypographySample(
                name: 'labelMedium',
                specs: '13 / 18 · 600',
                sample: 'Активная',
                style: context.wbText.labelMedium,
              ),
              _TypographySample(
                name: 'bodySmall',
                specs: '12 / 16 · 500',
                sample: 'Точность GPS ±8 м',
                style: context.wbText.bodySmall,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypographySample extends StatelessWidget {
  const _TypographySample({
    required this.name,
    required this.specs,
    required this.sample,
    required this.style,
    this.showDivider = true,
  });

  final String name;
  final String specs;
  final String sample;
  final TextStyle? style;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 2,
        children: [
          Text(
            name,
            style: context.wbText.labelMedium?.copyWith(
              color: context.wbColors.brand600,
            ),
          ),
          Text(
            specs,
            style: context.wbText.bodySmall?.copyWith(
              color: context.wbColors.contentTertiary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(sample, style: style),
      if (showDivider) ...[
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 68,
    child: Column(
      children: [
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: WbRadius.small,
            border: Border.all(color: context.wbColors.borderSubtle),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.wbText.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({required this.onSave, required this.onDelete});
  final VoidCallback onSave;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Actions',
    components: 'Button · IconButton',
    children: [
      _Specimen(
        title: 'Варианты и состояния',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            WbButton(
              label: 'Сохранить местоположение',
              icon: Icons.add_location_alt_outlined,
              onPressed: onSave,
            ),
            WbButton(
              label: 'Переименовать',
              variant: WbButtonVariant.secondary,
              onPressed: _CatalogState._noop,
            ),
            WbButton(
              label: 'Готово',
              variant: WbButtonVariant.tertiary,
              onPressed: _CatalogState._noop,
            ),
            WbButton(
              label: 'Удалить',
              icon: Icons.delete_outline,
              variant: WbButtonVariant.destructive,
              onPressed: onDelete,
            ),
            const WbButton(label: 'Сохранение', loading: true),
            const WbButton(label: 'Нет сигнала GPS'),
          ],
        ),
      ),
      _Specimen(
        title: 'IconButton · 44×44',
        child: Wrap(
          spacing: 12,
          children: const [
            WbIconButton(
              icon: Icons.more_horiz,
              label: 'Ещё',
              onPressed: _CatalogState._noop,
            ),
            WbIconButton(
              icon: Icons.near_me_outlined,
              label: 'Вести к точке',
              variant: WbIconButtonVariant.brand,
              onPressed: _CatalogState._noop,
            ),
            WbIconButton(
              icon: Icons.share_outlined,
              label: 'Поделиться',
              variant: WbIconButtonVariant.filled,
              onPressed: _CatalogState._noop,
            ),
            WbIconButton(
              icon: Icons.delete_outline,
              label: 'Удалить',
              variant: WbIconButtonVariant.negative,
              onPressed: _CatalogState._noop,
            ),
          ],
        ),
      ),
    ],
  );
}

class _FormsSection extends StatelessWidget {
  const _FormsSection({required this.state});
  final _CatalogState state;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Forms',
    components: 'TextField · Checkbox · Radio · Switch · TypePicker',
    children: [
      const _Specimen(
        title: 'Ввод текста',
        child: Column(
          children: [
            WbTextField(
              label: 'Название точки',
              hint: 'Машина',
              helper: 'Так точка будет называться в списке.',
              leadingIcon: Icons.drive_file_rename_outline,
            ),
            SizedBox(height: 16),
            WbTextField(
              label: 'Поиск',
              hint: 'Найти точку',
              leadingIcon: Icons.search,
            ),
            SizedBox(height: 16),
            WbTextField(
              label: 'Название точки',
              hint: 'Машина',
              error: 'Введите название',
            ),
            SizedBox(height: 16),
            WbTextField(
              label: 'Заметка',
              hint: 'Второй ряд от въезда, у берёзы',
              helper: 'Необязательно.',
              minLines: 3,
              maxLines: 3,
            ),
          ],
        ),
      ),
      _Specimen(
        title: 'Выбор',
        child: Column(
          children: [
            WbCheckbox(
              value: state.keepScreen,
              label: 'Не гасить экран во время навигации',
              onChanged: (v) => state.update(() => state.keepScreen = v),
            ),
            const Divider(height: 24),
            WbRadio(
              value: 'metric',
              groupValue: state.units,
              label: 'Метры и километры',
              onChanged: (v) => state.update(() => state.units = v),
            ),
            WbRadio(
              value: 'imperial',
              groupValue: state.units,
              label: 'Футы и мили',
              onChanged: (v) => state.update(() => state.units = v),
            ),
            const Divider(height: 24),
            WbSwitch(
              value: state.haptics,
              label: 'Вибрация при прибытии',
              onChanged: (v) => state.update(() => state.haptics = v),
            ),
          ],
        ),
      ),
      _Specimen(
        width: 1014,
        title: 'TypePicker · фиксированный набор из восьми типов',
        child: WbTypePicker(
          value: state.pointType,
          onChanged: (v) => state.update(() => state.pointType = v),
        ),
      ),
    ],
  );
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.state});
  final _CatalogState state;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Content',
    components: 'ListItem · PointCard · Card · Badge · Chip · Avatar',
    children: [
      _Specimen(
        title: 'Сохранённые точки',
        child: Column(
          children: [
            WbListItem(
              title: 'Машина',
              subtitle: '640 м · точность ±8 м',
              selected: true,
              leading: const Icon(Icons.directions_car_outlined),
              trailing: const WbBadge(label: 'Активная', tone: WbTone.positive),
              showDivider: true,
            ),
            const WbListItem(
              title: 'Лагерь у озера',
              subtitle: '1.4 км · сохранено вчера',
              leading: Icon(Icons.cabin_outlined),
              trailing: Icon(Icons.chevron_right),
              showDivider: true,
            ),
            const WbListItem(
              title: 'Место рыбалки',
              subtitle: '3.8 км · точность ±24 м',
              leading: Icon(Icons.phishing_outlined),
              trailing: WbBadge(label: 'Слабый сигнал', tone: WbTone.warning),
            ),
          ],
        ),
      ),
      const _Specimen(
        title: 'PointCard · активная точка на главном',
        child: Column(
          children: [
            WbPointCard(
              title: 'Машина',
              distance: '640 м',
              typeIcon: Icons.directions_car_outlined,
              direction: WbPointDirection(
                icon: Icons.directions_car_outlined,
                rotation: 35,
              ),
            ),
            SizedBox(height: 12),
            WbPointCard(
              title: 'Лагерь',
              distance: '1,2 км',
              typeIcon: Icons.cabin_outlined,
              direction: WbPointDirection(
                icon: Icons.cabin_outlined,
                rotation: 240,
              ),
            ),
            SizedBox(height: 12),
            WbPointCard(
              title: 'Лагерь',
              distance: '1,2 км',
              typeIcon: Icons.cabin_outlined,
            ),
            SizedBox(height: 12),
            WbPointCardSkeleton(),
          ],
        ),
      ),
      _Specimen(
        title: 'Badge · Chip · Avatar',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                WbBadge(label: 'Активная', tone: WbTone.positive),
                WbBadge(label: 'Слабый сигнал', tone: WbTone.warning),
                WbBadge(label: 'Нет GPS', tone: WbTone.negative),
                WbBadge(label: 'Новая', tone: WbTone.brand),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                WbChip(
                  label: 'Машина',
                  icon: Icons.directions_car_outlined,
                  selected: state.carChip,
                  onSelected: (v) => state.update(() => state.carChip = v),
                ),
                const WbChip(label: 'Лагерь', icon: Icons.cabin_outlined),
                const WbChip(label: 'Рыбалка', icon: Icons.phishing_outlined),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                WbAvatar(name: 'Машина', brand: true),
                SizedBox(width: 12),
                WbAvatar(name: 'Лагерь'),
                SizedBox(width: 12),
                WbAvatar(name: 'Рыбалка', size: 32),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection({required this.state});
  final _CatalogState state;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Navigation',
    components: 'AppBar · BackButton · SegmentedTabs · BottomNav',
    children: [
      _Specimen(
        title: 'AppBar',
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.wbColors.borderSubtle),
                borderRadius: WbRadius.medium,
              ),
              child: const WbAppBar(
                title: 'Сохранённые точки',
                actions: [
                  WbIconButton(
                    icon: Icons.settings_outlined,
                    label: 'Настройки',
                    onPressed: _CatalogState._noop,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: context.wbColors.borderSubtle),
                borderRadius: WbRadius.medium,
              ),
              child: const WbAppBar(
                title: 'Машина',
                onBack: _CatalogState._noop,
              ),
            ),
          ],
        ),
      ),
      _Specimen(
        title: 'SegmentedTabs · BottomNav',
        child: Column(
          children: [
            WbSegmentedTabs(
              items: const {0: 'Список', 1: 'Компасс'},
              value: state.tab,
              onChanged: (v) => state.update(() => state.tab = v),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: WbRadius.medium,
              child: WbBottomNav(
                items: const [
                  WbBottomNavItem(
                    icon: Icons.explore_outlined,
                    label: 'Компас',
                  ),
                  WbBottomNavItem(icon: Icons.bookmark_outline, label: 'Точки'),
                  WbBottomNavItem(
                    icon: Icons.settings_outlined,
                    label: 'Настройки',
                  ),
                ],
                index: state.nav,
                onChanged: (v) => state.update(() => state.nav = v),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _WayfindingSection extends StatelessWidget {
  const _WayfindingSection();
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Wayfinding',
    components: 'DirectionDial · Illustration · PageDots',
    children: [
      _Specimen(
        width: 1014,
        title: 'Состояния компаса',
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 36,
          runSpacing: 32,
          children: const [
            _CompassSample(
              distance: '640 м',
              detail: 'ok · луч ±15°, GPS ±8 м',
              rotation: 34,
              spread: 15,
            ),
            _CompassSample(
              distance: '1.4 км',
              detail: 'unreliable · луч ±45°, GPS ±42 м',
              rotation: 68,
              spread: 45,
            ),
          ],
        ),
      ),
      _Specimen(
        width: 1014,
        title: 'Иллюстрации и шаги онбординга',
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 36,
          runSpacing: 32,
          children: [
            for (final kind in WbIllustrationKind.values)
              Column(
                children: [
                  WbIllustration(kind, size: 160),
                  const SizedBox(height: 12),
                  WbPageDots(count: 3, index: kind.index),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

class _CompassSample extends StatelessWidget {
  const _CompassSample({
    required this.distance,
    required this.detail,
    required this.rotation,
    required this.spread,
  });
  final String distance;
  final String detail;
  final double rotation;
  final double spread;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Column(
      children: [
        WbDirectionDial(
          rotation: rotation,
          spread: spread,
          size: 200,
          semanticLabel: detail,
        ),
        const SizedBox(height: 12),
        Text(distance, style: context.wbText.headlineSmall),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: context.wbText.bodySmall?.copyWith(
            color: context.wbColors.contentTertiary,
          ),
        ),
      ],
    ),
  );
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.onDialog, required this.onSheet});
  final VoidCallback onDialog;
  final VoidCallback onSheet;
  @override
  Widget build(BuildContext context) => _Section(
    title: 'Feedback',
    components: 'Alert · Snackbar · Dialog · BottomSheet · Progress · Skeleton',
    children: [
      const _Specimen(
        title: 'Alert',
        child: Column(
          children: [
            WbAlert(
              title: 'Компас не откалиброван',
              message:
                  'Опишите восьмёрку телефоном, чтобы стрелка стала точнее.',
              tone: WbTone.warning,
            ),
            SizedBox(height: 12),
            WbAlert(
              title: 'Нет доступа к геолокации',
              message:
                  'Разрешите доступ в настройках, чтобы видеть направление.',
              tone: WbTone.negative,
            ),
            SizedBox(height: 12),
            WbAlert(
              title: 'Точка сохранена',
              message: 'Точность GPS ±8 м.',
              tone: WbTone.positive,
            ),
          ],
        ),
      ),
      const _Specimen(
        title: 'Прогресс и загрузка',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WbProgress(label: 'Определяем местоположение…'),
            SizedBox(height: 16),
            WbProgress(label: 'Точность растёт', value: .64),
            SizedBox(height: 22),
            WbSkeleton(width: 220, height: 16),
            SizedBox(height: 10),
            WbSkeleton(width: 320),
            SizedBox(height: 10),
            WbSkeleton(width: 160),
            SizedBox(height: 20),
            WbSnackbar(
              message: 'Точка «Машина» удалена',
              actionLabel: 'Отменить',
            ),
          ],
        ),
      ),
      _Specimen(
        width: 1014,
        title: 'Платформенные слои',
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            WbButton(
              label: 'Открыть диалог',
              variant: WbButtonVariant.secondary,
              onPressed: onDialog,
            ),
            WbButton(
              label: 'Открыть шторку',
              variant: WbButtonVariant.tertiary,
              onPressed: onSheet,
            ),
          ],
        ),
      ),
    ],
  );
}

class _MotionSection extends StatelessWidget {
  const _MotionSection();

  @override
  Widget build(BuildContext context) => const _Section(
    title: 'Motion',
    components:
        'WbPage · WbStateSwitcher · WbSwipeActions · WbActionSheet · WbUndoSnackbar',
    children: [
      _Specimen(title: 'Переходы экранов', child: _TransitionsDemo()),
      _Specimen(title: 'Смена состояний', child: _StatesDemo()),
      _Specimen(title: 'Действия над точкой', child: _PointActionsDemo()),
      _Specimen(
        title: 'QR',
        width: 340,
        child: WbQrCode(data: 'wayback://app/import?lat=56.50353&lon=85.03131'),
      ),
    ],
  );
}

/// A phone-sized navigator to try each [WbTransition] in.
class _TransitionsDemo extends StatefulWidget {
  const _TransitionsDemo();

  @override
  State<_TransitionsDemo> createState() => _TransitionsDemoState();
}

class _TransitionsDemoState extends State<_TransitionsDemo> {
  final _stack = <WbTransition?>[null];

  WbPage<void> _page(int depth, WbTransition? transition) => WbPage(
    key: ValueKey(depth),
    transition: transition ?? WbTransition.drill,
    child: Scaffold(
      appBar: WbAppBar(
        title: depth == 0 ? 'Главный' : transition!.name,
        onBack: depth == 0 ? null : () => setState(_stack.removeLast),
      ),
      body: Center(child: Text('Экран ${depth + 1}')),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      ClipRRect(
        borderRadius: WbRadius.medium,
        child: SizedBox(
          width: 280,
          height: 420,
          child: Navigator(
            pages: [for (final (i, t) in _stack.indexed) _page(i, t)],
            onDidRemovePage: (_) {},
          ),
        ),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in WbTransition.values)
            WbButton(
              label: t.name,
              size: WbButtonSize.small,
              variant: WbButtonVariant.secondary,
              onPressed: () => setState(() => _stack.add(t)),
            ),
        ],
      ),
    ],
  );
}

enum _DemoState { loading, content, empty }

class _StatesDemo extends StatefulWidget {
  const _StatesDemo();

  @override
  State<_StatesDemo> createState() => _StatesDemoState();
}

class _StatesDemoState extends State<_StatesDemo> {
  var _state = _DemoState.loading;
  var _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: [
      WbStateSwitcher(
        state: _state,
        animateSize: true,
        child: switch (_state) {
          _DemoState.loading => const Column(
            spacing: WbSpacing.sm,
            children: [WbPointCardSkeleton(), WbPointCardSkeleton()],
          ),
          _DemoState.content => const Column(
            spacing: WbSpacing.sm,
            children: [
              WbPointCard(
                title: 'Машина',
                distance: '320 м',
                typeIcon: Icons.directions_car_outlined,
              ),
              WbPointCard(
                title: 'Лагерь',
                distance: '1,4 км',
                typeIcon: Icons.cabin_outlined,
              ),
              WbPointCard(
                title: 'Рыбалка',
                distance: '2,1 км',
                typeIcon: Icons.phishing_outlined,
              ),
            ],
          ),
          _DemoState.empty => const WbEmptyState(
            icon: Icons.add_location_alt_outlined,
            title: 'Пока нет точек',
            message: 'Сохраните место, чтобы вернуться к нему',
          ),
        },
      ),
      WbSegmentedTabs(
        items: {for (final s in _DemoState.values) s: s.name},
        value: _state,
        onChanged: (s) => setState(() => _state = s),
      ),
      WbButton(label: 'Сохранить', loading: _saving, onPressed: _save),
    ],
  );
}

class _PointActionsDemo extends StatefulWidget {
  const _PointActionsDemo();

  @override
  State<_PointActionsDemo> createState() => _PointActionsDemoState();
}

class _PointActionsDemoState extends State<_PointActionsDemo> {
  final _points = ['Машина', 'Лагерь', 'Рыбалка'];

  void _delete(String point) {
    final index = _points.indexOf(point);
    setState(() => _points.remove(point));
    WbUndoSnackbar.show(
      context,
      message: 'Точка «$point» удалена',
      actionLabel: 'Вернуть',
      onUndo: () => setState(() => _points.insert(index, point)),
    );
  }

  void _openSheet(String point) => WbActionSheet.show(
    context,
    title: point,
    subtitle: '640 м',
    icon: Icons.place_outlined,
    actions: [
      WbSheetAction(
        icon: Icons.edit_outlined,
        label: 'Переименовать',
        onSelected: _CatalogState._noop,
      ),
      WbSheetAction(
        icon: Icons.delete_outline,
        label: 'Удалить',
        destructive: true,
        onSelected: () => _delete(point),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => WbAnimatedItems<String>(
    items: _points,
    keyOf: (point) => point,
    itemBuilder: (context, point, isLast) => WbSwipeActions(
      actions: [
        WbSwipeAction(
          icon: Icons.edit_outlined,
          label: 'Переименовать',
          onPressed: _CatalogState._noop,
        ),
        WbSwipeAction(
          icon: Icons.delete_outline,
          label: 'Удалить',
          destructive: true,
          onPressed: () => _delete(point),
        ),
      ],
      child: WbListItem(
        title: point,
        showDivider: !isLast,
        onLongPress: () => _openSheet(point),
      ),
    ),
  );
}
