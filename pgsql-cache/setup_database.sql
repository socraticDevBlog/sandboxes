-- Create the pg_cron extension first
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Only difference from normal table is the UNLOGGED keyword. 
-- As for the columns, here we use JSONB values, but you could use whatever suits 
-- your needs, e.g. text, varchar or hstore. We also include inserted_at column,
-- which will be used for cache invalidation. Optionally, we also create an index
-- for better read performance. 

CREATE UNLOGGED TABLE cache (
    id serial PRIMARY KEY,
    key text UNIQUE NOT NULL,
    value jsonb,
    inserted_at timestamp);

CREATE INDEX idx_cache_key ON cache (key);

CREATE OR REPLACE PROCEDURE expire_rows (retention_period INTERVAL) AS
$$
BEGIN
    DELETE FROM cache
    WHERE inserted_at < NOW() - retention_period;

    COMMIT;
END;
$$ LANGUAGE plpgsql;

CALL expire_rows('60 minutes');

SELECT cron.schedule('*/5 * * * *', $$CALL expire_rows('1 hour');$$);


CREATE OR REPLACE PROCEDURE insert_cache_row()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.cache (key, value, inserted_at)
    VALUES (
        'auto_' || extract(epoch from NOW())::text || '_' || floor(random() * 1000)::text,
        jsonb_build_object(
            'timestamp', NOW(),
            'message', 'Auto-generated cache entry',
            'random', floor(random() * 10000)
        ),
        NOW()
    );
    
    COMMIT;
END;
$$;

SELECT cron.schedule(
    'insert-cache-every-minute',  -- job name
    '* * * * *',                   -- every minute (cron format)
    $$CALL insert_cache_row();$$
);

SELECT * FROM cron.job;


