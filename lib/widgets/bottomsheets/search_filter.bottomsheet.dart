import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/tag.dart';
import 'package:chaskiy/view_models/search_filter.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({
    required this.onSubmitted,
    required this.vm,
    required this.search,
    super.key,
  });

  final Search? search;
  final SearchFilterViewModel vm;
  final Function(Search) onSubmitted;

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  RangeValues? _priceValues;

  Search get search => widget.search!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ViewModelBuilder<SearchFilterViewModel>.reactive(
      viewModelBuilder: () => widget.vm,
      onViewModelReady: (vm) => vm.fetchSearchData(),
      disposeViewModel: false,
      builder:
          (_, vm, __) => Container(
            height: MediaQuery.sizeOf(context).height * .88,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 13, 10, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtrar búsqueda',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.5,
                                ),
                              ),
                              Text(
                                'Encuentra justo lo que necesitas',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _reset,
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  Expanded(
                    child:
                        vm.busy(vm.searchData)
                            ? const Center(child: BusyIndicator())
                            : _FilterContent(
                              vm: vm,
                              search: search,
                              priceValues: _resolvedPriceValues(vm),
                              onLayoutChanged:
                                  (value) =>
                                      setState(() => search.layoutType = value),
                              onSortChanged:
                                  (value) =>
                                      setState(() => search.sort = value),
                              onPriceChanged: (values) {
                                setState(() => _priceValues = values);
                                search.minPrice = values.start.toString();
                                search.maxPrice = values.end.toString();
                              },
                              onTagChanged: _toggleTag,
                              onLocationChanged:
                                  (value) =>
                                      setState(() => search.byLocation = value),
                            ),
                  ),
                  _ApplyBar(
                    onPressed: () {
                      widget.onSubmitted(search);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  RangeValues _resolvedPriceValues(SearchFilterViewModel vm) {
    if (_priceValues != null) return _priceValues!;
    final limits = vm.searchData?.priceRange;
    final min = limits?.isNotEmpty == true ? limits!.first : 0.0;
    final max = limits != null && limits.length > 1 ? limits[1] : 100.0;
    final selectedMin = double.tryParse(search.minPrice ?? '') ?? min;
    final selectedMax = double.tryParse(search.maxPrice ?? '') ?? max;
    return RangeValues(
      selectedMin.clamp(min, max),
      selectedMax.clamp(min, max),
    );
  }

  void _toggleTag(Tag tag) {
    setState(() {
      final tags = List<Tag>.from(search.tags ?? []);
      final selected = tags.any((item) => item.id == tag.id);
      if (selected) {
        tags.removeWhere((item) => item.id == tag.id);
      } else {
        tags.add(tag);
      }
      search.tags = tags;
    });
  }

  void _reset() {
    setState(() {
      search.layoutType = 'grid';
      search.sort = 'asc';
      search.minPrice = null;
      search.maxPrice = null;
      search.tags = [];
      search.byLocation = true;
      _priceValues = null;
    });
  }
}

class _FilterContent extends StatelessWidget {
  const _FilterContent({
    required this.vm,
    required this.search,
    required this.priceValues,
    required this.onLayoutChanged,
    required this.onSortChanged,
    required this.onPriceChanged,
    required this.onTagChanged,
    required this.onLocationChanged,
  });

  final SearchFilterViewModel vm;
  final Search search;
  final RangeValues priceValues;
  final ValueChanged<String> onLayoutChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<Tag> onTagChanged;
  final ValueChanged<bool> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    final validTags =
        (vm.searchData?.tags ?? [])
            .where((tag) => tag.name.trim().isNotEmpty)
            .toList();
    final limits = vm.searchData?.priceRange;
    final min = limits?.isNotEmpty == true ? limits!.first : 0.0;
    final max = limits != null && limits.length > 1 ? limits[1] : 100.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: HugeIcons.strokeRoundedGridView,
            title: 'Tipo de vista',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  icon: HugeIcons.strokeRoundedGridView,
                  label: 'Cuadrícula',
                  selected: search.layoutType == 'grid',
                  onTap: () => onLayoutChanged('grid'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectionCard(
                  icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                  label: 'Lista',
                  selected: search.layoutType == 'list',
                  onTap: () => onLayoutChanged('list'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle(
            icon: HugeIcons.strokeRoundedSortingAZ01,
            title: 'Ordenar resultados',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SelectionCard(
                  icon: HugeIcons.strokeRoundedSortByUp01,
                  label: 'A – Z',
                  selected: search.sort == 'asc',
                  onTap: () => onSortChanged('asc'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SelectionCard(
                  icon: HugeIcons.strokeRoundedSortByDown01,
                  label: 'Z – A',
                  selected: search.sort == 'desc',
                  onTap: () => onSortChanged('desc'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PriceSection(
            min: min,
            max: max,
            values: priceValues,
            onChanged: onPriceChanged,
          ),
          if (validTags.isNotEmpty) ...[
            const SizedBox(height: 26),
            const _SectionTitle(
              icon: HugeIcons.strokeRoundedTags,
              title: 'Filtrar por',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              runSpacing: 9,
              children:
                  validTags.map((tag) {
                    final selected = (search.tags ?? []).any(
                      (item) => item.id == tag.id,
                    );
                    return FilterChip(
                      selected: selected,
                      label: Text(tag.name.trim()),
                      avatar:
                          selected
                              ? const Icon(Icons.check_rounded, size: 17)
                              : null,
                      onSelected: (_) => onTagChanged(tag),
                      showCheckmark: false,
                      side: BorderSide(
                        color:
                            selected
                                ? AppColor.primaryColor
                                : Theme.of(context).colorScheme.outlineVariant,
                      ),
                      selectedColor: AppColor.primaryColor.withValues(
                        alpha: .12,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    );
                  }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          _LocationOption(
            value: search.byLocation ?? true,
            onChanged: onLocationChanged,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 21, color: AppColor.primaryColor),
        const SizedBox(width: 9),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected
              ? AppColor.primaryColor.withValues(alpha: .10)
              : Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color:
                  selected
                      ? AppColor.primaryColor
                      : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color:
                    selected
                        ? AppColor.primaryColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColor.primaryColor : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColor.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
  });
  final double min;
  final double max;
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle(
          icon: HugeIcons.strokeRoundedMoney03,
          title: 'Rango de precio',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _PricePill(value: values.start),
            const Spacer(),
            Text(
              'hasta',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            _PricePill(value: values.end),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max <= min ? min + 1 : max,
          divisions: max > min ? 100 : 1,
          labels: RangeLabels(
            _compactPrice(values.start),
            _compactPrice(values.end),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        _compactPrice(value),
        style: TextStyle(
          color: AppColor.primaryColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            HugeIcons.strokeRoundedLocation01,
            color: AppColor.primaryColor,
          ),
        ),
        title: const Text(
          'Cerca de mi ubicación',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text('Prioriza resultados disponibles cerca de ti'),
      ),
    );
  }
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          icon: const Icon(HugeIcons.strokeRoundedFilterHorizontal),
          label: Text(
            'Aplicar filtros'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

String _compactPrice(double value) {
  if (value.abs() >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)} M';
  }
  if (value.abs() >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)} mil';
  }
  return '\$${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}';
}
