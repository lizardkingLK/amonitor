# allow execution access
# chmod +x ./script_db_select_alerts.sh

#!/bin/bash

# selects data contains in the table for a quick view
docker exec -it timescaledb psql -U postgres -d alerts_db -c "
SELECT 
    inner_data.severity AS category,
    COUNT(*) AS total_alerts
FROM "\"Alerts\"",
LATERAL jsonb_to_record(data) AS outer_data(
    essentials JSONB
),
LATERAL jsonb_to_record(outer_data.essentials) AS inner_data(
    severity TEXT
)
GROUP BY category
ORDER BY total_alerts DESC
LIMIT 50"