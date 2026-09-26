import '../../../support/business_test_harness.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:Kelivo/core/models/chat_input_data.dart';
import 'package:Kelivo/core/providers/assistant_provider.dart';
import 'package:Kelivo/core/providers/settings_provider.dart';
import 'package:Kelivo/features/home/widgets/chat_input_bar.dart';
import 'package:Kelivo/l10n/app_localizations.dart';

void main() {
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
    var sends = 0;
    var attachmentTaps = 0;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: assistant),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
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
    );
    await tester.pump();
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
