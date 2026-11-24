import CardanoLedgerApi.V3
import LiveScripts.S_17d0515468d89d073bffcae84e20ebb8417e3c9faad22dc8bdf4e087.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "A" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "A" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 10 11 12) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 288737)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
                txOutReferenceScript := some { data := "A" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 288737, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "A" }, txOutRefIdx := 3 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 25)],
      txInfoData := [], txInfoId := { data := "A" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 18652,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 10022 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 25,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "A" }, txOutRefIdx := 3 } none } : ScriptContext)
