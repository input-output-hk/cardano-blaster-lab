import CardanoLedgerApi.V3
import LiveScripts.S_05d231799bdec5acab13e670b4107d81a5725814c2de7900d422fdb6.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "A" }, txOutRefIdx := 6 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 255103)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 5
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 4,
                        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "åð\n¼9%\x7f¡cúÿV^ûÁN036#v#dqyB" }]),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 255103, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "åð\n¼9%\x7f¡cúÿV^ûÁN036#v#dqyB" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "A" }, txOutRefIdx := 6 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 146)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 3738,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 13262 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 146,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "A" }, txOutRefIdx := 6 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 5
          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 4,
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "åð\n¼9%\x7f¡cúÿV^ûÁN036#v#dqyB" }])) } : ScriptContext)
