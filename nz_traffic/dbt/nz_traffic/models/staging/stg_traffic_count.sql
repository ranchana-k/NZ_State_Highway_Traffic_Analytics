{{ config(materialized="view") }}

with traffic as (
    SELECT
    {{ dbt_utils.generate_surrogate_key(["SiteRef","startDate"]) }} as traffic_count_id,
    {{ dbt.safe_cast("date", api.Column.translate_type("date")) }} as date,
    {{ dbt.safe_cast("startDate", api.Column.translate_type("datetime")) }} as start_datetime,
    SiteRef as site_ref,
    classWeight as class_weight,
    siteDescription,
    {{ dbt.safe_cast("laneNumber", api.Column.translate_type("integer")) }} as lane_number,
    {{ dbt.safe_cast("flowDirection", api.Column.translate_type("integer")) }} as flow_direction,
    {{ dbt.safe_cast("trafficCount", api.Column.translate_type("float")) }} as traffic_count,

from {{ source("nz_traffic_raw","raw_traffic_count")}}
)

select *
from traffic

{% if var('is_test_run', default=true) %} 
limit 100
{% endif %} 