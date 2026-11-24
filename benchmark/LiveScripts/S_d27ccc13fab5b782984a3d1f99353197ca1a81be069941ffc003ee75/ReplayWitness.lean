import CardanoLedgerApi.V3
import LiveScripts.S_d27ccc13fab5b782984a3d1f99353197ca1a81be069941ffc003ee75.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 21660)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "B" },
                txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 21660, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [],
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
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 8 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 15)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 19559,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 23647 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 15,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 8 } none } : ScriptContext)
