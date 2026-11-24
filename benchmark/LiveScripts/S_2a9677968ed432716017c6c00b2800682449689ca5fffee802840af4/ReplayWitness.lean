import CardanoLedgerApi.V3
import LiveScripts.S_2a9677968ed432716017c6c00b2800682449689ca5fffee802840af4.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "\x07" }, txOutRefIdx := 3 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "p" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 10 11 12) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 101227)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
                txOutReferenceScript := some { data := "È" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 101227, txInfoMint := [], txInfoTxCerts := [],
      txInfoWdrl := [(CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "`" }, 5)],
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
        [(Contexts.ScriptPurpose.Rewarding (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "`" }),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 21)],
      txInfoData := [], txInfoId := { data := "\x07ë/°Ö`8pÎoÈøPbI\x15!sÝðÇ\x7f\x1f\x07ì" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 19590,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20799 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 21,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.RewardingScript (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "`" }) } : ScriptContext)
