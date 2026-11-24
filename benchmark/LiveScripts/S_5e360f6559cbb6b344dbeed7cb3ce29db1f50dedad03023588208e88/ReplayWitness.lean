import CardanoLedgerApi.V3
import LiveScripts.S_5e360f6559cbb6b344dbeed7cb3ce29db1f50dedad03023588208e88.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "ú" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "ÿ" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 10 11 12) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 23514)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "D" },
                txOutReferenceScript := some { data := "1" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 23514, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "â" }, 5)],
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
        [(Contexts.ScriptPurpose.Rewarding (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "â" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 16)],
      txInfoData := [], txInfoId := { data := "újX»âÐÿ\x05SD1Èâðï,½Á`*Vä±<0w" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 27893,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 24390 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 16,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "â" }) } : ScriptContext)
