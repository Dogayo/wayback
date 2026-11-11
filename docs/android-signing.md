<p align="right"><b>English</b> · <a href="android-signing.ru.md">Русский</a></p>

# Signing the Android build (JKS keystore)

Instructions for the `wayback` project (Flutter, Gradle Kotlin DSL, `applicationId = com.dogayo.wayback`).

The build is already ready for signing (#17): `android/app/build.gradle.kts` takes the upload key from `android/key.properties`, and without that file signs the release with the debug key. CI restores the key from GitHub secrets (§7) and does not publish a release signed with the debug key. What is left is to create the key (§1), the `key.properties` file (§2) and the secrets (§7) — this is done once, and only you know the passwords.

---

## 1. Create a keystore

`keytool` comes with the JDK that is installed together with Android Studio. Check:

```bash
keytool -help
```

On Fedora `keytool` is already in `/usr/bin` (the OpenJDK package). If the command is not found, use the JDK from Android Studio:

```bash
export PATH="$HOME/android-studio/jbr/bin:$PATH"
```

Create the key (put the file **outside the repository**, for example in `~/keys/`):

```bash
mkdir -p ~/keys && keytool -genkey -v -keystore ~/keys/wayback-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

What `keytool` asks for:

- **Keystore password** — the store password. Keep it in a password manager; it cannot be recovered.
- **First and last name / organization / city / country** — fill in freely (Google Play does not check this); the country is a two-letter code, for example `RU`.
- **Key password for `<upload>`** — can stay the same as the store password (Enter).

Check the contents:

```bash
keytool -list -v -keystore ~/keys/wayback-upload.jks -alias upload
```

> `-validity 10000` (~27 years) is a Google Play requirement: the key must stay valid at least until 22 October 2033.

---

## 2. The `android/key.properties` file

Create `android/key.properties` (do **not** commit it to git):

```properties
storePassword=STORE_PASSWORD
keyPassword=KEY_PASSWORD
keyAlias=upload
storeFile=/home/Dogayo/keys/wayback-upload.jks
```

`storeFile` is an absolute path or a path relative to `android/app/`. Do not use a backslash in passwords: in the `.properties` format it is an escape.

---

## 3. `.gitignore`

Already set up — in the root and in `android/.gitignore`:

```
# Android signing
android/key.properties
**/*.jks
**/*.keystore
```

Make sure the files did not get into the index:

```bash
git status --porcelain android/key.properties
```

---

## 4. Signing in `android/app/build.gradle.kts` (already wired up)

At the top of the file, **before** the `plugins` block:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside the `android { ... }` block, **before** `buildTypes`:

```kotlin
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
```

And replace the `buildTypes` block:

```kotlin
    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
```

The debug fallback keeps the build from failing on machines without `key.properties` (CI, another developer).

---

## 5. Build and check

```bash
flutter build appbundle --release
```

```bash
flutter build apk --release
```

Check which key signed the APK:

```bash
"$(ls ~/Android/Sdk/build-tools/*/apksigner | sort -V | tail -1)" verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

The SHA-256 fingerprint in the output must match what `keytool -list -v` shows for your keystore. If you see `CN=Android Debug`, the signing config was not picked up — check the path in `storeFile`.

---

## 6. If the key already exists

Nothing needs to be created — copy the `.jks` into `~/keys/` and follow steps 2–5. The alias can be found like this:

```bash
keytool -list -keystore ~/keys/wayback-upload.jks
```

---

## 7. CI (GitHub Actions)

The keystore does not go into the repository — `ci.yml` (job `build-android`) assembles it from four repository secrets. Set them from the terminal with `gh`, without copying anything by hand:

```bash
base64 -w0 ~/keys/wayback-upload.jks | gh secret set ANDROID_KEYSTORE_BASE64
```

```bash
gh secret set ANDROID_KEY_ALIAS --body upload
```

```bash
gh secret set ANDROID_STORE_PASSWORD
```

```bash
gh secret set ANDROID_KEY_PASSWORD
```

The last two commands ask for the value interactively, so the password does not end up in the shell history. Check that the secrets are in place (values are not shown):

```bash
gh secret list
```

What CI does:

- **Restore upload keystore** — decodes the keystore into a temporary runner directory and writes `android/key.properties`.
- **Verify signature** — prints the APK signing certificate (`apksigner verify --print-certs`).
- A tag release without the secrets, or signed with `CN=Android Debug`, **fails** — a debug-signed APK will not update an install signed with the real key. A manual run (`Run workflow`) without the secrets builds with the debug key and a warning.

---

## About losing the key

- Without Play App Signing, losing the `.jks` or its password means the app can no longer be updated — only a new listing with a new `applicationId`.
- With **Play App Signing** on (the default for new apps), your `.jks` is the *upload key*, and it can be reset through Google Play support. Google keeps the release signing key.
- Keep a backup of the `.jks` and the passwords somewhere safe (a password manager / encrypted storage), not in the repository.
