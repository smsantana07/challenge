WITH monthly_sales AS (
    SELECT 
        dd.year,
        dd.month,
        ds.customer_name AS complete_name,
        COUNT(fs.total_items) AS accomplished_sales, -- Aqui considerei a quantidade de vendas realizadas igual a quantidade de produtos vendidos, pois temos (de acordo com a doc) a seguinte afirmação como premissa: "para cada item que for vendido será refletido em uma order independente da quantidade que for comprada."
        SUM(fs.total_amount) AS total_amount 

    FROM delivery."fact_sales" AS fs
    JOIN delivery."dim_sellers" AS ds
        ON fs.seller_id = ds.seller_id
    JOIN delivery."dim_date" AS dd
        ON fs.date_id = dd.date_id
    JOIN delivery."dim_category" AS dc
        ON fs.category_id = dc.category_id

    WHERE 
        dd.year = 2020 
        AND dc.category_name LIKE '%Celulares%' -- Aqui coloquei dessa forma (like) para buscar quaisquer categorias que contenham o nome "Celulares", endependentemente do path.  
    
    GROUP BY 
        dd.year, dd.month, ds.customer_name
),
ranked_sales AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY year, month ORDER BY total_amount DESC) AS ranking
    FROM monthly_sales

)
SELECT 
    year,
    month,
    complete_name,
    accomplished_sales,
    total_amount
FROM ranked_sales
WHERE ranking <= 5 -- Top 5 para cada mês
ORDER BY 
    year, month, ranking
