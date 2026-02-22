-- Del Mundos: Paper Hands Analysis
-- Identifies wallets that sold early and missed potential gains
-- Based on 7-day average market price
-- Dashboard: https://dune.com/captainzeezy/del-mundos

WITH sales AS (
    SELECT 
        seller,
        nft_token_id as token_id,
        amount_original as sell_price,
        block_time
    FROM opensea.trades
    WHERE nft_contract_address = 0x313e99d23d6a9ed47af8d26ce99d8901c137343e
        AND blockchain = 'ethereum'
        AND amount_original > 0
),

recent_avg AS (
    SELECT AVG(amount_original) as current_price
    FROM opensea.trades
    WHERE nft_contract_address = 0x313e99d23d6a9ed47af8d26ce99d8901c137343e
        AND blockchain = 'ethereum'
        AND amount_original > 0
        AND block_time >= NOW() - INTERVAL '7' DAY
)

SELECT 
    s.seller as wallet,
    COUNT(DISTINCT s.token_id) as nfts_sold,
    ROUND(SUM(s.sell_price), 4) as total_sold_for_eth,
    ROUND(COUNT(DISTINCT s.token_id) * MAX(r.current_price), 4) as could_have_made_eth,
    ROUND((COUNT(DISTINCT s.token_id) * MAX(r.current_price)) - SUM(s.sell_price), 4) as missed_gains_eth,
    ROUND(((COUNT(DISTINCT s.token_id) * MAX(r.current_price)) - SUM(s.sell_price)) / SUM(s.sell_price) * 100, 2) as missed_gain_pct
FROM sales s
CROSS JOIN recent_avg r
GROUP BY s.seller
HAVING SUM(s.sell_price) > 0
ORDER BY missed_gains_eth DESC
