import CardanoLedgerApi.V3
import LiveScripts.S_78bbd2b4a99afc6500df8c9f38300001835bf2bc7211ecb1dffecfea.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 7 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 145266)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 145266, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 7 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
      txInfoData :=
        [({ data := "" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
              [PlutusCore.Data.PlutusCore.DataInternal.Data.I 14,
                PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }])],
      txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 25875,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 24373 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 7 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 14,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }])) } : ScriptContext)
