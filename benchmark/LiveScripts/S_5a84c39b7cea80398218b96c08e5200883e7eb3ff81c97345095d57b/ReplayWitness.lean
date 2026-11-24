import CardanoLedgerApi.V3
import LiveScripts.S_5a84c39b7cea80398218b96c08e5200883e7eb3ff81c97345095d57b.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 286904)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 286904, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
            (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
              (TxCert.DRep.DRep
                (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
                  { data := "bCx+\x1bïh=Mõ ¡å=\x1erÍ3¸a÷K4\x04" })))
            86],
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
                (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
                  (TxCert.DRep.DRep
                    (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
                      { data := "bCx+\x1bïh=Mõ ¡å=\x1erÍ3¸a÷K4\x04" })))
                86),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 85)],
      txInfoData := [], txInfoId := { data := "\x0ek'£°ÙE\x0b\x0b\x17ªmu 0¦1Þâr8{" }, txInfoVotes := [],
      txInfoProposalProcedures := [], txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 236,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 30834 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 85,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" })
        (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
          (TxCert.DRep.DRep
            (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
              { data := "bCx+\x1bïh=Mõ ¡å=\x1erÍ3¸a÷K4\x04" })))
        86) } : ScriptContext)
