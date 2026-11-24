import CardanoLedgerApi.V3
import LiveScripts.S_e57f046704184c3ae2d1af98dbed8201315ed1122bec5d6b2caa7282.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 65769)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 65769, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
            (some 23)],
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
                (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" }) (some 23)),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 21)],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 10809,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 1833 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 21,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegStaking (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
        (some 23)) } : ScriptContext)
