@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import 'golden_harness.dart';

const _bothPlatforms = [TargetPlatform.android, TargetPlatform.iOS];

void main() {
  goldenScene(
    'buttons',
    (context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GoldenGroup(
          'WbButton · variants',
          children: [
            WbButton(label: 'Сохранить', onPressed: noop),
            WbButton(
              label: 'Переименовать',
              variant: WbButtonVariant.secondary,
              onPressed: noop,
            ),
            WbButton(
              label: 'Пока пропустить',
              variant: WbButtonVariant.tertiary,
              onPressed: noop,
            ),
            WbButton(
              label: 'Удалить точку',
              variant: WbButtonVariant.destructive,
              onPressed: noop,
            ),
          ],
        ),
        GoldenGroup(
          'WbButton · small, icon, loading, disabled',
          children: [
            WbButton(
              label: 'Сохранить',
              size: WbButtonSize.small,
              onPressed: noop,
            ),
            WbButton(
              label: 'Отмена',
              size: WbButtonSize.small,
              variant: WbButtonVariant.secondary,
              onPressed: noop,
            ),
            WbButton(
              label: 'Сохранить место',
              icon: Icons.add_location_alt_outlined,
              onPressed: noop,
            ),
            WbButton(label: 'Сохранение', loading: true, onPressed: noop),
            WbButton(label: 'Сохранить'),
            WbButton(
              label: 'Переименовать',
              variant: WbButtonVariant.secondary,
            ),
          ],
        ),
        GoldenGroup(
          'WbIconButton',
          children: [
            WbIconButton(icon: Icons.more_vert, label: 'Ещё', onPressed: noop),
            WbIconButton(
              icon: Icons.add,
              label: 'Добавить',
              variant: WbIconButtonVariant.brand,
              onPressed: noop,
            ),
            WbIconButton(
              icon: Icons.my_location,
              label: 'Моё местоположение',
              variant: WbIconButtonVariant.filled,
              onPressed: noop,
            ),
            WbIconButton(
              icon: Icons.delete_outline,
              label: 'Удалить',
              variant: WbIconButtonVariant.negative,
              onPressed: noop,
            ),
          ],
        ),
      ],
    ),
  );

  goldenScene(
    'inputs',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WbTextField(label: 'Название точки', hint: 'Например, Машина'),
        const SizedBox(height: WbSpacing.md),
        WbTextField(
          label: 'Название точки',
          controller: TextEditingController(text: 'Машина'),
          helper: 'До 40 символов',
        ),
        const SizedBox(height: WbSpacing.md),
        WbTextField(
          label: 'Название точки',
          controller: TextEditingController(text: ''),
          error: 'Введите название',
        ),
        const SizedBox(height: WbSpacing.md),
        const WbTextField(
          label: 'Название точки',
          hint: 'Недоступно',
          enabled: false,
        ),
        const SizedBox(height: WbSpacing.xl),
        WbCheckbox(
          value: true,
          label: 'Показывать точность',
          onChanged: (_) {},
        ),
        WbCheckbox(value: false, label: 'Вибрация у цели', onChanged: (_) {}),
        const WbCheckbox(value: true, label: 'Недоступно'),
        const SizedBox(height: WbSpacing.md),
        WbRadio<String>(
          value: 'metric',
          groupValue: 'metric',
          label: 'Метры',
          onChanged: (_) {},
        ),
        WbRadio<String>(
          value: 'imperial',
          groupValue: 'metric',
          label: 'Футы',
          onChanged: (_) {},
        ),
        const SizedBox(height: WbSpacing.md),
        WbSwitch(value: true, label: 'Не гасить экран', onChanged: (_) {}),
        WbSwitch(value: false, label: 'Вибрация', onChanged: (_) {}),
      ],
    ),
    platforms: _bothPlatforms,
  );

  goldenScene(
    'content',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WbListItem(
          title: 'Машина',
          subtitle: '640 м · сохранено 12 мин назад',
          leading: WbAvatar(name: 'Машина'),
          trailing: WbBadge(label: '±8 м', tone: WbTone.positive),
          showDivider: true,
        ),
        const WbListItem(
          title: 'Лагерь',
          subtitle: '1.4 км · вчера',
          leading: WbAvatar(name: 'Лагерь', brand: true),
          selected: true,
        ),
        const SizedBox(height: WbSpacing.md),
        WbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('До машины', style: context.wbText.labelMedium),
              Text('640 м', style: context.wbText.displaySmall),
              Text('Точность GPS ±8 м', style: context.wbText.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: WbSpacing.xl),
        const GoldenGroup(
          'WbBadge',
          children: [
            WbBadge(label: 'Нейтральный'),
            WbBadge(label: 'Бренд', tone: WbTone.brand),
            WbBadge(label: 'Рядом', tone: WbTone.positive),
            WbBadge(label: 'Низкая точность', tone: WbTone.warning),
            WbBadge(label: 'Нет сигнала', tone: WbTone.negative),
          ],
        ),
        GoldenGroup(
          'WbChip · WbAvatar',
          children: [
            WbChip(label: 'Машина', selected: true, onSelected: (_) {}),
            WbChip(
              label: 'Лагерь',
              icon: Icons.cabin_outlined,
              onSelected: (_) {},
            ),
            const WbChip(label: 'Недоступно'),
            const WbAvatar(name: 'Машина'),
            const WbAvatar(name: 'Лагерь', brand: true),
          ],
        ),
        const GoldenGroup(
          'WbDivider',
          children: [SizedBox(width: 358, child: WbDivider())],
        ),
      ],
    ),
  );

  goldenScene(
    'navigation',
    (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WbAppBar(
          title: 'Машина',
          onBack: noop,
          actions: [
            WbIconButton(icon: Icons.more_vert, label: 'Ещё', onPressed: noop),
          ],
        ),
        const SizedBox(height: WbSpacing.xl),
        WbSegmentedTabs<int>(
          items: const {0: 'Все', 1: 'Рядом', 2: 'Недавние'},
          value: 0,
          onChanged: (_) {},
        ),
        const SizedBox(height: WbSpacing.xl),
        WbBottomNav(
          items: const [
            WbBottomNavItem(icon: Icons.explore_outlined, label: 'Компас'),
            WbBottomNavItem(icon: Icons.bookmark_outline, label: 'Точки'),
            WbBottomNavItem(icon: Icons.settings_outlined, label: 'Настройки'),
          ],
          index: 0,
          onChanged: (_) {},
        ),
      ],
    ),
    platforms: _bothPlatforms,
  );

  goldenScene(
    'feedback',
    (context) => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WbAlert(
          title: 'Низкая точность GPS',
          message: 'Отойдите от зданий и деревьев — точность ±42 м.',
          tone: WbTone.warning,
        ),
        SizedBox(height: WbSpacing.sm),
        WbAlert(
          title: 'Нет доступа к геолокации',
          message: 'Разрешите доступ в настройках, чтобы видеть направление.',
          tone: WbTone.negative,
        ),
        SizedBox(height: WbSpacing.sm),
        WbAlert(
          title: 'Компас откалиброван',
          message: 'Направление показывается точно.',
          tone: WbTone.positive,
        ),
        SizedBox(height: WbSpacing.sm),
        WbAlert(
          title: 'Офлайн',
          message: 'Направление и расстояние работают без сети.',
          tone: WbTone.brand,
        ),
        SizedBox(height: WbSpacing.xl),
        WbSnackbar(
          message: 'Точка «Машина» сохранена',
          actionLabel: 'Отменить',
          onAction: noop,
        ),
        SizedBox(height: WbSpacing.xl),
        WbProgress(label: 'Определяем местоположение', value: .4),
        SizedBox(height: WbSpacing.xl),
        // Align keeps the stretched column from overriding the widths.
        Align(
          alignment: Alignment.centerLeft,
          child: WbSkeleton(width: 220, height: 14),
        ),
        SizedBox(height: WbSpacing.xs),
        Align(alignment: Alignment.centerLeft, child: WbSkeleton(width: 300)),
      ],
    ),
  );

  goldenScene(
    'bottom_sheet',
    (context) => WbBottomSheet(
      title: 'Тип точки',
      child: Padding(
        padding: const EdgeInsets.all(WbSpacing.md),
        child: WbTypePicker(value: WbPointType.car, onChanged: (_) {}),
      ),
    ),
  );

  goldenScene(
    'compass',
    (context) => const Wrap(
      spacing: WbSpacing.md,
      runSpacing: WbSpacing.md,
      children: [
        WbCompassArrow(rotation: 35, size: 160),
        WbCompassArrow(
          rotation: 200,
          size: 160,
          state: WbCompassState.unreliable,
        ),
        WbCompassArrow(size: 160, state: WbCompassState.arrived),
      ],
    ),
  );

  group('dialog', () {
    for (final platform in _bothPlatforms) {
      for (final theme in GoldenTheme.values) {
        final suffix = '${platform.name}_${theme.name}';
        testWidgets('destructive confirm golden ($suffix)', (tester) async {
          await pumpGoldenApp(
            tester,
            theme: theme,
            platform: platform,
            height: 400,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: WbButton(
                    label: 'Удалить',
                    onPressed: () => WbDialogs.confirm(
                      context,
                      title: 'Удалить «Машина»?',
                      message: 'Вы потеряете сохранённое местоположение.',
                      confirmLabel: 'Удалить',
                      destructive: true,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(WbButton));
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('dialog_$suffix.png'),
          );
        });
      }
    }
  });
}
