import '../../../support/business_test_harness.dart';

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:Kelivo/theme/palettes.dart';
import 'package:Kelivo/theme/theme_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Kelivo/core/models/chat_input_data.dart';
import 'package:Kelivo/core/providers/assistant_provider.dart';
import 'package:Kelivo/core/providers/settings_provider.dart';
import 'package:Kelivo/features/home/widgets/chat_input_bar.dart';
import 'package:Kelivo/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    if (Platform.environment['CAPTURE_UI'] != 'true') return;
    final font = File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
    if (await font.exists()) {
      final loader = FontLoader('Roboto');
      loader.addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
      await loader.load();
    }
    final icons = FontLoader('packages/lucide_icons_flutter/Lucide');
    icons.addFont(rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'));
    await icons.load();
  });
  testWidgets('phone composer sends text and exposes attachment actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final settings = SettingsProvider(createBusinessTestPreferences());
    await settings.loaded;
    final assistant = AssistantProvider(
      preferences: createBusinessTestPreferences(),
    );
    final controller = TextEditingController(text: 'Hello');
    addTearDown(controller.dispose);
    final previewKey = GlobalKey();
    var sends = 0;
    var attachmentTaps = 0;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: assistant),
        ],
        child: MaterialApp(
          theme: buildLightThemeForScheme(ThemePalettes.monochrome.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: previewKey,
            child: Scaffold(
              backgroundColor: const Color(0xFFF6F6F6),
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ChatInputBar(
                controller: controller,
                sendButtonTooltip: 'Send test message',
                onMore: () => attachmentTaps++,
                onSend: (_) async {
                  sends++;
                  return ChatInputSubmissionResult.rejected;
                },
              ),
            ),
          ),
          ),
        ),
      ),
    );
    await tester.pump();
    if (Platform.environment['CAPTURE_UI'] == 'true') {
      await tester.runAsync(() async {
        final boundary = previewKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/ui-previews/composer-light.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Select Model'), findsNothing);
    await tester.tap(find.byTooltip('Send test message'));
    await tester.pump();
    expect(sends, 1);
    // The leading control reveals the existing toolbar and attachment picker.
    final more = find.byTooltip('Add');
    await tester.tap(more.first);
    await tester.pumpAndSettle();
    expect(more, findsNWidgets(2));
    await tester.tap(more.last);
    expect(attachmentTaps, 1);
    expect(tester.takeException(), isNull);
  });
}
