import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';

class LocationSharingTile extends StatelessWidget {
  final bool isLocationShared;
  final String coordinates;
  final String address;
  final VoidCallback onToggle;

  const LocationSharingTile({
    super.key,
    required this.isLocationShared,
    required this.coordinates,
    required this.address,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberColors.borderSubtle, width: 1),
        boxShadow: CyberColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isLocationShared
                          ? CyberColors.riskCriticalBg
                          : CyberColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: isLocationShared
                          ? CyberColors.riskCritical
                          : CyberColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'SHARE EMERGENCY LOCATION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: isLocationShared,
                activeColor: CyberColors.riskCritical,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: CyberColors.borderSubtle,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Coordinate Telemetry Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CyberColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isLocationShared
                    ? CyberColors.riskCritical.withOpacity(0.3)
                    : CyberColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isLocationShared ? Icons.radar_rounded : Icons.location_off_outlined,
                  size: 18,
                  color: isLocationShared
                      ? CyberColors.riskCritical
                      : CyberColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isLocationShared ? coordinates : 'LOCATION MASKED',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isLocationShared
                                  ? CyberColors.textPrimary
                                  : CyberColors.textSecondary,
                            ),
                          ),
                          if (isLocationShared) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CyberColors.riskSafeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '±3.2m GPS LOCK',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: CyberColors.riskSafe,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLocationShared
                            ? address
                            : 'Enable toggle to attach real-time coordinates to emergency reports.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: CyberColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
