# NZ State Highway Traffic Analytics
Transit New Zealand is dedicated to designing, developing, and upkeeping the state highway system to ensure it enhances a safe, responsive, sustainable land transportation system across New Zealand. Monitoring traffic on the state highway helps the authorities to analyse and plan for action in order to achieve their goals.

# 1. Objective
This end-to-end pipeline provides daily traffic count across New Zealand State Highways which is designed to deliver key metrics such as vehicle counts, the most frequented monitoring sites, percent heavy load vehicles. While the default configuration focuses on pre-selected key monitoring region, the geographical scope and specific sites of interest can be dynamically adjusted according to user needs. The project seeks to offer insights that support effective traffic management and infrastructure development.

# 2. Data Source 
Dataset is provided by NZ Transport Agency through [TMS daily traffic counts API](https://opendata-nzta.opendata.arcgis.com/datasets/NZTA::tms-daily-traffic-counts-api/about), together with [static SH traffic monitoring sites data](https://opendata-nzta.opendata.arcgis.com/datasets/NZTA::state-highway-traffic-monitoring-sites/about). 

# 3. Tech Stack Overview and Workflow
<img width="632" alt="workflow" src="https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics/assets/68572758/bf755074-f1aa-421d-a748-610854779590">

## 3.1 Data Ingestion: 
Used Mage.ai as the workflow orchestrator for batch processing the data. 
1. Retrieving data from API 
2. Keep it in Google Cloud Storage (data lake). 
3. Append the new data into bigquery (used in transformation) and 
4. Run dbt models to production Bigquery table.
## 3.2 Data Storage: 
Google Cloud Storage (GCS) was chosen as the primary data storage solution, ensuring data is securely stored and readily accessible.
## 3.3 Data Transformations: 
dbt (Data Build Tool) was used to transform raw data into structured formats that are optimized (by partitioning and clustering) for analysis. 
Transformation Steps:
1. joined traffic count data with monitoring sites data.
2. selected and adjust only fields used
3. partitioned by date as users need to select range of date interested 
4. clustered by Region as the state highway data often analysed by Region
## 3.4 Data Warehousing: 
Used Google BigQuery to enables efficient data storage for transformed data and enhances querying capabilities. 
## 3.5 Data Visualization: 
Used Looker Studio to visualize key metrics.
## 3.6 Cloud Infrastructure: 
Terraform was used to provision and set up all google cloud infrastructure, ex. cloud run service to run mage pipeline, Bigquery, Google Cloud Storage Bucket
  
# 5. Prerequisites
- Install [gcloud SDK](https://cloud.google.com/sdk/docs/install)
- Gmail account (free for 300 USD credit) 
- Install Terraform

# 5. Project Setup
## 5.1 Clone this git repo to a local folder
`git clone https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics.git`
## 5.2 Preparing Credentials
 1) Create a GCP project and enable [Service Usage API](https://console.cloud.google.com/apis/api/serviceusage.googleapis.com)
 2) Create a service account key with the role owner and Storage Admin and create service account key as JSON file, rename it to `creds.json`
 3) Put service account credentials `creds.json` in `keys/` folder at the root project folder (<PROJECT_FOLDER_NAME>/keys/creds.json)
 4) Run command `gcloud init` and `gcloud auth application-default login` to config email account and project_id then run `gcloud auth configure-docker`
## 5.3 Push Container Image to Artifact registry (aka container registry)
 1) Go to [Artifact Registry Console](https://console.cloud.google.com/artifacts)
 2) Create a new repository as following:

<img width="517" alt="repo1" src="https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics/assets/68572758/efee5b56-ca03-44d6-a6b8-e4547ae69f66">

<img width="338" alt="repo2" src="https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics/assets/68572758/c8fd32d9-a08c-4c7f-8ab9-fa25f427c7c3">

3) At root folder, run a command: (Please change values according yours.)

`docker build -t gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME .`
4) Push our container, run a command :

`docker push gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME`

## 5.4 Prepare Environment Variables
1) Edit `.dev` and save as `.env` (only 5 variables)
```
TF_VAR_project_id=
TF_VAR_region=
TF_VAR_zone=
TF_VAR_location=
TF_VAR_docker_image=gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME
```
## 5.5 Run Terraform
1) Navigate to folder `terraform`
2) Run `terraform init`, `terraform plan` and then `terraform apply`
   Terraform will create resources i.e. bigquery dataset, gcs storage bucket, cloud run service (for running pipeline on cloud) 
## 5.6 [Navigate to cloud run](https://console.cloud.google.com/run?referrer=search&hl=en) then click cloud run service http link to open a container service or click output link showed in the CLI used to run 5.5

<img width="433" alt="cloud run" src="https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics/assets/68572758/ed0831d1-c343-4496-a211-0e31ae22fefe">

## 5.7 Run a pipeline through Mage.ai
1) Choose pipeline named `nz-traffic-count`
2) Create Trigger

<img width="551" alt="mage1" src="https://github.com/ranchana-k/NZ_State_Highway_Traffic_Analytics/assets/68572758/f795a145-3c62-4c05-a069-2f00d85bdafe">

3) Select Run @once to trigger the whole pipeline

# 6. Dashboard
At first , I'd like to visualize the data with monitoring site (X,Y) coordinates found in SH_Traffic_Monitoring_Site. Unfortunately, they were not google map coordinates and probably belonged to an old version New Zealand standard map. Therefore, I can visualize by only region.

[Dashboard](https://lookerstudio.google.com/reporting/223ca748-2fc2-47e1-b573-66b397fab61c/page/teOxD/edit)

