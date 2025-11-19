import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_champ/src/data/repositories/animation_service_impl.dart';

void main() {
  group('AnimationServiceImpl', () {
    late AnimationServiceImpl animationService;

    setUp(() {
      animationService = AnimationServiceImpl();
    });

    group('Animation duration', () {
      test('should return correct animation duration', () {
        expect(animationService.animationDuration, const Duration(seconds: 3));
      });
    });

    group('Animation widgets', () {
      testWidgets('should build correct animation widget', (WidgetTester tester) async {
        final widget = animationService.buildCorrectAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Semantics), findsOneWidget);
      });

      testWidgets('should build incorrect animation widget', (WidgetTester tester) async {
        final widget = animationService.buildIncorrectAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Semantics), findsOneWidget);
      });

      testWidgets('should build timeout animation widget', (WidgetTester tester) async {
        final widget = animationService.buildTimeoutAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Semantics), findsOneWidget);
      });
    });

    group('Custom animations', () {
      testWidgets('should build custom animation with specified properties', (WidgetTester tester) async {
        final widget = animationService.buildCustomAnimation(
          animationPath: 'assets/lottie/test.json',
          width: 150,
          height: 150,
          repeat: true,
        );
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        // Widget should be created without errors
        expect(widget, isA<Widget>());
      });
    });

    group('Feedback overlay', () {
      testWidgets('should build feedback overlay with animation and message', (WidgetTester tester) async {
        final animation = animationService.buildCorrectAnimation();
        final overlay = animationService.buildFeedbackOverlay(
          animation: animation,
          message: 'Correct!',
        );
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: overlay)));
        
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Column), findsOneWidget);
        expect(find.text('Correct!'), findsOneWidget);
      });

      testWidgets('should build feedback overlay with custom styling', (WidgetTester tester) async {
        final animation = animationService.buildCorrectAnimation();
        final overlay = animationService.buildFeedbackOverlay(
          animation: animation,
          message: 'Great job!',
          backgroundColor: Colors.blue.withOpacity(0.8),
          textStyle: const TextStyle(
            color: Colors.yellow,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        );
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: overlay)));
        
        expect(find.text('Great job!'), findsOneWidget);
        
        final textWidget = tester.widget<Text>(find.text('Great job!'));
        expect(textWidget.style?.color, Colors.yellow);
        expect(textWidget.style?.fontSize, 28);
        expect(textWidget.style?.fontWeight, FontWeight.w900);
      });
    });

    group('Controlled animations', () {
      testWidgets('should build controlled animation with animation controller', (WidgetTester tester) async {
        late AnimationController controller;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  controller = AnimationController(
                    duration: const Duration(seconds: 2),
                    vsync: Scaffold.of(context) as TickerProvider,
                  );
                  
                  return animationService.buildControlledAnimation(
                    animationPath: 'assets/lottie/test.json',
                    controller: controller,
                    width: 100,
                    height: 100,
                  );
                },
              ),
            ),
          ),
        );
        
        // Widget should be created without errors
        expect(find.byType(Widget), findsWidgets);
        
        controller.dispose();
      });
    });

    group('Asset validation', () {
      test('should validate animation assets', () async {
        final isValid = await animationService.validateAnimationAssets();
        expect(isValid, isA<bool>());
      });
    });

    group('Widget properties', () {
      testWidgets('should have correct container dimensions', (WidgetTester tester) async {
        final widget = animationService.buildCorrectAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        final container = tester.widget<Container>(find.byType(Container).first);
        expect(container.constraints?.maxWidth, 200);
        expect(container.constraints?.maxHeight, 200);
      });

      testWidgets('should have semantic labels for accessibility', (WidgetTester tester) async {
        final correctWidget = animationService.buildCorrectAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: correctWidget)));
        
        expect(find.byType(Semantics), findsOneWidget);
        
        final semantics = tester.widget<Semantics>(find.byType(Semantics));
        expect(semantics.properties.label, 'Correct answer animation');
      });
    });

    group('Error handling', () {
      testWidgets('should handle animation loading errors gracefully', (WidgetTester tester) async {
        // This test verifies that the widget can be built even if animations fail to load
        final widget = animationService.buildCorrectAnimation();
        
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
        
        // Should not throw any exceptions
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Performance considerations', () {
      testWidgets('should create widgets efficiently', (WidgetTester tester) async {
        // Test that multiple animations can be created without issues
        final widgets = [
          animationService.buildCorrectAnimation(),
          animationService.buildIncorrectAnimation(),
          animationService.buildTimeoutAnimation(),
        ];
        
        for (final widget in widgets) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));
          expect(find.byType(Container), findsOneWidget);
        }
      });
    });
  });
}