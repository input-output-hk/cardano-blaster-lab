import CardanoLedgerApi.V3
import LiveScripts.S_4c38a676bb2f95fb97c8d20065eee6ac2551ee32422b8d69b58d3daa.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 4076)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 10
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                              [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }],
                            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [],
      txInfoOutputs :=
        [{
            txOutAddress :=
              { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                addressStakingCredential := none },
            txOutValue :=
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                    [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 1)])],
            txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
            txOutReferenceScript := some { data := "" } }],
      txInfoFee := 4075, txInfoMint := [], txInfoTxCerts := [], txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 1982,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 25319 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 8 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 10
          [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]])) } : ScriptContext)
