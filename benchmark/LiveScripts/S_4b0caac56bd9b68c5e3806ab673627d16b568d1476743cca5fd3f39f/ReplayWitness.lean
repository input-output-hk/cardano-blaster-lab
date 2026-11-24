import CardanoLedgerApi.V3
import LiveScripts.S_4b0caac56bd9b68c5e3806ab673627d16b568d1476743cca5fd3f39f.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 306408)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 20,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 19,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 18,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 17,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 16,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 15,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 306408, txInfoMint := [], txInfoTxCerts := [],
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
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 3 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 40)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 24556,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 7816 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 40,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 3 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 20, PlutusCore.Data.PlutusCore.DataInternal.Data.I 19,
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 18, PlutusCore.Data.PlutusCore.DataInternal.Data.I 17,
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 16, PlutusCore.Data.PlutusCore.DataInternal.Data.I 15,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }])) } : ScriptContext)
