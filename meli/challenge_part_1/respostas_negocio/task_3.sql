INSERT INTO delivery.fact_daily_item_status (
  item_id, 
  item_name, 
  amount, 
  status, 
  processed_at_date_id
)
SELECT
  di.item_id,
  di.item_name,
  di.amount,
  CASE 
    WHEN di.end_date_id IS NOT NULL THEN 1 -- Status ativo se end_date_id não for nulo
    ELSE 0 -- Status inativo caso contrário
  END AS status,
  TO_CHAR(CURRENT_DATE, 'YYYYMMDD')::INTEGER AS processed_at_date_id

FROM delivery."dim_items" AS di
LEFT JOIN delivery."dim_date" AS dd
  ON di.processed_at_date_id = dd.date_id

WHERE dd.date_id = TO_CHAR(CURRENT_DATE, 'YYYYMMDD')::INTEGER -- Isso aqui serve pra processar apenas para a data atual

ON CONFLICT (item_id, processed_at_date_id) -- Gerencia conflitos nessa chave composta da junção entre item_id e processed_at_date_id
DO UPDATE SET
  item_name = EXCLUDED.item_name,
  amount = EXCLUDED.amount,
  status = EXCLUDED.status

--Aqui a minha ideia seria a atualização dessa tabela ser feita através de uma task dentro de uma DAG no Airflow. 
