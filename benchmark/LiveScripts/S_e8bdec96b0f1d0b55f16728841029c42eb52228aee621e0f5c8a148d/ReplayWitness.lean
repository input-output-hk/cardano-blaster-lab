import CardanoLedgerApi.V3
import LiveScripts.S_e8bdec96b0f1d0b55f16728841029c42eb52228aee621e0f5c8a148d.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 29 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 35 36 37) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 198284)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                      [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "BCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" }]),
                txOutReferenceScript := some { data := "BCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 198284, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl :=
        [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "BCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" }, 30)],
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
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 29 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 432)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 28322,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 19559 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 432,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 29 }
      (some
        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "BCDEFGHIJKLMNOPQRSTUVWXYZ[\\]" }])) } : ScriptContext)
