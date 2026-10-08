import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../domain/entities/threat_history_item.dart';

class ThreatFilterBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ThreatCategory? selectedCategory;
  final ValueChanged<ThreatCategory?> onCategoryChanged;
  final ThreatSeverity? selectedSeverity;
  final ValueChanged<ThreatSeverity?> onSeverityChanged;
  final VoidCallback onResetFilters;

  const ThreatFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedSeverity,
    required this.onSeverityChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = searchQuery.isNotEmpty ||
        selectedCategory != null ||
        selectedSeverity != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar
        Container(
          decoration: BoxDecoration(
            color: CyberColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: searchQuery.isNotEmpty
                  ? CyberColors.primaryBlue
                  : CyberColors.borderSubtle,
              width: 1.0,
            ),
            boxShadow: const [CyberColors.cardShadow],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Icon(Icons.search_rounded,
                    color: CyberColors.primaryBlue, size: 20),
              ),
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: CyberColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by target, threat type, reason, or date...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: CyberColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: CyberColors.textSecondary),
                  onPressed: () => onSearchChanged(''),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Category Filter Horizontal Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // "ALL" Category Chip
              _buildCategoryChip(
                label: 'ALL SCANS',
                icon: Icons.hub_outlined,
                isSelected: selectedCategory == null,
                onTap: () => onCategoryChanged(null),
              ),
              const SizedBox(width: 8),

              // 5 Individual Categories
              ...ThreatCategory.values.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildCategoryChip(
                    label: cat.label.toUpperCase(),
                    icon: cat.icon,
                    isSelected: isSelected,
                    onTap: () => onCategoryChanged(cat),
                  ),
                );
              }),

              if (hasActiveFilters) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onResetFilters,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: CyberColors.dangerSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CyberColors.dangerBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_off_rounded,
                            size: 14, color: CyberColors.criticalDanger),
                        const SizedBox(width: 5),
                        Text(
                          'RESET',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: CyberColors.criticalDanger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3. Severity Level Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Text(
                'SEVERITY:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: CyberColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              ...ThreatSeverity.values.reversed.map((sev) {
                final isSelected = selectedSeverity == sev;
                final color = _getSeverityColor(sev);

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () => onSeverityChanged(sev),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.12) : CyberColors.surfaceCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? color : CyberColors.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            sev.label,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? color : CyberColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? CyberColors.primarySoft
              : CyberColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? CyberColors.primaryBlue
                : CyberColors.borderSubtle,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? CyberColors.primaryBlue : CyberColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.4,
                color: isSelected ? CyberColors.primaryBlue : CyberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(ThreatSeverity severity) {
    switch (severity) {
      case ThreatSeverity.critical:
        return CyberColors.criticalDanger;
      case ThreatSeverity.high:
        return CyberColors.warning;
      case ThreatSeverity.medium:
        return const Color(0xFFD97706);
      case ThreatSeverity.low:
        return CyberColors.primaryBlue;
      case ThreatSeverity.safe:
        return CyberColors.success;
    }
  }
}
