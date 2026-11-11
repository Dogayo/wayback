<p align="right"><a href="android-signing.md">English</a> · <b>Русский</b></p>

# Подпись Android-сборки (JKS keystore)

Инструкция для проекта `wayback` (Flutter, Gradle Kotlin DSL, `applicationId = com.dogayo.wayback`).

Сборка уже готова к подписи (#17): `android/app/build.gradle.kts` берёт upload-ключ из `android/key.properties`, а без этого файла подписывает release debug-ключом. CI восстанавливает ключ из секретов GitHub (§7) и не выпускает релиз, подписанный debug-ключом. Остаётся создать ключ (§1), файл `key.properties` (§2) и секреты (§7) — это делается один раз, пароли знаете только вы.

---

## 1. Создать keystore

`keytool` входит в JDK, который ставится вместе с Android Studio. Проверить:

```bash
keytool -help
```

На Fedora `keytool` уже есть в `/usr/bin` (пакет OpenJDK). Если команда не найдена — используйте JDK из Android Studio:

```bash
export PATH="$HOME/android-studio/jbr/bin:$PATH"
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
storeFile=/home/Dogayo/keys/wayback-upload.jks
```

`storeFile` — абсолютный путь либо путь относительно каталога `android/app/`. Обратный слэш в паролях не используйте: в формате `.properties` это экранирование.

---

## 3. `.gitignore`

Уже настроено — в корневом и `android/.gitignore`:

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

## 4. Подпись в `android/app/build.gradle.kts` (уже подключена)

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
"$(ls ~/Android/Sdk/build-tools/*/apksigner | sort -V | tail -1)" verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

Отпечаток SHA-256 в выводе должен совпадать с тем, что показывает `keytool -list -v` для вашего keystore. Если видите `CN=Android Debug` — подпись не подхватилась, проверьте путь в `storeFile`.

---

## 6. Если ключ уже существует

Ничего создавать не нужно — скопируйте `.jks` в `~/keys/`, и выполните шаги 2–5. Алиас можно узнать так:

```bash
keytool -list -keystore ~/keys/wayback-upload.jks
```

---

## 7. CI (GitHub Actions)

Keystore в репозиторий не кладём — `ci.yml` (job `build-android`) собирает его из четырёх секретов репозитория. Задать их из терминала через `gh`, ничего не копируя руками:

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

Последние две команды спросят значение интерактивно — так пароль не попадёт в историю shell. Проверить, что секреты на месте (значения не показываются):

```bash
gh secret list
```

Что делает CI:

- **Restore upload keystore** — раскодирует keystore во временный каталог раннера и пишет `android/key.properties`.
- **Verify signature** — печатает сертификат подписи APK (`apksigner verify --print-certs`).
- Релиз по тегу без секретов или с подписью `CN=Android Debug` **падает** — debug-подписанный APK не обновит установку, подписанную настоящим ключом. Ручной запуск (`Run workflow`) без секретов собирается с debug-ключом и предупреждением.

---

## Важное про потерю ключа

- Без Play App Signing потеря `.jks` или пароля означает невозможность обновить приложение — только новая публикация с новым `applicationId`.
- С включённым **Play App Signing** (по умолчанию для новых приложений) ваш `.jks` — это *upload key*, и его можно сбросить через поддержку Google Play. Ключ подписи релиза хранит Google.
- Держите бэкап `.jks` и паролей в надёжном месте (менеджер паролей / зашифрованное хранилище), не в репозитории.
