import CardanoLedgerApi.V3
import LiveScripts.S_f0bdb73a9fe70b6c0781b7a7466274dce6d78c7bd3e8fcb4244935e2.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" }, txOutRefIdx := 33 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  {
                    addressCredential :=
                      CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                        { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 174758)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 19405,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 93]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 174758, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
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
        [(Contexts.ScriptPurpose.Spending
              { txOutRefId := { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" }, txOutRefIdx := 33 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 101)],
      txInfoData := [], txInfoId := { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 28705,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 12836 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 101,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" }, txOutRefIdx := 33 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "]\\[ZYXWVUTSRQPONMLKJIHGFEDCB" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 19405, PlutusCore.Data.PlutusCore.DataInternal.Data.I 93])) } : ScriptContext)
