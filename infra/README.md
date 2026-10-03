# Infrastructure

Terraform for the `reclamo-listo` GCP project (`590741883744`, `us-central1`). State lives in `gs://reclamo-listo-tfstate` (versioned).

## What Terraform manages

- Project APIs.
- Artifact Registry repository `reclamo-listo` with a cleanup policy (10 recent versions, 30 days).
- Service accounts `run-api` and `run-web`, with minimum roles.
- Cloud Run services `api` (IAM-only, see ADR 0004) and `web` (public).
- Firestore Native database, single region.

Terraform owns the *shape* of the Cloud Run services. `deploy.yml` owns the image and the traffic split; `lifecycle.ignore_changes` keeps the two from fighting.

## Bootstrap done by hand (2026-10-03)

These resources exist before Terraform can run and are **not** managed by it. Re-create them in this order if the project is ever rebuilt.

```bash
gcloud services enable sts.googleapis.com --project reclamo-listo

gcloud storage buckets create gs://reclamo-listo-tfstate --project reclamo-listo \
  --location us-central1 --uniform-bucket-level-access --public-access-prevention
gcloud storage buckets update gs://reclamo-listo-tfstate --versioning

gcloud iam service-accounts create github-deployer --project reclamo-listo \
  --display-name "GitHub Actions deployer"

gcloud iam workload-identity-pools create github --project reclamo-listo \
  --location global --display-name "GitHub Actions"

gcloud iam workload-identity-pools providers create-oidc github-oidc --project reclamo-listo \
  --location global --workload-identity-pool github --display-name "GitHub OIDC" \
  --issuer-uri "https://token.actions.githubusercontent.com" \
  --attribute-mapping "google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
  --attribute-condition "assertion.repository == 'FelipeCoder23/reclamo-listo'"

gcloud iam service-accounts add-iam-policy-binding \
  github-deployer@reclamo-listo.iam.gserviceaccount.com --project reclamo-listo \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/590741883744/locations/global/workloadIdentityPools/github/attribute.repository/FelipeCoder23/reclamo-listo"

for r in roles/run.admin roles/artifactregistry.admin roles/iam.serviceAccountAdmin \
         roles/iam.serviceAccountUser roles/resourcemanager.projectIamAdmin \
         roles/datastore.owner roles/serviceusage.serviceUsageAdmin; do
  gcloud projects add-iam-policy-binding reclamo-listo \
    --member "serviceAccount:github-deployer@reclamo-listo.iam.gserviceaccount.com" \
    --role "$r" --condition None --quiet
done

gcloud storage buckets add-iam-policy-binding gs://reclamo-listo-tfstate \
  --member "serviceAccount:github-deployer@reclamo-listo.iam.gserviceaccount.com" \
  --role roles/storage.objectAdmin
```

Values GitHub Actions needs (repository variables, not secrets):

| Variable | Value |
|---|---|
| `GCP_WIF_PROVIDER` | `projects/590741883744/locations/global/workloadIdentityPools/github/providers/github-oidc` |
| `GCP_DEPLOYER_SA` | `github-deployer@reclamo-listo.iam.gserviceaccount.com` |

## Running locally

Terraform uses Application Default Credentials. Once per machine:

```bash
gcloud auth application-default login
```

Then:

```bash
cd infra
terraform init
terraform plan
terraform apply
```

In CI, `ci.yml` runs `fmt`, `validate` and `plan` on every PR. `apply` is manual.

## Rollback

Cloud Run keeps previous revisions. To send all traffic back to the last good one:

```bash
gcloud run services update-traffic api --region us-central1 --to-revisions REVISION=100
```
