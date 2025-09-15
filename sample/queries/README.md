## Ask for memories

```
SELECT
  p.id as memory_id,
  p.name,
  obj ->> 'at'     AS at,
  obj ->> 'from'   AS "from",
  obj ->> 'to'     AS "to",
  obj ->> 'type'   AS "type",
  obj ->> 'action' AS action,
  obj ->> 'description' as description
FROM players p
CROSS JOIN LATERAL unnest(p.memory) AS m(elem)   -- elem é jsonb (pode ser objeto ou string)
CROSS JOIN LATERAL (
  SELECT CASE
           WHEN jsonb_typeof(elem) = 'string'
             THEN ((elem #>> '{}')::jsonb)  -- tira as aspas do jsonb string e converte pra jsonb objeto
           ELSE elem
         END AS obj
) t
WHERE obj ->> 'to' = 'Molinor' or obj ->> 'from' = 'Molinor'
ORDER BY p.name, (obj ->> 'at')::timestamptz;
```