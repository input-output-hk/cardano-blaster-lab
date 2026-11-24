import CardanoLedgerApi.V3
import LiveScripts.S_6fb003585fcdf63810bb9c2a117b71cf61772bebaa31040f84d02928.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "À" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "¿" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 1)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 1, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "S" }, 5)],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [{ data := "ÀÒäº¤üS®¿¨×ÉÐ(\x10n:åY=TÅ\x12\x13Ê" }],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Rewarding (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "S" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 21)],
      txInfoData := [], txInfoId := { data := "À" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 24273,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20056 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 21,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "S" }) } : ScriptContext)
