# Flutter Local Notifications and Gson Proguard rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses

# Keep Flutter Local Notifications plugin classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Keep Gson type tokens and adapters
-keep class com.google.gson.** { *; }
-keepclassmembers class * extends com.google.gson.TypeAdapter {
    public <init>(...);
}
-keepclassmembers class * extends com.google.gson.reflect.TypeToken {
    *;
}
-keep class * extends com.google.gson.reflect.TypeToken {
    *;
}
-dontwarn com.google.gson.**
