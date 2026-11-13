# WinHRMS auth + attendance — device test checklist

Run on a **real phone** (Android 7+ / iOS 15.5+). The iOS simulator can't run
this build: ML Kit ships no arm64-simulator slice and iOS 26 simulators no
longer run x86_64 apps.

Before testing, run the API smoke test with the same account:

```bash
WINHRMS_EMAIL=... WINHRMS_PASSWORD=... dart run tool/winhrms_smoke.dart --lat <office lat> --lng <office lng>
```

Accounts needed on tenant `default`:

| Account | location_mandatory | face_mandatory |
|---|---|---|
| A | false | false |
| B | true | false |
| C | true | true (face enrolled) |

## 1. Login and session
- [ ] Email field shows the email keyboard; a mobile number is rejected as "Invalid email address".
- [ ] Wrong password → snackbar "Invalid tenant or credentials".
- [ ] Inactive user → error, stays on login.
- [ ] Correct login → dashboard. Kill and reopen the app → goes straight to the dashboard (token checked with `/auth/me`).
- [ ] Airplane mode, reopen → still opens the dashboard with cached data.
- [ ] Invalidate the token on the server (or wait for expiry) → next Home refresh returns to login.

## 2. Home — account A (no location, no face)
- [ ] Before punching: timer 00:00:00, **Punch In** button. No location prompt on tap.
- [ ] Punch In → success snackbar, timer starts, **Start Break** + **Punch Out** shown.
- [ ] Start Break → "On break" label, timer stops, Punch Out hidden. End Break → timer resumes.
- [ ] Timer value matches the web app (checks `elapsed_seconds` meaning).
- [ ] Punch Out → "You have punched out for today."; no buttons.
- [ ] Pull to refresh / background and resume → same state.
- [ ] Profile → Logout while punched in → "not allowed to sign out, before punch-out". After punch-out → logs out.

## 3. Location — account B
- [ ] At the office: Punch In asks for location permission once, then succeeds.
- [ ] Outside the geofence: server message shown, state unchanged.
- [ ] Location services off / permission denied → matching error message.

## 4. Face punch — account C (face + location required)

**Setup (admin, web app):** pick a test employee, turn on *face mandatory* and
*location mandatory*, and enroll their face. The current test account
(abhishek@) has face verification **off**, so it never opens this screen.
Install a fresh build on a real phone (the iOS simulator can't run ML Kit).

Reset permissions before each run:
- **Android:** Settings → Apps → We Win → Permissions → Camera / Location →
  *Ask every time* (or uninstall/reinstall).
- **iOS:** Settings → We Win → Camera / Location, or uninstall/reinstall
  (iOS only shows each prompt once per install).

### 4a. Camera — allow
- [ ] Punch In → "Checking your location…" → "Starting face verification…" → camera prompt.
- [ ] **Allow** → camera opens in the oval; the permission prompt does **not** cancel the flow.
- [ ] Follow the 3 instructions; dots fill; "Verifying…" → screen closes, Home shows punched in + server message.
- [ ] Punch Out goes through the same screen ("Verify to Punch Out") with **no** location step.

### 4b. Camera — deny
- [ ] Punch In → camera prompt → **Don't allow / Deny** → "Camera access is needed…" with **Open Settings**, **Try again**, **Cancel**.
- [ ] **Try again** → (Android) prompt appears again; (iOS) no prompt, same error.
- [ ] Android: deny twice (or tick *Don't ask again*) → Try again shows the error without a prompt.
- [ ] **Open Settings** → app's settings page opens → enable Camera → return to the app → flow restarts automatically and reaches the camera.
- [ ] **Cancel** → back to Home, nothing punched.
- [ ] Revoke Camera in Settings while the app is open, come back, Punch In → error again (no crash).

### 4c. Location (punch-in only)
- [ ] Location prompt → **Deny** → "Location access is needed…" with **Try again** (no Settings button) → Try again re-prompts.
- [ ] Deny permanently (Android *Don't ask again* / iOS *Don't allow* then later) → "Location access is turned off…" with **Open Settings**.
- [ ] Turn off device Location/GPS → "Location is turned off…" with **Turn on location** → opens location settings → enable → return → retries.
- [ ] Outside the office geofence → server's message (e.g. distance), no camera.

### 4d. Capture behaviour
- [ ] No face / two faces / far away → matching hint, nothing captured.
- [ ] **turn_left / turn_right not swapped.** If turning left is accepted for "turn right", set
      `FacePoseEvaluator.yawSignForUserLeft = -1` (`lib/core/services/face_pose_evaluator.dart`). Check Android **and** iOS.
- [ ] Stay away from the camera for 25 s → "Could not verify your face…", Try again works.
- [ ] Send app to background mid-capture → "Face capture was interrupted", Try again works, camera reopens.
- [ ] Someone else's face → server rejection message, Try again works.
- [ ] Wait out the session expiry before finishing → "session expired", Try again starts a new one.

## 5. Legacy screens (expected to be affected)
The Attendance tab (calendar, day details, corrections), Home punch log,
login, OTP and password reset now use WinHRMS. Still on `api.wewinlimited.com`:
admin dashboard counts, team attendance, resign, the profile details card and
signup. Note what each shows; they are out of scope for this migration.
