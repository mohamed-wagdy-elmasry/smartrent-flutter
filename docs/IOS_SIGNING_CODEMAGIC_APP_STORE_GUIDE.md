# Signing and Publishing the iOS App with Codemagic

This guide covers the Flutter app in this repository, how iOS signing works, and how to publish it to App Store Connect using `codemagic.yaml`.

## The key limitation

You do not currently have an Apple Developer Program account. You can prepare the project and run iOS builds in Codemagic, but you cannot publish this app to the App Store yet. App Store distribution requires an active Apple Developer Program membership, an App Store Connect app record, an Apple distribution signing identity/profile (or a supported managed-signing setup), and App Store Connect authentication. Codemagic does not issue or replace Apple's credentials.

Apple lists membership at **USD $99 per year**, with local pricing and possible eligible fee waivers. An existing enrolled team can instead invite you and grant the necessary role; publishing would then use that team's app, signing assets, and seller identity. [Apple Developer Program enrollment](https://developer.apple.com/programs/enroll/) · [Membership comparison](https://developer.apple.com/support/compare-memberships/)

A free Apple Account can be used with Xcode for personal development and limited on-device testing. This is not App Store distribution and does not provide App Store Connect publishing or TestFlight distribution. A simulator build does not require App Store signing.

## Project-specific details

- Framework: Flutter (`pubspec.yaml` specifies Flutter 3.32.8).
- iOS workspace: `ios/Runner.xcworkspace`.
- Current app bundle ID: `com.next.smartrent` (from `ios/Runner.xcodeproj/project.pbxproj`).
- Display name: Smart Rent.
- Version/build: `1.2.0+9` in `pubspec.yaml`. The build number must increase for each uploaded build.
- Minimum iOS deployment target: iOS 12.0 (from the Xcode project).

Before enrollment, verify that `com.next.smartrent` is the bundle ID you intend to keep. Bundle IDs should be unique and must match the explicit App ID and provisioning profile in the Apple team that owns the app. Do not change it casually after the app record is created.

## Terms in plain language

- **Signing identity/certificate:** identifies the Apple team that signed the app. For App Store delivery this is an Apple Distribution certificate, including its private key.
- **Provisioning profile:** connects the App ID, team, distribution certificate, and allowed distribution method. The App Store profile is used for App Store Connect distribution.
- **App Store Connect API key:** lets Codemagic authenticate to upload builds and submit/manage app records. It is separate from the signing certificate.
- **Codemagic code signing identity:** the certificate and private key (commonly uploaded as a `.p12`) stored securely in Codemagic. A matching `.mobileprovision` profile is also required for manual signing.
- **`codemagic.yaml`:** build instructions stored at the repository root. It contains references to credential names, never private key material.

A certificate without its private key is not enough to sign. Never commit the `.p12`, its password, the App Store Connect `.p8`, or API key credentials to Git.

## What to do now, before you have membership

1. Keep developing the Flutter app and run Android builds as usual.
2. Use an iOS simulator build for basic iOS UI checks. A simulator build is not an installable App Store package.
3. If you have a Mac, sign into Xcode with your Apple Account and select the Personal Team for limited personal device testing. The provisioning expires and must be renewed periodically.
4. Prepare the Codemagic workflow below, but expect the signed distribution workflow to stop until the Apple credentials and API key are configured.
5. Decide whether you will enroll as an individual or publish under an organization/team. The seller name is based on the enrolled account type.
6. If a company or another developer owns the app, ask the Account Holder/Admin to invite your Apple Account to their team with the access needed for Certificates, Identifiers & Profiles and App Store Connect. Do not share their Apple Account password.

If enrolling as an organization, Apple may require a D‑U‑N‑S Number and verification of the legal entity. Apple lists the current requirements on its [enrollment page](https://developer.apple.com/programs/enroll/).

## After you have team access: prepare Apple assets

The Account Holder or an Admin should:

1. Complete Apple Developer Program enrollment and accept the agreements.
2. In App Store Connect, create the app record. Select iOS and set its bundle ID to `com.next.smartrent` (or the final approved ID).
3. In Users and Access → Integrations → App Store Connect API, create an API key with **App Manager** access (or a more privileged role if your team process requires it). Download the `.p8` once and record its Key ID and Issuer ID securely.
4. Create an Apple Distribution certificate. Export the certificate **with its private key** from Keychain Access as a password-protected `.p12`. Alternatively, use Codemagic's supported automatic certificate/profile fetching after linking the Apple Developer Portal integration and API key.
5. For manual signing, create an App Store Connect provisioning profile for the explicit App ID and distribution certificate. Download its `.mobileprovision` file.
6. In Codemagic, connect the Apple Developer Portal integration/API key. Upload or fetch the signing certificate and provisioning profile in **Team settings → codemagic.yaml settings → Code signing identities**. Give the API key integration a name and use that exact name in YAML.

Apple's profile instructions state that an App Store Connect profile uses an explicit App ID and a distribution certificate. See [Create an App Store Connect provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/). Codemagic documents the API key and signing requirements in [App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/) and [First signed build](https://docs.codemagic.io/yaml-quick-start/first-signed-build/).

## Example root `codemagic.yaml`

This is a starting template, not a ready-to-run configuration. Replace `YOUR_APP_STORE_CONNECT_API_KEY` with the integration name configured in Codemagic. The API key and signing assets must be added to Codemagic securely first. Keep the file at the repository root.

```yaml
workflows:
  ios-app-store:
    name: iOS App Store
    max_build_duration: 120
    instance_type: mac_mini_m2

    integrations:
      app_store_connect: YOUR_APP_STORE_CONNECT_API_KEY

    environment:
      flutter: 3.32.8
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.next.smartrent

    scripts:
      - name: Get Flutter packages
        script: flutter pub get
      - name: Install CocoaPods
        script: |
          cd ios
          pod install
      - name: Apply signing profiles to the Xcode project
        script: xcode-project use-profiles
      - name: Build signed IPA
        script: flutter build ipa --release

    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log

    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true
        beta_groups:
          - Internal Testers
        submit_to_app_store: false
```

This example uploads the build to TestFlight for internal testing after signing. Once the app record, metadata, compliance answers, and review details are ready, set `submit_to_app_store: true` if you want Codemagic to submit the build for App Review. Submission does not guarantee approval: Apple reviews the app before release. You can also upload to App Store Connect and complete submission manually.

The group name under `beta_groups` must exist in App Store Connect; remove that field if not using a group. Check Codemagic's current YAML reference before relying on a template because supported fields can change: [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/) and [iOS signing](https://docs.codemagic.io/yaml-code-signing/yaml-code-signing/).

### Manual assets vs. automatic fetching

The YAML above declares App Store signing and bundle ID. Depending on how signing assets are managed in Codemagic, you either upload the matching certificate/profile and let `xcode-project use-profiles` select them, or configure the Apple Developer Portal integration so Codemagic can fetch/create the assets for the team. Automatic fetching still requires valid Apple team access, membership, and permissions. The YAML itself cannot manufacture an Apple identity.

Do not add guessed signing file names, passwords, private keys, or API key contents to this file. Configure secrets and files in Codemagic's secure settings.

## Build and release checklist

- [ ] Confirm final bundle ID and app display name.
- [ ] Confirm Apple Developer Program membership or an invitation to the publishing team.
- [ ] Create the App Store Connect app record with the same bundle ID.
- [ ] Create/configure the App Store Connect API key and Codemagic integration.
- [ ] Upload or fetch the Apple Distribution certificate/private key and matching profile.
- [ ] Add `codemagic.yaml` at repository root and scan the branch in Codemagic.
- [ ] Run the workflow and confirm it produces a signed `.ipa`.
- [ ] Install the first build through TestFlight and verify app behavior on real devices.
- [ ] Complete App Store listing, screenshots, privacy details, age rating, export compliance, and review contact information in App Store Connect.
- [ ] Increment the Flutter build number (the number after `+` in `1.2.0+9`) for every new upload.
- [ ] Submit the selected build for App Review and release it after approval.

## Sources

- [Apple Developer Program enrollment and fee](https://developer.apple.com/programs/enroll/)
- [Compare Apple Developer membership options](https://developer.apple.com/support/compare-memberships/)
- [Apple: create an App Store Connect provisioning profile](https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/)
- [Codemagic: App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/)
- [Codemagic: first signed build](https://docs.codemagic.io/yaml-quick-start/first-signed-build/)
- [Codemagic: iOS code signing](https://docs.codemagic.io/yaml-code-signing/yaml-code-signing/)



## Step-by-step instructions and commands

Commands below assume you open PowerShell in the project root:

```powershell
Set-Location 'L:\DATA\smart-rent\source-code\carbo-app\carbo-user'
```

### A. Check the project now (no Apple membership required)

On this Windows machine you can check Flutter setup and fetch packages:

```powershell
flutter --version
flutter doctor -v
flutter pub get
```

The project asks for Flutter 3.32.8 and Dart >=3.8.1 in `pubspec.yaml`. If `flutter doctor` reports that Xcode is unavailable, that is expected on Windows. Apple iOS builds require macOS with Xcode; Codemagic provides a macOS build machine so you can build in the cloud.

For a simulator build, run this on a Mac with Xcode installed:

```bash
flutter build ios --simulator --release
```

This creates a simulator app, not an App Store IPA. On Windows, skip this command.

### B. Prepare and commit the Codemagic workflow

Create a file named exactly `codemagic.yaml` in the repository root (the same folder as `pubspec.yaml`). Paste the example workflow above into it and replace `YOUR_APP_STORE_CONNECT_API_KEY` with the key integration name you will create in Codemagic later.

The example assumes an App Store Connect beta tester group named `Internal Testers`. Either create that group in App Store Connect or remove the `beta_groups` lines.

Check that the file is in the right place:

```powershell
Test-Path .\codemagic.yaml
Get-Content .\codemagic.yaml
```

Commit and push it to the Git provider connected to Codemagic:

```powershell
git status
git add codemagic.yaml
git commit -m "Add iOS Codemagic workflow"
git push
```

If Git asks for an identity, configure your name and email first:

```powershell
git config user.name "Your Name"
git config user.email "you@example.com"
```

Codemagic reads the YAML from the selected branch. In Codemagic, add/import the app from that Git provider, select the branch containing the file, and run **Check for configuration file**. Select the `ios-app-store` workflow and start a build. Until Apple signing assets and API key are set up, the signed IPA/publishing steps will fail; this does not mean the Flutter project cannot be prepared.

### C. When you enroll or get invited to a team

1. Sign into Apple Developer and App Store Connect with the Apple Account that belongs to the enrolled team.
2. Create the App Store Connect app record with bundle ID `com.next.smartrent`. If the team does not own or cannot register that ID, choose an available bundle ID and update the Runner target in Xcode before making the app record.
3. Create an App Store Connect API key with App Manager access. Download the `.p8` file once and keep it private.
4. In Codemagic team settings, open **Integrations → Developer Portal** and add the API key. Record the Codemagic integration name (the exact string used under `integrations.app_store_connect` in YAML).
5. In Codemagic team settings, open **codemagic.yaml settings → Code signing identities**. Add/fetch an Apple Distribution certificate and an App Store Connect provisioning profile for `com.next.smartrent`. Automatic fetching requires a working Developer Portal integration and suitable team permissions.
6. Push any YAML changes to the connected Git branch. Do not put the `.p8`, `.p12`, password, or provisioning profile contents into Git.

### D. Run a signed build from Codemagic

After credentials are configured, return to the app in Codemagic, select the branch, and start `ios-app-store`. The workflow runs these equivalent commands on its macOS worker:

```bash
flutter pub get
cd ios && pod install
cd ..
xcode-project use-profiles
flutter build ipa --release
```

If the build succeeds, download the IPA from the Codemagic build page under **Artifacts**. If it fails, inspect the first signing-related error: common causes are a mismatched bundle ID, missing/expired profile, certificate without its private key, insufficient Apple team permission, or an API key that is not connected to the same team.

### E. Upload to TestFlight, then submit for App Review

With the example workflow's `publishing.app_store_connect` settings, Codemagic uploads the IPA and attempts to distribute it to TestFlight. Check the build log and App Store Connect; Apple may need time to process the build. In App Store Connect, complete the app listing, privacy details, age rating, export compliance, screenshots, and review contact information. Test the TestFlight build before release.

When you are ready for App Review, change this in `codemagic.yaml`:

```yaml
submit_to_app_store: true
```

The example deliberately keeps App Store submission disabled initially. Commit and push the change, then run the workflow again. Apple reviews the submission; once approved, follow your selected release setting in App Store Connect. Each upload must use a new build number. For example, update the project version from `1.2.0+9` to `1.2.0+10` in `pubspec.yaml`, commit, push, and rebuild.

### Local IPA build on a Mac (optional)

Once you have signing assets installed/configured on a Mac, you can also build locally. These commands do not work on Windows:

```bash
flutter pub get
cd ios
pod install
cd ..
flutter build ipa --release
```

An App Store IPA requires valid distribution signing from the Apple team. For this project, Codemagic is the straightforward route from Windows because it supplies the required macOS/Xcode build environment.

### Useful troubleshooting commands (Mac or Codemagic worker)

```bash
flutter doctor -v
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release -v
```

Use `flutter clean` only to clear generated build output; it does not fix incorrect Apple certificates, profiles, bundle IDs, or account permissions.



## Apple sign-in and connecting the Apple team to Codemagic

You need two related Apple services: the **Apple Developer account** for certificates and provisioning, and **App Store Connect** for the app record, API key, TestFlight, and App Store submission. Sign in to both with the Apple Account that owns or has been invited to the publishing team.

### 1. Create or sign in to an Apple Account

If you do not have an Apple Account, create one at [account.apple.com](https://account.apple.com/). Use an email address you control and enable two-factor authentication. Keep access to the trusted phone number/device because Apple may request verification.

Then:

1. Open [developer.apple.com/account](https://developer.apple.com/account/).
2. Sign in with that Apple Account.
3. Accept the Apple Developer Agreement if shown.
4. If you are only preparing the project, a free Apple developer registration is enough to explore the portal and use Xcode Personal Team for limited development. It does **not** enable App Store Connect distribution.
5. To publish, choose **Join the Apple Developer Program** and enroll as an individual or organization. Complete identity/business verification and pay the displayed regional membership fee. Wait until membership is active.

**If you are joining someone else's developer team:** ask its Account Holder/Admin to invite the email address associated with your Apple Account. Accept the invitation from Apple's email or from App Store Connect. Ask the team admin to grant the least access needed: developer portal access for certificates/identifiers/profiles and an App Store Connect role that can manage the app/builds (Codemagic recommends App Manager for publishing). The account that owns the app should remain the publisher; do not create a separate app record under the wrong team.

### 2. Sign in to App Store Connect and create the app record

1. Open [appstoreconnect.apple.com](https://appstoreconnect.apple.com/) and sign in using the enrolled or invited Apple Account.
2. Confirm the correct team is selected (if the account belongs to multiple teams).
3. Go to **Apps → + → New App**.
4. Select **iOS**, enter the app name and primary language, select the correct team, and choose the bundle ID `com.next.smartrent`.
5. Enter an SKU (an internal identifier such as `smart-rent-ios`; it is not shown to customers) and create the record.

If `com.next.smartrent` is unavailable or belongs to another team, stop and resolve ownership before proceeding. Choose a bundle ID controlled by your team, update the iOS Runner target in Xcode, and create the app record with exactly that same ID. In this repository the current value is in `ios/Runner.xcodeproj/project.pbxproj` under `PRODUCT_BUNDLE_IDENTIFIER`.

### 3. Create an App Store Connect API key

1. In App Store Connect, open **Users and Access → Integrations → App Store Connect API**.
2. Select the correct team/provider if prompted.
3. Under **Team Keys**, click **+** to create a key.
4. Name it, for example `Codemagic CI`, and choose **App Manager** access.
5. Generate the key. Download the `.p8` private key immediately; Apple only makes it downloadable once.
6. Copy the **Key ID** and **Issuer ID** shown on the page. Store the `.p8` file and IDs securely. Do not commit them to the repository or send them in chat.

The key authenticates Codemagic to App Store Connect. It does not itself sign the app. Signing requires the distribution certificate/profile as described next.

### 4. Connect the Apple account to Codemagic

1. Sign in to [Codemagic](https://codemagic.io/) and open the Codemagic team that contains this app.
2. Open **Team settings → Integrations → Developer Portal** (the labels may vary slightly with Codemagic UI updates).
3. Choose **Connect** or **Manage keys → Add key**.
4. Enter a recognizable integration name such as `carbo-appstore`.
5. Enter the Apple **Issuer ID** and **Key ID**, then upload the downloaded `.p8` file as the API key/private key.
6. Save the integration. If prompted for an Apple team/provider, select the same team that owns the App Store Connect app record and bundle ID.

In the root `codemagic.yaml`, use that exact integration name:

```yaml
integrations:
  app_store_connect: carbo-appstore
```

If the YAML already has this block, replace its placeholder with the name you saved in Codemagic. The name is a reference to a secret in Codemagic, not a password or API key value.

### 5. Configure code signing in Codemagic

1. In Codemagic team settings, open **codemagic.yaml settings → Code signing identities**.
2. Open the iOS certificates section. Use **Fetch certificates** / automatic signing if available, select the connected Apple Developer Portal integration and the `com.next.smartrent` App ID, and let Codemagic create or fetch an Apple Distribution certificate and App Store provisioning profile.
3. If using manual signing instead, upload:
   - An Apple Distribution `.p12` exported with its private key and protected by a password.
   - An App Store Connect `.mobileprovision` profile for the matching explicit App ID and distribution certificate.
4. Give the uploaded signing assets a label if requested. The `ios_signing` block in the workflow should specify the same bundle identifier and `distribution_type: app_store`.
5. Return to **Applications**, open this repository, select the branch containing `codemagic.yaml`, scan/check the YAML configuration, and start the `ios-app-store` workflow.

A successful run should produce `build/ios/ipa/*.ipa` and upload it to App Store Connect using the API key. Check **App Store Connect → TestFlight** after Apple's processing finishes.

### What each connection does

| Item | Where it comes from | What Codemagic uses it for |
|---|---|---|
| Apple Account and team membership | Apple Developer / team invitation | Permission to manage the app and signing resources |
| App Store Connect API key (`.p8`, Key ID, Issuer ID) | App Store Connect | Uploading builds and managing publishing actions |
| Apple Distribution certificate with private key | Apple Developer team | Signing the release app |
| App Store provisioning profile | Apple Developer team | Authorizing the signed app for App Store Connect distribution |
| Codemagic integration name | Codemagic settings | Lets YAML select the securely stored Apple API key |

If a Codemagic menu or Apple page has moved, use the current official walkthroughs: [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/), [Codemagic iOS signing](https://docs.codemagic.io/yaml-code-signing/yaml-code-signing/), and [Apple Developer Program enrollment](https://developer.apple.com/programs/enroll/).

