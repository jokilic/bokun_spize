# AI meal processing

Flutter uploads the optional photo and calls `createAIMeal` with a stable meal ID, text, Storage path, local meal date, and language code

The callable atomically creates `users/{uid}/meals/{mealId}` and a server-only `users/{uid}/aiMealJobs/{mealId}` record, then enqueues `processAIMeal`

The worker reads the photo, calls Gemini with the configured model fallbacks, validates the output, calculates meal totals from foods, and updates the existing Meal document

The app's existing Firestore listener displays loading, errors, and completed meals

## One-time Firebase setup

Run these commands from the repository root using Node.js 22, the Firebase CLI, and the Google Cloud CLI

1. Ensure the `bokun-spize` Firebase project uses the Blaze billing plan
2. Create a Gemini Developer API key for this project in [Google AI Studio](https://aistudio.google.com/apikey), with access to the configured models
3. Sign in and enable the required services

```sh
firebase login
gcloud auth login
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com eventarc.googleapis.com cloudscheduler.googleapis.com cloudtasks.googleapis.com secretmanager.googleapis.com generativelanguage.googleapis.com --project bokun-spize
```

4. Store the API key as a Firebase secret when prompted, then install the backend dependencies

```sh
firebase functions:secrets:set GEMINI_API_KEY --project bokun-spize
npm --prefix functions ci
```

Do not put the key in Dart, tracked files, or the non-secret `.env` file

5. Deploy Firestore rules and the recovery index, then the functions

```sh
firebase deploy --only firestore:rules,firestore:indexes --project bokun-spize
firebase deploy --only functions:ai-meals --project bokun-spize
```

The function predeploy hook compiles the TypeScript backend automatically

Wait for the `aiMealJobs.nextAttemptAt` collection-group index to finish building before using the new app

The index file introduces only the recovery index; retain any additional indexes already configured in your project when reconciling the deployment

6. Give the functions' runtime service account permission to enqueue tasks, look up the worker URL, and invoke the worker

The following commands use the default shared runtime identity assigned by Firebase, discovered from the deployed callable

```sh
AI_MEAL_RUNTIME_SA="$(gcloud functions describe createAIMeal --gen2 --region europe-west1 --project bokun-spize --format='value(serviceConfig.serviceAccountEmail)')"
AI_MEAL_WORKER_SERVICE="$(gcloud functions describe processAIMeal --gen2 --region europe-west1 --project bokun-spize --format='value(serviceConfig.service)')"

gcloud projects add-iam-policy-binding bokun-spize --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/cloudtasks.enqueuer
gcloud projects add-iam-policy-binding bokun-spize --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/cloudfunctions.viewer
gcloud projects add-iam-policy-binding bokun-spize --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/datastore.user
gcloud storage buckets add-iam-policy-binding gs://bokun-spize.firebasestorage.app --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/storage.objectViewer
gcloud iam service-accounts add-iam-policy-binding "$AI_MEAL_RUNTIME_SA" --project bokun-spize --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/iam.serviceAccountUser
gcloud run services add-iam-policy-binding "${AI_MEAL_WORKER_SERVICE##*/}" --region europe-west1 --project bokun-spize --member="serviceAccount:${AI_MEAL_RUNTIME_SA}" --role=roles/run.invoker
```

If you assign separate service accounts to the callable and recovery functions, apply the enqueue, lookup, self-impersonation, and invocation grants to both enqueueing identities

With separate identities, grant Firestore access (`roles/datastore.user`) to all four functions and Storage object read access (`roles/storage.objectViewer` on the meal bucket) to the callable and worker

Firebase normally configures runtime and secret access during deployment, but projects with restricted default service accounts may need those grants explicitly

The task worker must remain restricted to authenticated service-account invocation

7. Use the updated app only after backend deployment and permissions are complete

`flutter pub get` has already updated the Dart lockfile; run it on other checkouts before running the app

## Configuration

All four functions and the Flutter callable use `europe-west1`

To change the region, update `region` in `src/runtime.ts` and `AIService.region` in `lib/services/ai_service.dart` together before deployment, and adjust the commands above

Android, Apple platforms, and web use the Firebase Functions SDK; Windows uses the authenticated callable HTTP protocol because the Flutter Functions plugin does not provide a Windows implementation

Optional non-secret overrides go in the ignored `functions/.env.bokun-spize` file

```dotenv
AI_MEAL_MODELS=gemini-3.5-flash-lite,gemini-3.1-flash-lite,gemini-3.8-flash,gemini-3.7-flash,gemini-3.6-flash,gemini-3.5-flash
AI_MEAL_DAILY_LIMIT=50
```

Redeploy functions after changing these values or the prompt

The limit is per authenticated user per UTC day and counts accepted requests once, including failed AI jobs; network retries with the same meal ID do not consume additional quota

Authentication and the daily limit are enforced in the callable; App Check enforcement is not enabled because this app does not currently initialize App Check

## Recovery and compatibility

- A durable job exists even if immediate queue submission fails
- `recoverAIMeals` runs every five minutes to retry enqueueing and recover expired six-minute worker leases
- Each job allows up to three processing attempts, with up to six models per attempt and a 25-second timeout per model request
- The SDK's automatic model retries are disabled so the worker controls the retry budget
- Unfinished jobs become failed after exhausting their attempts or reaching a 30-minute age, on the next worker or recovery pass
- Each successful claim gets a unique lease token; stale workers cannot overwrite another attempt's result
- A worker checks the user and meal still exist before committing, so deletion cannot restore a meal
- Active AI meals cannot be edited by clients; completed and failed meals remain compatible with manual edits
- `deleteUserAIData` deletes server-only job and quota documents when the existing account-deletion flow deletes the parent user document
- Existing manual meals and older app-created meals have no job record and retain their current rules
- Existing stuck loading meals from the previous app are not automatically reprocessed
- `createdAt` remains a local ISO string matching the existing daily query; server scheduling timestamps live only in the job document

The app must finish uploading and submitting before work can continue independently of the phone

Uploads interrupted before submission have no server job; an uploaded image can remain unreferenced if the app closes before submitting, as image cleanup is not scheduled by this migration

## Validation

Run unit tests without Firebase credentials or model calls

```sh
npm --prefix functions test
```

Run all tests, including real Firestore transactions and Security Rules, in an isolated demo project

```sh
env -u DEBUG firebase emulators:exec --only firestore --project demo-bokun-spize --config firebase.test.json 'npm --prefix functions test'
```

The emulator tests cover duplicate requests, quota enforcement, duplicate task deliveries, completed results, deleted meals, expired leases, stale workers, retry exhaustion, expired jobs, deleted accounts, ownership, and write protection

No live Gemini requests are made by these tests

After deployment, check one text meal, one photo meal, and one request where you close the app after its loading document appears in the Firestore console; reopening should show the saved result or error

If meals stay loading, inspect `createAIMeal`, `processAIMeal`, and `recoverAIMeals` logs and verify the queue permissions and recovery index

## References

- [Firebase callable functions](https://firebase.google.com/docs/functions/callable)
- [Firebase task queue functions and IAM](https://firebase.google.com/docs/functions/task-functions)
- [Firebase secret parameters](https://firebase.google.com/docs/functions/config-env)
- [Google Gen AI SDK](https://ai.google.dev/gemini-api/docs/libraries)
