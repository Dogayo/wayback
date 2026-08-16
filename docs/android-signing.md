# Подпись Android-сборки (JKS keystore)

Инструкция для проекта `wayback` (Flutter, Gradle Kotlin DSL, `applicationId = com.dogayo.wayback`).

Сейчас release-сборка подписывается debug-ключом (`android/app/build.gradle.kts`, блок `buildTypes.release`). Ниже — как создать свой ключ и переключить сборку на него.

---

## 1. Создать keystore

`keytool` входит в JDK, который ставится вместе с Android Studio. Проверить:

```bash
keytool -help
```

Если команда не найдена — используйте JDK из Android Studio:

```bash
export PATH="/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin:$PATH"
```

Создание ключа (файл кладём **вне репозитория**, например в `~/keys/`):

```bash
mkdir -p ~/keys && keytool -genkey -v -keystore ~/keys/wayback-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Что спросит `keytool`:

- **Keystore password** — пароль хранилища. Запишите в менеджер паролей, восстановить нельзя.
- **First and last name / организация / город / страна** — можно заполнить свободно (для Google Play это не проверяется), страна — двухбуквенный код, например `RU`.
- **Key password for `<upload>`** — можно оставить тем же, что и пароль хранилища (Enter).

Проверить содержимое:

```bash
keytool -list -v -keystore ~/keys/wayback-upload.jks -alias upload
```

> `-validity 10000` (~27 лет) — требование Google Play: ключ должен быть валиден минимум до 22 октября 2033 года.

---

## 2. Файл `android/key.properties`

Создайте `android/key.properties` (в git **не** коммитить):

```properties
storePassword=ПАРОЛЬ_ХРАНИЛИЩА
keyPassword=ПАРОЛЬ_КЛЮЧА
keyAlias=upload
storeFile=/Users/dogayo/keys/wayback-upload.jks
```

`storeFile` — абсолютный путь либо путь относительно каталога `android/app/`.

---

## 3. Добавить в `.gitignore`

В корневой `.gitignore` проекта:

```
# Android signing
android/key.properties
**/*.jks
**/*.keystore
```

Убедитесь, что файлы не попали в индекс:

```bash
git status --porcelain android/key.properties
```

---

## 4. Подключить подпись в `android/app/build.gradle.kts`

В начало файла, **до** блока `plugins`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Внутрь блока `android { ... }`, **перед** `buildTypes`:

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

И заменить блок `buildTypes`:

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

Фолбэк на debug нужен, чтобы сборка не падала на машинах без `key.properties` (CI, другой разработчик).

---

## 5. Собрать и проверить

```bash
flutter build appbundle --release
```

```bash
flutter build apk --release
```

Проверить, каким ключом подписан APK:

```bash
"$(dirname $(which apksigner) 2>/dev/null || echo $ANDROID_HOME/build-tools/34.0.0)/apksigner" verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

Отпечаток SHA-256 в выводе должен совпадать с тем, что показывает `keytool -list -v` для вашего keystore. Если видите `CN=Android Debug` — подпись не подхватилась, проверьте путь в `storeFile`.

---

## 6. Если ключ уже существует

Ничего создавать не нужно — скопируйте `.jks` в `~/keys/`, и выполните шаги 2–5. Алиас можно узнать так:

```bash
keytool -list -keystore ~/keys/wayback-upload.jks
```

---

## 7. CI (GitHub Actions и т.п.)

Keystore в репозиторий не кладём — передаём через секреты в base64:

```bash
base64 -i ~/keys/wayback-upload.jks | pbcopy
```

В workflow перед сборкой:

```yaml
      - name: Restore keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload.jks
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=upload.jks
          EOF
```

---

## Важное про потерю ключа

- Без Play App Signing потеря `.jks` или пароля означает невозможность обновить приложение — только новая публикация с новым `applicationId`.
- С включённым **Play App Signing** (по умолчанию для новых приложений) ваш `.jks` — это *upload key*, и его можно сбросить через поддержку Google Play. Ключ подписи релиза хранит Google.
- Держите бэкап `.jks` и паролей в надёжном месте (менеджер паролей / зашифрованное хранилище), не в репозитории.
