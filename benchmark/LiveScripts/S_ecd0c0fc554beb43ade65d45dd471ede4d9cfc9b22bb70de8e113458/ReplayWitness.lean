import CardanoLedgerApi.V3
import LiveScripts.S_ecd0c0fc554beb43ade65d45dd471ede4d9cfc9b22bb70de8e113458.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := " " }, txOutRefIdx := 8 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "÷" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 300678)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 38),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 300678, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl :=
        [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
              { data := " ÷eÒ]££fD7\x1fv\x19Ù{ÜÏ\x03O0g\x19!ÙÜà÷" },
            4)],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := " " }, txOutRefIdx := 8 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 37)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20025,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 26155 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 37,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := " " }, txOutRefIdx := 8 }
      (some (PlutusCore.Data.PlutusCore.DataInternal.Data.I 38)) } : ScriptContext)
