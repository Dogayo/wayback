/// Whether the app may read the location right now.
enum LocationAccess {
  /// Allowed while the app is in use.
  granted,

  /// Not allowed yet; the system dialog can still be shown.
  denied,

  /// Refused for good; only the system settings can change it.
  deniedForever,

  /// Location services are switched off on the device.
  serviceDisabled,
}
