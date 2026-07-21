# Firebase rules draft

Ovaj file je privremeni dogovor za Firebase strukturu i security rules dok aplikacija jos nije spojena na Firebase.

## Product decision

- App se moze otvoriti i koristiti bez racuna.
- Bez racuna nema spremanja profila, statistike, custom cueova, custom modova ni preferencea.
- Login postoji za sve sto treba biti spremljeno na korisnika.
- Nema local persistence za korisnicke podatke. Privremeno stanje treninga smije zivjeti samo u runtime stateu aplikacije.

## Suggested Firestore structure

```text
users/{uid}
  displayName: string
  createdAt: timestamp
  updatedAt: timestamp

users/{uid}/settings/app
  selectedMode: string
  refreshSeconds: number
  comboMinLength: number
  comboMaxLength: number
  enabledPunches: array<number>
  defenseCueSet: string
  soundEnabled: bool
  voiceEnabled: bool
  updatedAt: timestamp

users/{uid}/customDefenseCues/{cueId}
  label: string
  category: string
  enabled: bool
  createdAt: timestamp
  updatedAt: timestamp

users/{uid}/customModes/{modeId}
  name: string
  refreshSeconds: number
  comboMinLength: number
  comboMaxLength: number
  enabledPunches: array<number>
  defenseCueIds: array<string>
  createdAt: timestamp
  updatedAt: timestamp

users/{uid}/trainingSessions/{sessionId}
  mode: string
  startedAt: timestamp
  endedAt: timestamp
  durationSeconds: number
  generatedComboCount: number
  pauseCount: number

users/{uid}/trainingStats/summary
  totalSessions: number
  totalDurationSeconds: number
  totalGeneratedCombos: number
  currentStreakDays: number
  bestStreakDays: number
  lastTrainingAt: timestamp
  updatedAt: timestamp
```

## Firestore security rules

```rules
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    function ownsUserDoc(uid) {
      return signedIn() && request.auth.uid == uid;
    }

    function validString(value, min, max) {
      return value is string && value.size() >= min && value.size() <= max;
    }

    function validOptionalString(value, max) {
      return value == null || (value is string && value.size() <= max);
    }

    function validTimestamp(value) {
      return value is timestamp;
    }

    function validPunchList(value) {
      return value is list
        && value.size() >= 1
        && value.size() <= 6
        && value.hasOnly([1, 2, 3, 4, 5, 6]);
    }

    match /users/{uid} {
      allow read, create, update, delete: if ownsUserDoc(uid);

      match /settings/{settingsId} {
        allow read, delete: if ownsUserDoc(uid);
        allow create, update: if ownsUserDoc(uid)
          && settingsId == "app"
          && request.resource.data.keys().hasOnly([
            "selectedMode",
            "refreshSeconds",
            "comboMinLength",
            "comboMaxLength",
            "enabledPunches",
            "defenseCueSet",
            "soundEnabled",
            "voiceEnabled",
            "updatedAt"
          ])
          && validString(request.resource.data.selectedMode, 1, 40)
          && request.resource.data.refreshSeconds is number
          && request.resource.data.refreshSeconds >= 3
          && request.resource.data.refreshSeconds <= 300
          && request.resource.data.comboMinLength is number
          && request.resource.data.comboMaxLength is number
          && request.resource.data.comboMinLength >= 1
          && request.resource.data.comboMaxLength <= 12
          && request.resource.data.comboMinLength <= request.resource.data.comboMaxLength
          && validPunchList(request.resource.data.enabledPunches)
          && validString(request.resource.data.defenseCueSet, 1, 40)
          && request.resource.data.soundEnabled is bool
          && request.resource.data.voiceEnabled is bool
          && validTimestamp(request.resource.data.updatedAt);
      }

      match /customDefenseCues/{cueId} {
        allow read, delete: if ownsUserDoc(uid);
        allow create, update: if ownsUserDoc(uid)
          && request.resource.data.keys().hasOnly([
            "label",
            "category",
            "enabled",
            "createdAt",
            "updatedAt"
          ])
          && validString(request.resource.data.label, 1, 60)
          && validOptionalString(request.resource.data.category, 40)
          && request.resource.data.enabled is bool
          && validTimestamp(request.resource.data.createdAt)
          && validTimestamp(request.resource.data.updatedAt);
      }

      match /customModes/{modeId} {
        allow read, delete: if ownsUserDoc(uid);
        allow create, update: if ownsUserDoc(uid)
          && request.resource.data.keys().hasOnly([
            "name",
            "refreshSeconds",
            "comboMinLength",
            "comboMaxLength",
            "enabledPunches",
            "defenseCueIds",
            "createdAt",
            "updatedAt"
          ])
          && validString(request.resource.data.name, 1, 40)
          && request.resource.data.refreshSeconds is number
          && request.resource.data.refreshSeconds >= 3
          && request.resource.data.refreshSeconds <= 300
          && request.resource.data.comboMinLength is number
          && request.resource.data.comboMaxLength is number
          && request.resource.data.comboMinLength >= 1
          && request.resource.data.comboMaxLength <= 12
          && request.resource.data.comboMinLength <= request.resource.data.comboMaxLength
          && validPunchList(request.resource.data.enabledPunches)
          && request.resource.data.defenseCueIds is list
          && request.resource.data.defenseCueIds.size() <= 100
          && validTimestamp(request.resource.data.createdAt)
          && validTimestamp(request.resource.data.updatedAt);
      }

      match /trainingSessions/{sessionId} {
        allow read, delete: if ownsUserDoc(uid);
        allow create, update: if ownsUserDoc(uid)
          && request.resource.data.keys().hasOnly([
            "mode",
            "startedAt",
            "endedAt",
            "durationSeconds",
            "generatedComboCount",
            "pauseCount"
          ])
          && validString(request.resource.data.mode, 1, 40)
          && validTimestamp(request.resource.data.startedAt)
          && validTimestamp(request.resource.data.endedAt)
          && request.resource.data.durationSeconds is number
          && request.resource.data.durationSeconds >= 0
          && request.resource.data.durationSeconds <= 86400
          && request.resource.data.generatedComboCount is number
          && request.resource.data.generatedComboCount >= 0
          && request.resource.data.pauseCount is number
          && request.resource.data.pauseCount >= 0;
      }

      match /trainingStats/{statsId} {
        allow read, delete: if ownsUserDoc(uid);
        allow create, update: if ownsUserDoc(uid)
          && statsId == "summary"
          && request.resource.data.keys().hasOnly([
            "totalSessions",
            "totalDurationSeconds",
            "totalGeneratedCombos",
            "currentStreakDays",
            "bestStreakDays",
            "lastTrainingAt",
            "updatedAt"
          ])
          && request.resource.data.totalSessions is number
          && request.resource.data.totalSessions >= 0
          && request.resource.data.totalDurationSeconds is number
          && request.resource.data.totalDurationSeconds >= 0
          && request.resource.data.totalGeneratedCombos is number
          && request.resource.data.totalGeneratedCombos >= 0
          && request.resource.data.currentStreakDays is number
          && request.resource.data.currentStreakDays >= 0
          && request.resource.data.bestStreakDays is number
          && request.resource.data.bestStreakDays >= 0
          && validTimestamp(request.resource.data.lastTrainingAt)
          && validTimestamp(request.resource.data.updatedAt);
      }
    }
  }
}
```

## Storage rules draft

Ako kasnije dodamo avatar ili media assete, neka svaki user pise samo u svoj folder.

```rules
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```
