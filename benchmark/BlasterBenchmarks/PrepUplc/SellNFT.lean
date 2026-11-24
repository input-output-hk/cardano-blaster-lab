import Benchmark.PrepUplc.Harness
import CardanoLedgerApi.V2

open CardanoLedgerApi.V2

-- Keep the original script, conversion, and 1800-step budget used by
-- CardanoLedgerApiBlaster/Tests/Scripts/SellNFT/SellNFT.lean.
#bench_prep_uplc_file "sellNFT@1800" PlutusV2 single_cbor_hex
  "../packages/CardanoLedgerApiBlaster/Tests/Scripts/SellNFT/sell_nft.flat" spendingInputs 1800
