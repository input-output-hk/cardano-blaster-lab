import CardanoLedgerApi.V3
import LiveScripts.S_9aa880b46f8b66197cc3d401e64ba48c05b4e3e026798e488fa04131.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 108701)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 108701, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
            (some 17)],
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
              (TxCert.TxCert.TxCertRegStaking
                (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }) (some 17)),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 15)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 10809,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 1833 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 15,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
        (some 17)) } : ScriptContext)
