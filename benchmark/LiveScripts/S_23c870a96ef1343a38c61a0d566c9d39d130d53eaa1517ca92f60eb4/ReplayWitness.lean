import CardanoLedgerApi.V3
import LiveScripts.S_23c870a96ef1343a38c61a0d566c9d39d130d53eaa1517ca92f60eb4.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }, txOutRefIdx := 29 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  {
                    addressCredential :=
                      CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                        { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 36 37 38) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 613123)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" },
                txOutReferenceScript := some { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 613123, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []]],
      txInfoSignatories := [{ data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending
              { txOutRefId := { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }, txOutRefIdx := 29 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [])],
      txInfoData :=
        [({ data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 35
              [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.I 41,
                PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }])],
      txInfoId := { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22297,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 29856 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }, txOutRefIdx := 29 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 35
          [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 41,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "\\[ZYXWVUTSRQPONMLKJIHGFEDCBA" }])) } : ScriptContext)
