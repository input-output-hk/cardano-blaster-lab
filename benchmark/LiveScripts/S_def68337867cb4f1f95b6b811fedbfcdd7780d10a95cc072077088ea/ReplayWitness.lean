import CardanoLedgerApi.V3
import LiveScripts.S_def68337867cb4f1f95b6b811fedbfcdd7780d10a95cc072077088ea.Script

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
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 459532)]),
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "B" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 13516)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 459532,
      txInfoMint :=
        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "B" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Map
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.I (-13516))])],
      txInfoTxCerts := [], txInfoWdrl := [],
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
        [(Contexts.ScriptPurpose.Minting { data := "B" }, PlutusCore.Data.PlutusCore.DataInternal.Data.I 18)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 21767,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 16142 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 18,
  scriptContextScriptInfo := Contexts.ScriptInfo.MintingScript { data := "B" } } : ScriptContext)
