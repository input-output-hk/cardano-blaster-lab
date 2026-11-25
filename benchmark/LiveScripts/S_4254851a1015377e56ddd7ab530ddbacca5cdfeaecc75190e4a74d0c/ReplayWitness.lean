import CardanoLedgerApi.V3
import LiveScripts.S_4254851a1015377e56ddd7ab530ddbacca5cdfeaecc75190e4a74d0c.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "×" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "Z" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 44038)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 44038, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl :=
        [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
              { data := "ælJyÕ9\x0fµðú\x03]($¡`×¥¿tJÖ\x10+" },
            5)],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 33707],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Rewarding
              (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                { data := "ælJyÕ9\x0fµðú\x03]($¡`×¥¿tJÖ\x10+" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [])],
      txInfoData := [], txInfoId := { data := "×ÐB\x07÷h2Z\x00E\néGÎu\x0fmÀfÐ\x0cáM\x04é" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 8910,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 32210 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript
      (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "ælJyÕ9\x0fµðú\x03]($¡`×¥¿tJÖ\x10+" }) } : ScriptContext)
