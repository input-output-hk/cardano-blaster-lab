import CardanoLedgerApi.V3
import LiveScripts.S_673f2bfaa44efb5e9ae881606e32f94dfbee5ccd1c8ca4f9c44365de.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 5 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 328694)]),
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 5639)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 328694,
      txInfoMint :=
        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Map
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.I (-5639))])],
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
        [(Contexts.ScriptPurpose.Minting { data := "A" }, PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 14896,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20281 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
  scriptContextScriptInfo := Contexts.ScriptInfo.MintingScript { data := "A" } } : ScriptContext)
