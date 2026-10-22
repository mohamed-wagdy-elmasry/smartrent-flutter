# ProGuard/R8 rules for SmartRent
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.**
-dontwarn com.pusher.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**

# Keep Flutter and plugin classes
-keep class io.flutter.** { *; }
-keep class com.pusher.** { *; }
-keep class me.carda.awesome_notifications.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.play.core.** { *; }
