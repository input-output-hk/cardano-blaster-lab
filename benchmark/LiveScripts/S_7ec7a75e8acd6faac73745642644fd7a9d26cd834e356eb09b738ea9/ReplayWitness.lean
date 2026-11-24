import CardanoLedgerApi.V3
import LiveScripts.S_7ec7a75e8acd6faac73745642644fd7a9d26cd834e356eb09b738ea9.Script

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
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "𠀀" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 72367)]),
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 1)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 72367,
      txInfoMint :=
        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Map
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.I (-1))])],
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
        [(Contexts.ScriptPurpose.Minting { data := "A" }, PlutusCore.Data.PlutusCore.DataInternal.Data.I 13)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 24619,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 18458 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 13,
  scriptContextScriptInfo := Contexts.ScriptInfo.MintingScript { data := "A" } } : ScriptContext)
