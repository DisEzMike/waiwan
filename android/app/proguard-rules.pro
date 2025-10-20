# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep OkHttp3 classes for image_cropper
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Keep UCrop classes
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# Keep Retrofit classes if used
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**

# Keep Gson classes for JSON serialization
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep all serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}