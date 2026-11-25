import CardanoLedgerApi.V3
import LiveScripts.S_fc8787790a71e54cdd00e6e49265bb977f30aa0618fb4c2ab8817c66.Script

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
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 140408)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 140408, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
            (TxCert.Delegatee.DelegVote TxCert.DRep.DRepAlwaysAbstain) 28],
      txInfoWdrl := [],
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
        [(Contexts.ScriptPurpose.Certifying 0
              (TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
                (TxCert.Delegatee.DelegVote TxCert.DRep.DRepAlwaysAbstain) 28),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 22)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20056,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 20329 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
        (TxCert.Delegatee.DelegVote TxCert.DRep.DRepAlwaysAbstain) 28) } : ScriptContext)
