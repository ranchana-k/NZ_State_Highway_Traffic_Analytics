import io
import pandas as pd
import requests
import json
from datetime import datetime, timedelta
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    main_url = 'https://services.arcgis.com/CXBb7LAjgIIdcsPt/arcgis/rest/services/TMS_Telemetry_Sites/FeatureServer/0/query?where='
    year_range = [2022,2023]
    data = []
    for year in year_range:
        for month in range(1,13):
            start_date = datetime(year,month,1)
            # If the month is December (12), the next month is January of the next year
            if month == 12: 
                end_date = datetime(year + 1,1,1)
            else: 
                end_date = datetime(year,month+1,1)

            standardMaxRecord = 32000
            maxRecordCountFactor = 4
            size_limit = standardMaxRecord * maxRecordCountFactor
            query = "startDate >= TIMESTAMP '" + str(start_date) + "' AND startDate < TIMESTAMP '" + str(end_date) + "'&outFields=*&maxRecordCountFactor=" + str(maxRecordCountFactor) + "&resultType=standard&outSR=4326&f=json"
            url = main_url + query

            response = requests.get(url)
            response.raise_for_status()
            response_dict = response.json()
            if 'features' in response_dict.keys():
                # load data in to dataframe
                print("Total records:", len(response_dict['features']))
                chunk_df = pd.json_normalize(response_dict,"features")
                chunk_df.columns = [col.split('.', 1)[1] if '.' in col else col for col in chunk_df.columns]

                data = data + chunk_df.values.tolist()
    df = pd.DataFrame(data, columns = ['OBJECTID', 'startDate', 'siteID', 'regionName', 'SiteRef',
       'classWeight', 'siteDescription', 'laneNumber', 'flowDirection',
       'trafficCount'])
                
    return df


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
