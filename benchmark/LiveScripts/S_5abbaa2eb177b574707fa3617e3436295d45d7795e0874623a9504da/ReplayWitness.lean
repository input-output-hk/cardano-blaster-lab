import CardanoLedgerApi.V3
import LiveScripts.S_5abbaa2eb177b574707fa3617e3436295d45d7795e0874623a9504da.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 303140)])],
                txOutDatum :=
                  CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 66),
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 303140, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl :=
        [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
              { data := "0ñ\tZ*Ëh»\x0fú\x19>\x18à\x04¶Ý>\x12µÙÂ7Z\x1d\\A" },
            5)],
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
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 53)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 17193,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 13986 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 53,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 8 }
      (some (PlutusCore.Data.PlutusCore.DataInternal.Data.I 66)) } : ScriptContext)
