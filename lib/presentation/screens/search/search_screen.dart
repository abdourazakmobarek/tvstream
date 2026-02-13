import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tvstream/l10n/app_localizations.dart';

import '../../../data/models/channel.dart';
import '../../../logic/channels_cubit.dart';
import '../../../core/app_theme.dart';
import '../../widgets/channel_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Channel> _filterChannels(List<Channel> channels, String query, String? category) {
    return channels.where((channel) {
      final matchesQuery = query.isEmpty ||
          channel.name.toLowerCase().contains(query.toLowerCase()) ||
          channel.nameAr.contains(query) ||
          channel.nameAr.toLowerCase().contains(query.toLowerCase());

      final matchesCategory = category == null || category.isEmpty || channel.category == category;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = ['Public', 'Private', 'Radio'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: GoogleFonts.cairo(color: AppTheme.textMain, fontSize: 14),
            cursorColor: AppTheme.primaryGreen,
            decoration: InputDecoration(
              hintText: 'ابحث عن قناة...',
              hintStyle: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
      body: BlocBuilder<ChannelsCubit, ChannelsState>(
        builder: (context, state) {
          if (state is ChannelsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (state is ChannelsLoaded) {
            final allChannels = [...state.channels, ...state.radioChannels];
            final filteredChannels = _filterChannels(allChannels, _searchQuery, _selectedCategory);

            return Column(
              children: [
                // Category Filters
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildCategoryChip('الكل', null),
                        const SizedBox(width: 8),
                        ...categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(_getCategoryName(cat, l10n), cat),
                        )),
                      ],
                    ),
                  ),
                ),
                // Results
                Expanded(
                  child: filteredChannels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text(l10n.noResults, style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 16)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredChannels.length,
                          itemBuilder: (context, index) {
                            return ChannelCard(channel: filteredChannels[index]);
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Public': return 'قنوات عمومية';
      case 'Private': return 'قنوات خاصة';
      case 'Radio': return 'إذاعات';
      default: return category;
    }
  }
}
