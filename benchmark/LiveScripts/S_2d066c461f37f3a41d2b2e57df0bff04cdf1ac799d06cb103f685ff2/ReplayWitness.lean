import CardanoLedgerApi.V3
import LiveScripts.S_2d066c461f37f3a41d2b2e57df0bff04cdf1ac799d06cb103f685ff2.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 7 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 13 14 15) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 404787)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "A" },
                txOutReferenceScript := some { data := "" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 404787, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }, 9)],
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
        [(Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 7 },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
              [PlutusCore.Data.PlutusCore.DataInternal.Data.I (-1587)])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 29315,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 9504 },
  scriptContextRedeemer :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [PlutusCore.Data.PlutusCore.DataInternal.Data.I (-1587)],
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.SpendingScript { txOutRefId := { data := "" }, txOutRefIdx := 7 } none } : ScriptContext)
