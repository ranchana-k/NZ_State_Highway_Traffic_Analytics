{{ config(
    materialized="table",
    partition_by={
        'field': 'date',
        'data_type': 'date',
        'granularity': 'day'
    },
    cluster_by=['region']) }}

with traffic_count as (
    SELECT
    *
from {{ ref('stg_traffic_count') }}
),
sites as (
    select * from {{ ref('traffic_monitoring_sites') }}
)


select traffic_count.*,
sites.X,
sites.Y,
sites.SH,
sites.type,
sites.region,
sites.percentHeavy
from traffic_count
left join sites 
on traffic_count.site_ref = sites.siteRef
