SELECT 
    ds.seller_id,
    ds.customer_name,
    ds.store_name,
    ds.birth_date_id,
    SUM(fs.total_items)

FROM delivery."fact_sales" fs
JOIN delivery."dim_sellers" ds
    ON fs.seller_id = ds.seller_id
JOIN delivery."dim_date" dd
    ON fs.date_id = dd.date_id

WHERE 
    birth_date_id = CAST(TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') AS INTEGER)
    AND dd.year = 2020
    AND dd.month = 1

GROUP BY 
    ds.seller_id, ds.customer_name, ds.store_name, ds.birth_date

HAVING 
    SUM(fs.total_items) > 1500
