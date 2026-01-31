# UMe Mobile App & API

AI-powered dating app with conversational profile building and LLM-based matchmaking.

## Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│  Flutter App    │─────▶│  FastAPI Backend │─────▶│  OpenAI GPT     │
│  (User Chat)    │      │  (Matchmaking)   │      │  (AI Analysis)  │
└─────────────────┘      └──────────────────┘      └─────────────────┘
         │                        │
         └────────────────────────┘
                    │
              ┌─────▼──────┐
              │  Firebase  │
              │  Firestore │
              └────────────┘
```

**Key Components:**
- `api/src/algo.py` - Matchmaking algorithm with canonical match IDs
- `api/src/prompts.py` - System prompts for persona discovery and ranking
- `api/src/ai.py` - OpenAI integration with structured outputs
- `api/src/themes.py` - 11 dating dimensions for profile completeness
- `mobile-app/lib/chat/` - Conversational UI with state management
- `mobile-app/lib/matches/` - Match display and interest tracking

## Prerequisites

- Flutter SDK 3.x+ - [Install](https://docs.flutter.dev/get-started/install)
- Python 3.11+
- Docker (optional, for containerized deployment)
- Firebase project
- OpenAI API key - [Get one](https://platform.openai.com/api-keys)

## Setup

### 1. Firebase Configuration

Create a Firebase project at https://console.firebase.google.com and enable:
- **Authentication** → Phone
- **Firestore Database** → Start in test mode
- **Cloud Storage** → Default bucket

Download Firebase Admin SDK key:
- Firebase Console → Project Settings → Service Accounts → Generate New Private Key
- Save as `api/firebase-admin-key.json`
- Add to `.gitignore`

Configure Flutter app:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart
cd mobile-app/
flutterfire configure
```

For Android, download `google-services.json`:
- Firebase Console → Project Settings → Your Apps → Android
- Place at `mobile-app/android/app/google-services.json`

### 2. Environment Variables

**API** (create `api/.env`):
```bash
OPENAI_API_KEY=sk-...
MODEL_NAME=gpt-4o-mini
API_KEY=$(openssl rand -hex 32)
```

**App** (create `mobile-app/.env`):
```bash
API_URL=http://localhost:8080
API_KEY=<same-as-api-key-above>
```

### 3. Run Locally

**Terminal 1 - API:**
```bash
cd api/
pip install -r requirements.txt
export GOOGLE_APPLICATION_CREDENTIALS="firebase-admin-key.json"
uvicorn app:app --reload --port 8080
```

**Terminal 2 - Flutter App:**
```bash
cd mobile-app/
flutter pub get
flutter run --dart-define-from-file=.env
```

### 4. Load Test Data

```bash
# Generate 10 fake profiles with personas
curl -X GET "http://localhost:8080/fake/people?n=10" \
  -H "api-key: YOUR_API_KEY"

# Trigger matchmaking
curl -X POST "http://localhost:8080/matches/create" \
  -H "api-key: YOUR_API_KEY" -d ""

# View API docs
open http://localhost:8080/docs
```

## Deployment

### API to Google Cloud Run

```bash
cd api/

# Authenticate
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Enable services
gcloud services enable \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  cloudscheduler.googleapis.com

# Update gcp_deploy.sh with your project ID, then deploy
./gcp_deploy.sh
```

Set up daily matchmaking cron in Cloud Scheduler:
- Frequency: `0 2 * * *` (2 AM daily)
- Target: Cloud Run job (job.py)
- Auth: Service account with Cloud Run Invoker role

### Flutter App

```bash
cd mobile-app/

# Update API_URL in .env to production URL

# Build APK
flutter build apk --release --dart-define-from-file=.env

# Or build App Bundle for Play Store
flutter build appbundle --release --dart-define-from-file=.env
```

APK location: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

**"Firebase not initialized"**
- Run `flutterfire configure` in `mobile-app/` directory
- Ensure `google-services.json` is in `mobile-app/android/app/`

**"OpenAI API error"**
- Check `OPENAI_API_KEY` in `api/.env`
- Verify API key has credits at https://platform.openai.com/usage

**"No matches found"**
- Ensure users have completed at least one conversation
- Check that test profiles have personas generated

**Docker build fails**
- Ensure `firebase-admin-key.json` exists in `api/`

## Security Notes

- Never commit `.env`, `firebase-admin-key.json`, or `google-services.json`
- Configure Firestore Security Rules for production
- Use Cloud Secret Manager for production secrets
- Rotate API keys regularly

## License

MIT License - See LICENSE file for details.
