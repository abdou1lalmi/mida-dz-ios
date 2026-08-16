# MIDA DZ GitHub Actions code signing

This guide configures the protected release job in `.github/workflows/ios.yml`. The ordinary push and pull-request job remains unsigned and continues to build the simulator app. The release job is manual, uses the `ios-release` GitHub Environment, and reads private signing material only from GitHub Secrets.

> Never commit `.p12`, `.mobileprovision`, `.p8`, certificate files, provisioning profiles, passwords, or private keys to the repository. Do not send their contents through chat.

## Distribution path

The recommended path is **App Store Connect plus TestFlight**. It produces a signed iPhone build without requiring the old MacBook Air to run Xcode. The alternative **Ad Hoc** path creates an IPA for registered device UDIDs; it is useful for private device testing but requires maintaining the device list in the Apple Developer portal.

| Path | Profile | Output | Physical iPhone requirement |
| --- | --- | --- | --- |
| TestFlight | App Store | Signed IPA uploaded to App Store Connect | Install TestFlight and accept the tester invitation |
| Ad Hoc | Ad Hoc | Signed IPA artifact | The iPhone UDID must be registered in the profile |

The project bundle identifier is `com.abdou1lalmi.midadz`. The App ID in Apple Developer must use that exact identifier.

## Apple Developer setup

Use a paid Apple Developer Program membership with access to **Certificates, Identifiers & Profiles** and **App Store Connect**. Create or confirm an explicit App ID for `com.abdou1lalmi.midadz`.

Create an **Apple Distribution** certificate. On a Mac, create a certificate signing request in Keychain Access, upload it in the Apple Developer portal, download the certificate, and import it into Keychain Access. Export the certificate together with its private key as a password-protected PKCS#12 file, for example `MidaDZ_Distribution.p12`. Keep the export password; it becomes `P12_PASSWORD`.

Create an **App Store provisioning profile** for TestFlight. Select the MIDA DZ App ID and the Apple Distribution certificate. Download the resulting `.mobileprovision` file and record its exact profile name. For the Ad Hoc path, create an Ad Hoc profile instead and register each device UDID first.

For TestFlight upload, create an **App Store Connect API key** under **Users and Access → Integrations → Keys**. Record the Issuer ID and Key ID, and download the `.p8` private key immediately. Apple does not provide the private key for download again after it is created.

## GitHub Environment

In the private repository, open **Settings → Environments → New environment** and create:

```text
ios-release
```

Enable required reviewers for this environment if more than one person has repository access. This keeps a signing release behind an explicit approval step. The release job is already configured with `environment: ios-release`.

## GitHub Secrets

Open **Settings → Environments → ios-release → Environment secrets** and create the following secrets:

| Secret | Value |
| --- | --- |
| `APPLE_TEAM_ID` | Your Apple Developer Team ID |
| `BUILD_CERTIFICATE_BASE64` | Base64-encoded `MidaDZ_Distribution.p12` |
| `P12_PASSWORD` | The password used when exporting the `.p12` |
| `KEYCHAIN_PASSWORD` | A new random password used only for the temporary CI keychain |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64-encoded App Store or Ad Hoc `.mobileprovision` |
| `PROVISION_PROFILE_NAME` | The exact profile name shown by Apple |
| `APPSTORE_KEY_ID` | App Store Connect API Key ID |
| `APPSTORE_ISSUER_ID` | App Store Connect Issuer ID |
| `APPSTORE_PRIVATE_KEY_BASE64` | Base64-encoded App Store Connect `.p8` private key |

The App Store Connect secrets are used only when `upload_testflight` is enabled. The signing secrets are required whenever `release` is enabled.

## Base64 encoding on macOS

Run these commands locally on a trusted Mac. The commands copy one-line Base64 values to the clipboard; paste each value into the corresponding GitHub Environment secret field.

```bash
base64 -i MidaDZ_Distribution.p12 | pbcopy
base64 -i MidaDZ_AppStore.mobileprovision | pbcopy
base64 -i AuthKey_ABC123XYZ.p8 | pbcopy
```

If `base64 -i` is not accepted by the shell, use:

```bash
base64 < MidaDZ_Distribution.p12 | tr -d '\n' | pbcopy
base64 < MidaDZ_AppStore.mobileprovision | tr -d '\n' | pbcopy
base64 < AuthKey_ABC123XYZ.p8 | tr -d '\n' | pbcopy
```

Use a different randomly generated value for `KEYCHAIN_PASSWORD`; it does not need to match your Mac login password or the `.p12` password.

## Run a signed release

Open the repository’s **Actions** tab and select **MIDA DZ iOS**. Choose **Run workflow**, select the `main` branch, set `release` to `true`, and set `upload_testflight` to `true` for the TestFlight path. Submit the workflow. If the `ios-release` Environment has required reviewers, approve the release when GitHub requests approval.

The release job performs these operations on a temporary macOS runner:

1. Generates the Xcode project with XcodeGen.
2. Creates a temporary keychain and imports the Apple Distribution certificate.
3. Installs the provisioning profile into the runner’s profile directory.
4. Archives MIDA DZ for the generic iOS device destination.
5. Exports a signed IPA using the App Store provisioning method.
6. Uploads the IPA as `mida-dz-ios-signed-<run-number>`.
7. Uploads the IPA to TestFlight when `upload_testflight` is true.
8. Deletes the temporary signing keychain in an always-run cleanup step.

The first run should be made with `upload_testflight` set to `false` if you want to verify certificate and profile configuration before sending a build to App Store Connect.

## Install through TestFlight

After the workflow uploads the IPA, Apple must process the build. Add yourself as an internal tester in App Store Connect, install the TestFlight app on the iPhone, accept the invitation, and install MIDA DZ from TestFlight. The IPA artifact is not the preferred manual installation mechanism for TestFlight builds.

## Ad Hoc alternative

To use the downloaded IPA directly for private testing, replace the App Store provisioning profile with an Ad Hoc profile that includes the iPhone’s UDID. The workflow’s `ExportOptions.plist` currently uses `app-store`; for Ad Hoc distribution, change the export method to `ad-hoc` and use the Ad Hoc profile name. The device must be registered in Apple Developer before the profile is generated.

## Troubleshooting

| Failure | Likely cause | Fix |
| --- | --- | --- |
| `No signing certificate` | The `.p12` is invalid, has the wrong password, or does not contain its private key | Re-export the certificate and private key together from Keychain Access |
| `No profiles for ... were found` | The profile App ID does not match `com.abdou1lalmi.midadz` | Recreate the profile for the exact bundle identifier |
| `Provisioning profile doesn't include signing certificate` | The profile was generated before the current certificate | Regenerate the profile after selecting the current Apple Distribution certificate |
| `App Store Connect authentication failed` | Issuer ID, Key ID, or `.p8` content is incorrect | Recreate the three App Store Connect secrets and verify the key role |
| Build succeeds but TestFlight does not show it | Apple is still processing the upload or the build number is already used | Wait for processing and increment the build number for a new upload |
| Environment approval is unavailable | The job is waiting for an `ios-release` reviewer | Open the workflow run and approve the environment deployment |

## Security checklist

Use a protected Environment rather than ordinary repository secrets for release credentials. Limit the App Store Connect API key role to what the workflow needs. Do not run the signed release from untrusted pull-request code, do not echo secret values in shell output, and rotate the certificate, profile, and API key if any private material is exposed.

## References

[1]: <https://developer.apple.com/help/account/certificates/certificates-overview/> "Apple certificates overview"
[2]: <https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/> "Apple Ad Hoc provisioning profiles"
[3]: <https://developer.apple.com/help/account/provisioning-profiles/create-an-app-store-provisioning-profile/> "Apple App Store provisioning profiles"
[4]: <https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api> "Apple App Store Connect API keys"
[5]: <https://docs.github.com/actions/security-guides/using-secrets-in-github-actions> "GitHub Actions secrets"
[6]: <https://docs.github.com/en/actions/concepts/security/secrets> "GitHub Actions secrets concepts"
