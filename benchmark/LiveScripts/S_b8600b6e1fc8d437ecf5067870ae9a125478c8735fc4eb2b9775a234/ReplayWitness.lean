import CardanoLedgerApi.V3
import LiveScripts.S_b8600b6e1fc8d437ecf5067870ae9a125478c8735fc4eb2b9775a234.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 5 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 109053)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 4
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 3,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 109053, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22726,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 13032 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 5 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 4
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 3,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }])) } : ScriptContext)
