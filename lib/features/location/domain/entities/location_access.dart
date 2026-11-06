/// Whether the app may read the location right now.
enum LocationAccess {
  /// Allowed while the app is in use, with precise positions.
  granted,

  /// Allowed, but positions are off by kilometers: useless for finding a way
  /// back, so it counts as missing access (mvp-scope.md §2.1).
  approximate,

  /// Not allowed yet; the system dialog can still be shown.
  denied,

  /// Refused for good; only the system settings can change it.
  deniedForever,

  /// Location services are switched off on the device.
  serviceDisabled,
}
