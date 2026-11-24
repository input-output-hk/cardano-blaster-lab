import CardanoLedgerApi.V3
import LiveScripts.S_1bcd2ac824b02aac21c4a018138aca4884c99fb3b9bca64d6240af2e.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "g" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "´" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 10 11 12) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 1)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "Ï" },
                txOutReferenceScript := some { data := "¸" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 1, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }, 5)],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Rewarding (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 14)],
      txInfoData := [], txInfoId := { data := "gCô¶F´àfÏ¸ª=\x01ï\x04\x1bm&F¾Lì\t" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 28477,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 27893 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 14,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }) } : ScriptContext)
