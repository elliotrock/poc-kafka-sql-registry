SET 'auto.offset.reset' = 'earliest';

CREATE STREAM tote_win_bets (runner_id INT, race_id INT, amount DOUBLE)
    WITH (kafka_topic='tote_win_bets', partitions=1, value_format = 'avro');

-- Bets runner keyed by partition
CREATE STREAM tote_win_bets_runner_keyed 
    AS SELECT tote_win_bets.runner_id as runner_id, tote_win_bets.race_id as race_id, amount 
    FROM tote_win_bets
    PARTITION BY runner_id
    EMIT CHANGES;     

-- -- Bets race keyed by partition
CREATE STREAM tote_win_bets_race_keyed
    AS SELECT tote_win_bets.race_id as race_id, tote_win_bets.amount as amount
    FROM tote_win_bets
    PARTITION BY race_id 
    EMIT CHANGES;

-- -- Runner Pool MAX(race_id) as race_id
CREATE TABLE tote_runners_pool 
    AS SELECT runner_id, SUM(amount) as runner_pool_amount 
    FROM tote_win_bets_runner_keyed GROUP BY runner_id
    EMIT CHANGES; 

-- -- Race Pool
CREATE TABLE tote_race_pool 
    AS SELECT race_id, SUM(amount) as race_pool_amount 
    FROM tote_win_bets_race_keyed GROUP BY race_id
    EMIT CHANGES; 

-- -- form 3 way join odd stream
CREATE STREAM tote_win_bet_race_runners_odds WITH (kafka_topic='tote_win_bet_race_runners_odds', partitions=1, value_format = 'avro')
    AS
    SELECT tote_race_pool.race_id as race_id,
        tote_runners_pool.runner_id as runner_id,
        tote_runners_pool.runner_pool_amount as runner_pool_amount,
        tote_race_pool.race_pool_amount as race_pool_amount,
        CASE 
            WHEN tote_race_pool.race_pool_amount = 0 AND tote_runners_pool.runner_pool_amount = 0 THEN CAST(0 AS DOUBLE) 
            WHEN tote_runners_pool.runner_pool_amount = 0 THEN CAST(0 AS DOUBLE)
            ELSE tote_race_pool.race_pool_amount / tote_runners_pool.runner_pool_amount 
        END AS odds
    FROM tote_win_bets
    INNER JOIN tote_runners_pool ON tote_win_bets.runner_id = tote_runners_pool.runner_id   
    INNER JOIN tote_race_pool ON tote_win_bets.race_id = tote_race_pool.race_id
    EMIT CHANGES;  
  