# NZ State Highway Traffic Analytics
Transit New Zealand is dedicated to designing, developing, and upkeeping the state highway system to ensure it enhances a safe, responsive, sustainable land transportation system across New Zealand. Monitoring traffic on the state highway helps the authorities to analyse and plan for action in order to achieve their goals.

# 1. Objective
This end-to-end pipeline provides daily traffic count across New Zealand State Highways which is designed to deliver key metrics such as vehicle counts, the most frequented monitoring sites, percent heavy load vehicles. While the default configuration focuses on pre-selected key monitoring region, the geographical scope and specific sites of interest can be dynamically adjusted according to user needs. The project seeks to offer insights that support effective traffic management and infrastructure development.

# 2. Data Source 
Dataset is provided by NZ Transport Agency through [TMS daily traffic counts API](https://opendata-nzta.opendata.arcgis.com/datasets/NZTA::tms-daily-traffic-counts-api/about), together with [static SH traffic monitoring sites data](https://opendata-nzta.opendata.arcgis.com/datasets/NZTA::state-highway-traffic-monitoring-sites/about). 

# 3. Tech Stack Overview and Workflow
![Workflow](https://excalidraw.com/#json=M9GYkQykS6aCq7d05gtH2,AJv12zRKjNEWwpqS48zjoA)
- Data Ingestion: 
    Used Mage.ai as the workflow orchestrator for batch processing the data by year month, retrieving data from API and keep it in Google Cloud Storage (data lake). Then, append the new data into bigquery (used in transformation) and run dbt models to production Bigquery table.
- Data Storage: 
    Used Google Cloud Storage (GCS) as the primary data storage solution, ensuring data is securely stored and readily accessible.
- Data Transformations: 
    Used dbt (Data Build Tool) for transforming raw data into structured formats that are optimized for analysis. By joining traffic count data with monitoring sites data.
- Data Warehousing: 
    Used Google BigQuery to enables efficient data storage for transformed data and enhances querying capabilities. 
- Data Visualization: 
    Used Looker Studio to visualize key metrics.
- Cloud Infrastructure: 
    Terraform is used to provision and set up all google cloud infrastructure.

# 4. Prerequisites
- Install [gcloud SDK](https://cloud.google.com/sdk/docs/install)
- Gmail account (free for 300 USD credit) 
- Install Terraform

# 5. Project Setup
    5.1 Clone this git repo to a local folder
    5.2 Preparing Credentials
        1) Create a GCP project and enable [Service Usage API](https://console.cloud.google.com/apis/api/serviceusage.googleapis.com)
        2) Create a service account key with the role owner and create service account key as JSON file, rename it to `creds.json`
        3) Put service account credentials `creds.json` in `keys/` folder
        4) Run command `gcloud init` and `gcloud auth application-default login` to config email account and project_id then run `gcloud auth configure-docker`
    5.3 Push Container Image to Artifact registry (aka container registry)
        1) Go to [Artifact Registry Console](https://console.cloud.google.com/artifacts)
        2) Create a new repository as following:
        
        3) At root folder, run a command: (Please change values according yours.)
            `docker build -t gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME .`
        4) Push our container, run a command :
            `docker push gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME`
    5.5 Prepare Environment Variables
        1) Edit `.dev` and save as `.env` (only 5 variables)
        ```
        TF_VAR_project_id=
        TF_VAR_region=
        TF_VAR_zone=
        TF_VAR_location=
        TF_VAR_docker_image=gcr.io/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME
        ```
    5.6 Run Terraform
        1) Navigate to folder `terraform`
        2) Run `terraform init`, `terraform plan` and then `terraform apply`
    5.7 Navigate to [cloud run](https://console.cloud.google.com/run?referrer=search&hl=en) then click cloud run servic http link to open a container service or click output link showed from 5.6
    5.8 Run a pipeline through Mage.ai
        1) Choose pipeline named `nz-traffic-count`
        2) Create Trigger
        3) Select Run @once

# 6. Dashboard
[Dashboard](https://lookerstudio.google.com/reporting/223ca748-2fc2-47e1-b573-66b397fab61c/page/teOxD/edit)

