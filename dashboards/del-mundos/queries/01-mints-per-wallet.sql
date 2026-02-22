-- Del Mundos: Mints Per Wallet
-- Shows how many NFTs each wallet minted, ranked by count
-- Dashboard: https://dune.com/captainzeezy/del-mundos

SELECT 
    "to" as minter,
    COUNT(*) as num_minted,
    MIN(evt_block_time) as first_mint,
    MAX(evt_block_time) as last_mint
FROM erc721_ethereum.evt_Transfer
WHERE contract_address = 0x313e99d23d6a9ed47af8d26ce99d8901c137343e
    AND "from" = 0x0000000000000000000000000000000000000000
GROUP BY "to"
ORDER BY num_minted DESC
LIMIT 20
