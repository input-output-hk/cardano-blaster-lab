import CardanoLedgerApi.V3
import LiveScripts.S_50a65666e492e14fbfd080bd7ba3448aecd3a308b6d46f0ee5a0cc0f.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 64834)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 64834, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
            (some 18)],
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
                (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }) (some 18)),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 16)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 10809,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 1833 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 16,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
        (some 18)) } : ScriptContext)
