import 'package:moxie_fitness/main.dart';
import 'package:moxie_fitness/providers/notifications_provider.dart';
import 'package:provider/provider.dart';

MultiProvider providers = MultiProvider(
  providers: [
    Provider<NotificationsProvider>(
      builder: (_) => NotificationsProvider(),
      dispose: (_, provider) => provider.dispose(),
    ),
  ],
  child: MoxieApp(),
);
