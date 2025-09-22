-- cumulative returns aggregated by time window
SELECT
  time_bucket,
  sum(cum_ret) OVER (ORDER BY time_bucket) as bucket_cum_rets
FROM (
  SELECT
    toStartOfInterval(timestamp, INTERVAL ${aggregate_window}) as time_bucket,
    log(argMax(mid, timestamp)/argMin(mid, timestamp)) * 100 as cum_ret
  FROM
    crypto_trading.tob
    WHERE full_instr = '$full_instr'
    AND ( timestamp >= $__fromTime AND timestamp <= $__toTime )
  GROUP BY time_bucket
)
ORDER BY time_bucket

-- cumulative volume delta with aggregation window
SELECT
  time_bucket,
  sum(bucket_cvd) OVER (ORDER BY time_bucket) as cvd
FROM (
  SELECT
    toStartOfInterval(timestamp, INTERVAL ${aggregate_window}) as time_bucket,
    sum(
      CASE
        WHEN side = 'sell' THEN (qty * price) * -1
        ELSE qty * price
      END
    ) as bucket_cvd
  FROM
    crypto_trading.agg_trades
    WHERE full_instr = '$full_instr'
    AND ( timestamp >= $__fromTime AND timestamp <= $__toTime )
  GROUP BY time_bucket
)
ORDER BY time_bucket

-- recent trades table
SELECT timestamp, price, qty, price * qty as notional, side, full_instr FROM "crypto_trading"."agg_trades" WHERE ( full_instr = '$full_instr' ) ORDER BY timestamp DESC LIMIT 100


-- funding rates
SELECT
  time_bucket,
  agg_fr
FROM (
  SELECT
    toStartOfInterval(timestamp, INTERVAL $aggregate_window) as time_bucket,
    avg(funding_rate) as agg_fr
  FROM
    crypto_trading.funding_rates
    WHERE full_instr = '$full_instr'
    AND ( timestamp >= $__fromTime AND timestamp <= $__toTime )
  GROUP BY time_bucket
)
ORDER BY time_bucket