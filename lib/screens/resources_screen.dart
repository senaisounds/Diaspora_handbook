import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/haptic_service.dart';

class ResourcesScreen extends StatelessWidget {
  final bool showAppBar;
  const ResourcesScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Handbook Resources'),
      ) : null,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'Emergency Contacts', Icons.emergency),
          _buildResourceTile(
            context,
            'Police / Emergency',
            '999 (or 112)',
            Icons.local_police,
            onTap: () => _launchPhone('999'),
          ),
          _buildResourceTile(
            context,
            'Ambulance',
            '193',
            Icons.medical_services,
            onTap: () => _launchPhone('193'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Accommodations', Icons.hotel),
          _buildResourceTile(
            context,
            'Official Hotel Partner',
            'Sheraton Addis Ababa\n+251 11 517 1717',
            Icons.bed,
            onTap: () => _launchPhone('+251115171717'),
          ),
          _buildResourceTile(
            context,
            'Accommodation Guide',
            'View map of nearby hotels',
            Icons.map,
            onTap: () {
              // Navigate to map with filter or open URL
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Transportation', Icons.directions_car),
          _buildResourceTile(
            context,
            'Official Shuttle',
            'Daily loops from 9AM - 10PM',
            Icons.directions_bus,
          ),
          _buildResourceTile(
            context,
            'Ride Hailing',
            'Uber, Bolt, and Yango are available',
            Icons.phone_iphone,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Local Guide', Icons.info),
          _buildResourceTile(
            context,
            'Currency',
            'Ethiopian Birr (ETB). 1 USD ≈ 55-60 ETB',
            Icons.currency_exchange,
          ),
          _buildResourceTile(
            context,
            'Sim Cards',
            'Ethio Telecom kiosks at airport and city',
            Icons.sim_card,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
        onTap: () {
          if (onTap != null) {
            HapticService.lightImpact();
            onTap();
          }
        },
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}

