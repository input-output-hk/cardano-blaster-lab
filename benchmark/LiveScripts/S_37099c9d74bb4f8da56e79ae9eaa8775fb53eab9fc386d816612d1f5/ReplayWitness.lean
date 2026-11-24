import CardanoLedgerApi.V3
import LiveScripts.S_37099c9d74bb4f8da56e79ae9eaa8775fb53eab9fc386d816612d1f5.Script

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
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 29219)]),
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 42107)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
      txInfoReferenceInputs := [],
      txInfoOutputs :=
        [{
            txOutAddress :=
              { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                addressStakingCredential :=
                  some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 11 12 13) },
            txOutValue :=
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                    [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                        PlutusCore.Data.PlutusCore.DataInternal.Data.I 27070)])],
            txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
            txOutReferenceScript := some { data := "" } }],
      txInfoFee := 2149,
      txInfoMint :=
        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Map
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.I (-42107))])],
      txInfoTxCerts := [], txInfoWdrl := [],
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
        [(Contexts.ScriptPurpose.Minting { data := "A" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" })],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 14876,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 5908 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
  scriptContextScriptInfo := Contexts.ScriptInfo.MintingScript { data := "A" } } : ScriptContext)
