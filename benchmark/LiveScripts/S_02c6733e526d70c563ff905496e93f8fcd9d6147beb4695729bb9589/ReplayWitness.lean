import CardanoLedgerApi.V3
import LiveScripts.S_02c6733e526d70c563ff905496e93f8fcd9d6147beb4695729bb9589.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "¢" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "-" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 100076)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 100076, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x10" }, 5)],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "¢lß¼\x10À-¢o]\t1\x0dx\x0cH/+\x13¥ÕQçöî" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Rewarding
              (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x10" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 15)],
      txInfoData := [], txInfoId := { data := "\x12~Üª¼X\n°eê\x01Æ­ç\x1fõ0yPã¿\x07þ+\x19" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 18936,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 17452 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 15,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript
      (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x10" }) } : ScriptContext)
