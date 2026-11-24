import CardanoLedgerApi.V3
import LiveScripts.S_41d03b6245bfde772ab5a5e19362db621e4280a3d73068958e5a1cce.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 4 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "" },
                    addressStakingCredential := none },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 186957)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 186957, txInfoMint := [],
      txInfoTxCerts :=
        [TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "A" })
            (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
              (TxCert.DRep.DRep
                (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
                  { data := "7>¨hðü\tK\x1fòþ¸Q1\x19oº@)Ø¨" })))
            118],
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
              (TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "A" })
                (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
                  (TxCert.DRep.DRep
                    (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
                      { data := "7>¨hðü\tK\x1fòþ¸Q1\x19oº@)Ø¨" })))
                118),
            PlutusCore.Data.PlutusCore.DataInternal.Data.I 38)],
      txInfoData := [], txInfoId := { data := "\x0ek'£°ÙE\x0b\x0b\x17ªmu 0¦1Þâr8{" }, txInfoVotes := [],
      txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 13062,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 14182 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 38,
  scriptContextScriptInfo :=
    Contexts.ScriptInfo.CertifyingScript 0
      (TxCert.TxCert.TxCertRegDeleg (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "A" })
        (TxCert.Delegatee.DelegStakeVote { data := "ë´\x7fsnr\x01vºEÏxâ8´E+zd(¦é" }
          (TxCert.DRep.DRep
            (CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential
              { data := "7>¨hðü\tK\x1fòþ¸Q1\x19oº@)Ø¨" })))
        118) } : ScriptContext)
