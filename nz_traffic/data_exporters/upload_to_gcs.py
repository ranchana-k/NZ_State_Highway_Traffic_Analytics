import pyarrow as pa 
import pyarrow.parquet as pq
import os

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

#os.environ['GOOGLE_APPLICATION_CREDENTIALS']='/home/src/keys/creds.json'
project_id = os.environ['TF_VAR_project_id']
bucket_name = os.environ['TF_VAR_storage_bucket_name']
root_path = f'{bucket_name}'

@data_exporter
def export_data(data, *args, **kwargs):
    table = pa.Table.from_pandas(data)
    gcs = pa.fs.GcsFileSystem()
    pq.write_to_dataset(
        table,
        root_path=root_path,
        partition_cols=['date'],
        filesystem=gcs
    )


