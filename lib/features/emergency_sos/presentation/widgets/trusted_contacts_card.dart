import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_colors.dart';
import '../../../../core/theme/glassmorphic_container.dart';
import '../../domain/entities/trusted_contact.dart';

class TrustedContactsCard extends StatelessWidget {
  final List<TrustedContact> contacts;
  final Function(TrustedContact) onAddContact;
  final Function(String) onRemoveContact;

  const TrustedContactsCard({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onRemoveContact,
  });

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController(text: 'Family Member');
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: CyberColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: CyberColors.borderSubtle, width: 1),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  color: CyberColors.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Add Trusted Contact',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: CyberColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  controller: nameController,
                  label: 'Full Name',
                  hint: 'e.g. Sarah Connor',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: relationshipController,
                  label: 'Relationship / Role',
                  hint: 'e.g. Attorney, Guardian, IT Lead',
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: phoneController,
                  label: 'Phone Number',
                  hint: 'e.g. +1 (555) 019-2831',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: emailController,
                  label: 'Email (Optional)',
                  hint: 'e.g. sarah@cyberdefense.org',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: CyberColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  final newContact = TrustedContact(
                    id: 'TC-${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    relationship: relationshipController.text.trim(),
                    phoneNumber: phone,
                    email: emailController.text.trim(),
                    isNotifyEnabled: true,
                    isAutoBeacon: true,
                  );
                  onAddContact(newContact);
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Contact',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      relationshipController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: CyberColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary),
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: CyberColors.textSecondary.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: CyberColors.primaryBlue, size: 18),
        filled: true,
        fillColor: CyberColors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CyberColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: CyberColors.primaryBlue),
        ),
      ),
    );
  }

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
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CyberColors.primarySoftBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.contact_phone_rounded,
                      color: CyberColors.primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'TRUSTED CONTACTS CIRCLE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: CyberColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showAddContactDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: CyberColors.primarySoftBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CyberColors.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: CyberColors.primaryBlue, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'ADD CONTACT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            'Emergency contacts will receive instant SMS threat alerts and location beacons during SOS.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: CyberColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          if (contacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CyberColors.borderSubtle),
              ),
              child: Center(
                child: Text(
                  'No trusted contacts configured. Add contacts to establish an emergency relay.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: CyberColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildContactTile(context, contact);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, TrustedContact contact) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CyberColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CyberColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: CyberColors.primarySoftBg,
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: CyberColors.primaryBlue,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        contact.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: CyberColors.primarySoftBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        contact.relationship.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: CyberColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phoneNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: CyberColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: CyberColors.riskSafeBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: CyberColors.riskSafe.withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Text(
              'BEACON ON',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: CyberColors.riskSafe,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: CyberColors.textSecondary,
              size: 18,
            ),
            tooltip: 'Remove Contact',
            onPressed: () => onRemoveContact(contact.id),
          ),
        ],
      ),
    );
  }
}
