import CardanoLedgerApi.V3
import LiveScripts.S_381cd9b620ce9d7c73dd45cfe207971cc79df79251003116094f6b36.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 279159)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 21
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 2362,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.List []]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 279159, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 2363],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 7 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 28)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 27490,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 18241 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 28,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 7 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 21
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 2362,
            PlutusCore.Data.PlutusCore.DataInternal.Data.List []])) } : ScriptContext)
