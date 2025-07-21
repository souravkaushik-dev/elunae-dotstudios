/*🔧 Under Design · DotStudios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:elunae/API/elunae.dart';
import 'package:elunae/extensions/l10n.dart';
import 'package:elunae/main.dart';
import 'package:elunae/screens/faq_sccreen.dart';
import 'package:elunae/screens/search_page.dart';
import 'package:elunae/services/data_manager.dart';
import 'package:elunae/services/router_service.dart';
import 'package:elunae/services/settings_manager.dart';
import 'package:elunae/services/update_manager.dart';
import 'package:elunae/style/app_colors.dart';
import 'package:elunae/style/app_themes.dart';
import 'package:elunae/utilities/common_variables.dart';
import 'package:elunae/utilities/flutter_bottom_sheet.dart';
import 'package:elunae/utilities/flutter_toast.dart';
import 'package:elunae/utilities/url_launcher.dart';
import 'package:elunae/utilities/utils.dart';
import 'package:elunae/widgets/bottom_sheet_bar.dart';
import 'package:elunae/widgets/confirmation_dialog.dart';
import 'package:elunae/widgets/custom_bar.dart';
import 'package:elunae/widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final activatedColor = Theme.of(context).colorScheme.secondaryContainer;
    final inactivatedColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                double roundedCorner = isCollapsed ? 20.0 : 30.0;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(
                    top: isCollapsed ? 0.0 : 80.0, // Adjust padding when collapsed
                    left: 16.0,
                  ),
                  title: Align(
                    alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown, // Ensures the text scales down to fit
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text(
                            'settings',
                            style: TextStyle(
                              fontFamily: 'displaymedium',
                              fontSize: isCollapsed ? 24.0 : 42.0, // Adjust font size for collapsed state
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Discover, and Explore Your Sound.',
                            style: TextStyle(
                              fontFamily: 'thin',
                              fontSize: isCollapsed ? 12.0 : 18.0,
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(roundedCorner),
                      ),
                    ),
                  ),
                );
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: commonSingleChildScrollViewPadding,
          child: Column(
            children: <Widget>[
              _buildPreferencesSection(
                context,
                primaryColor,
                activatedColor,
                inactivatedColor,
              ),
              if (!offlineMode.value)
                _buildOnlineFeaturesSection(
                  context,
                  activatedColor,
                  inactivatedColor,
                  primaryColor,
                ),
              _buildOthersSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(
    BuildContext context,
    Color primaryColor,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.preferences),
        CustomBar(
          context.l10n!.accentColor,
          Hicons.paletteLightOutline,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => _showAccentColorPicker(context),
        ),
        CustomBar(
          context.l10n!.themeMode,
          Hicons.sun2LightOutline,
          onTap:
              () => _showThemeModePicker(
                context,
                activatedColor,
                inactivatedColor,
              ),
        ),
        CustomBar(
          context.l10n!.audioQuality,
          Hicons.musicnoteLightOutline,
          onTap:
              () => _showAudioQualityPicker(
                context,
                activatedColor,
                inactivatedColor,
              ),
        ),
        CustomBar(
          context.l10n!.dynamicColor,
          HugeIcons.strokeRoundedToggleOn,
          trailing: Switch(
            value: useSystemColor.value,
            onChanged: (value) => _toggleSystemColor(context, value),
          ),
        ),
        if (themeMode == ThemeMode.dark)
          CustomBar(
            context.l10n!.pureBlackTheme,
            Hicons.colorPickerLightOutline,
            trailing: Switch(
              value: usePureBlackColor.value,
              onChanged: (value) => _togglePureBlack(context, value),
            ),
          ),
        ValueListenableBuilder<bool>(
          valueListenable: predictiveBack,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.predictiveBack,
              HugeIcons.strokeRoundedMoonSlowWind,
              trailing: Switch(
                value: value,
                onChanged: (value) => _togglePredictiveBack(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: offlineMode,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.offlineMode,
              HugeIcons.strokeRoundedWifiDisconnected02,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleOfflineMode(context, value),
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: backgroundPlay,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.backgroundPlay,

              HugeIcons.strokeRoundedChangeScreenMode,
              trailing: Switch(
                value: value,
                onChanged: (value) => _toggleBackgroundPlay(context, value),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOnlineFeaturesSection(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
    Color primaryColor,
  ) {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: playNextSongAutomatically,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.automaticSongPicker,
              HugeIcons.strokeRoundedMusicNote01,
              trailing: Switch(
                value: value,
                onChanged: (value) {
                  audioHandler.changeAutoPlayNextStatus();
                  showToast(context, context.l10n!.settingChangedMsg);
                },
              ),
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: defaultRecommendations,
          builder: (_, value, __) {
            return CustomBar(
              context.l10n!.originalRecommendations,
              HugeIcons.strokeRoundedBinaryCode,
              borderRadius: commonCustomBarRadiusLast,
              trailing: Switch(
                value: value,
                onChanged:
                    (value) => _toggleDefaultRecommendations(context, value),
              ),
            );
          },
        ),

        _buildToolsSection(context),
      ],
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.tools),
        CustomBar(
          context.l10n!.clearCache,
          HugeIcons.strokeRoundedClean,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () async {
            final cleared = await clearCache();
            showToast(
              context,
              cleared ? '${context.l10n!.cacheMsg}!' : context.l10n!.error,
            );
          },
        ),
        CustomBar(
          context.l10n!.clearSearchHistory,
          Hicons.rotateLeftLightOutline,
          onTap: () => _showClearSearchHistoryDialog(context),
        ),
        CustomBar(
          context.l10n!.clearRecentlyPlayed,
          Hicons.documentMinus1LightOutline,
          onTap: () => _showClearRecentlyPlayedDialog(context),
        ),

        CustomBar(
          context.l10n!.faqTitle,
          Hicons.warningLightOutline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FaqScreen()),
              );
            }
        ),
      ],
    );
  }

  Widget _buildOthersSection(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: context.l10n!.others),
        CustomBar(
          context.l10n!.licenses,
          Hicons.documentAlignLeft1LightOutline,
          borderRadius: commonCustomBarRadiusFirst,
          onTap: () => NavigationManager.router.go('/settings/license'),
        ),
        CustomBar(
          '${context.l10n!.copyLogs} (${logger.getLogCount()})',
          Hicons.dangerTriangleLightOutline,
          onTap: () async => showToast(context, await logger.copyLogs(context)),
        ),
        CustomBar(
         context.l10n!.about,
         Hicons.pinLightOutline,
          borderRadius: commonCustomBarRadiusLast,
         onTap: () => NavigationManager.router.go('/settings/about'),
        ),
      ],
    );
  }

  void _showAccentColorPicker(BuildContext context) {
    final isLight = themeMode == ThemeMode.light;

    showCustomBottomSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Pick an Accent Color',
              style: TextStyle(fontFamily: 'thin', fontSize: 18),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Nested inside scroll
            padding: const EdgeInsets.symmetric(vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = color == primaryColorSetting;

              return GestureDetector(
                onTap: () {
                  addOrUpdateData('settings', 'accentColor', color.value);
                  Navigator.of(context).pop();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                      isLight ? color.withAlpha(160) : color,
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }



  void _showThemeModePicker(
      BuildContext context,
      Color activatedColor,
      Color inactivatedColor,
      ) {
    final availableModes = [
      ThemeMode.system, // Auto (Follows device)
      ThemeMode.light,  // Day ☀️
      ThemeMode.dark,   // Night 🌙
    ];

    final Map<ThemeMode, String> modeLabels = {
      ThemeMode.system: 'Auto🌐',
      ThemeMode.light: 'Day ☀️',
      ThemeMode.dark: 'Night🌙',
    };

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableModes.length,
        itemBuilder: (context, index) {
          final mode = availableModes[index];
          final isSelected = themeMode == mode;
          final borderRadius = getItemBorderRadius(index, availableModes.length);

          return BottomSheetBar(
            modeLabels[mode] ?? mode.name,
                () {
              addOrUpdateData('settings', 'themeMode', mode.name);
              elunae.updateAppState(context, newThemeMode: mode);
              Navigator.pop(context);
            },
            isSelected ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }


  void _showLanguagePicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableLanguages = appLanguages.keys.toList();
    final activeLanguageCode = Localizations.localeOf(context).languageCode;
    final activeScriptCode = Localizations.localeOf(context).scriptCode;
    final activeLanguageFullCode =
        activeScriptCode != null
            ? '$activeLanguageCode-$activeScriptCode'
            : activeLanguageCode;

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableLanguages.length,
        itemBuilder: (context, index) {
          final language = availableLanguages[index];
          final newLocale = getLocaleFromLanguageCode(appLanguages[language]);
          final newLocaleFullCode =
              newLocale.scriptCode != null
                  ? '${newLocale.languageCode}-${newLocale.scriptCode}'
                  : newLocale.languageCode;

          final borderRadius = getItemBorderRadius(
            index,
            availableLanguages.length,
          );

          return BottomSheetBar(
            language,
            () {
              addOrUpdateData('settings', 'language', newLocaleFullCode);
              elunae.updateAppState(context, newLocale: newLocale);
              showToast(context, context.l10n!.languageMsg);
              Navigator.pop(context);
            },
            activeLanguageFullCode == newLocaleFullCode
                ? activatedColor
                : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _showAudioQualityPicker(
    BuildContext context,
    Color activatedColor,
    Color inactivatedColor,
  ) {
    final availableQualities = ['Breeze', 'Rhythm', ' Elune'];

    showCustomBottomSheet(
      context,
      ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: commonListViewBottmomPadding,
        itemCount: availableQualities.length,
        itemBuilder: (context, index) {
          final quality = availableQualities[index];
          final isCurrentQuality = audioQualitySetting.value == quality;
          final borderRadius = getItemBorderRadius(
            index,
            availableQualities.length,
          );

          return BottomSheetBar(
            quality,
            () {
              addOrUpdateData('settings', 'audioQuality', quality);
              audioQualitySetting.value = quality;
              showToast(context, context.l10n!.audioQualityMsg);
              Navigator.pop(context);
            },
            isCurrentQuality ? activatedColor : inactivatedColor,
            borderRadius: borderRadius,
          );
        },
      ),
    );
  }

  void _toggleSystemColor(BuildContext context, bool value) {
    addOrUpdateData('settings', 'useSystemColor', value);
    useSystemColor.value = value;
    elunae.updateAppState(
      context,
      newAccentColor: primaryColorSetting,
      useSystemColor: value,
    );
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePureBlack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'usePureBlackColor', value);
    usePureBlackColor.value = value;
    elunae.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _togglePredictiveBack(BuildContext context, bool value) {
    addOrUpdateData('settings', 'predictiveBack', value);
    predictiveBack.value = value;
    transitionsBuilder =
        value
            ? const PredictiveBackPageTransitionsBuilder()
            : const CupertinoPageTransitionsBuilder();
    elunae.updateAppState(context);
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleBackgroundPlay(BuildContext context, bool value) {
    addOrUpdateData('settings', 'backgroundPlay', value);
    backgroundPlay.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _toggleOfflineMode(BuildContext context, bool value) {
    addOrUpdateData('settings', 'offlineMode', value);
    offlineMode.value = value;

    // Trigger router refresh and notify about the change
    NavigationManager.refreshRouter();
    offlineModeChangeNotifier.value = !offlineModeChangeNotifier.value;

    showToast(context, context.l10n!.settingChangedMsg);
  }



  void _toggleDefaultRecommendations(BuildContext context, bool value) {
    addOrUpdateData('settings', 'defaultRecommendations', value);
    defaultRecommendations.value = value;
    showToast(context, context.l10n!.settingChangedMsg);
  }

  void _showClearSearchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearSearchHistoryQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit:
              () => {
                Navigator.of(context).pop(),
                searchHistory = [],
                deleteData('user', 'searchHistory'),
                showToast(context, '${context.l10n!.searchHistoryMsg}!'),
              },
        );
      },
    );
  }

  void _showClearRecentlyPlayedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          submitMessage: context.l10n!.clear,
          confirmationMessage: context.l10n!.clearRecentlyPlayedQuestion,
          onCancel: () => {Navigator.of(context).pop()},
          onSubmit:
              () => {
                Navigator.of(context).pop(),
                userRecentlyPlayed = [],
                deleteData('user', 'recentlyPlayedSongs'),
                showToast(context, '${context.l10n!.recentlyPlayedMsg}!'),
              },
        );
      },
    );
  }

}
