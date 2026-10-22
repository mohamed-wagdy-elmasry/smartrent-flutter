import 'package:carbo/base/services/notification_service.dart';
import 'package:carbo/base/services/realtime_service.dart';
import 'package:carbo/base/widgets/logger.dart';
import 'package:flutter/material.dart';

final log = logger(NotificationScreenTest);

class NotificationScreenTest extends StatelessWidget {
  const NotificationScreenTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              onTap: () async {
                final userId = 1234;
                if (userId > 0) {
                  try {
                    final realtime = RealtimeService();
                    await realtime.init();
                    // await realtime.subscribeToUserChannel(userId);
                  
                  } catch (e) {
                    log.e(
                      '[SplashController] Failed to reconnect realtime: $e',
                    );
                  }
                } else {
                  log.w('[SplashController] Invalid userId: $userId');
                }
              },
                            title: Text("Init Pusher"),

            ),
            ListTile(
              onTap: () {
                NotificationService.show(
                  title: "Hello",
                  body: "Body",
                  channel: CarNotificationChannel.bookingAlerts,
                );
              },
              leading: Icon(Icons.notifications),
              title: Text("Show Booking Alerts"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            ListTile(
              onTap: () {
                NotificationService.show(
                  title: "Hello",
                  body: "Body",
                  channel: CarNotificationChannel.supportMessages,
                );
              },
              leading: Icon(Icons.notifications),
              title: Text("Show Support Messages"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            ListTile(
              onTap: () {
                NotificationService.show(
                  title: "Hello",
                  body: "Body",
                  channel: CarNotificationChannel.tripUpdates,
                );
              },
              leading: Icon(Icons.notifications),
              title: Text("Show Trip Updates"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            ListTile(
              onTap: () {
                NotificationService.show(
                  title: "Hello",
                  body: "Body",
                  channel: CarNotificationChannel.systemLogs,
                );
              },
              leading: Icon(Icons.notifications),
              title: Text("Show System Logs"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
            ListTile(
              onTap: () {
                NotificationService.show(
                  title: "Hello",
                  body: "Body",
                  channel: CarNotificationChannel.generalUpdates,
                );
              },
              leading: Icon(Icons.notifications),
              title: Text("Show General Updates"),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
