import CardanoLedgerApi.V3
import LiveScripts.S_774dd58762420f567ac35e28c47197fab4d93025838974c2c9fa98c4.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 453067)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 10
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 14,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 13,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 21973]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 453067, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 21974],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 21976],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22868,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 26154 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 8 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 10
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 14, PlutusCore.Data.PlutusCore.DataInternal.Data.I 13,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 21973])) } : ScriptContext)
