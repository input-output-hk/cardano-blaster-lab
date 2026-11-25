import CardanoLedgerApi.V3
import LiveScripts.S_92e9c9eef30c1ece4635e9b1926f5855855518495cc525fd958c6fe1.Script

open CardanoLedgerApi.V3

/-- Typed context reconstructed from a native Z3 model. -/
def replayContext : ScriptContext := ({
  scriptContextTxInfo :=
    {
      txInfoInputs :=
        [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 5 },
            txInInfoResolved :=
              {
                txOutAddress :=
                  { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "A" },
                    addressStakingCredential :=
                      some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 12 13 14) },
                txOutValue :=
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 30374)]),
                    (PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 14250)])],
                txOutDatum := CardanoLedgerApi.V2.Tx.OutputDatum.OutputDatumHash { data := "" },
                txOutReferenceScript := some { data := "" } } }],
      txInfoReferenceInputs := [], txInfoOutputs := [], txInfoFee := 30374,
      txInfoMint :=
        [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
            PlutusCore.Data.PlutusCore.DataInternal.Data.Map
              [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "A" },
                  PlutusCore.Data.PlutusCore.DataInternal.Data.I (-14250))])],
      txInfoTxCerts := [], txInfoWdrl := [],
      txInfoValidRange :=
        PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
      txInfoSignatories := [],
      txInfoRedeemers :=
        [(Contexts.ScriptPurpose.Minting { data := "A" }, PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [])],
      txInfoData := [], txInfoId := { data := "" }, txInfoVotes := [], txInfoProposalProcedures := [],
      txInfoCurrentTreasuryAmount := PlutusCore.Data.PlutusCore.DataInternal.Data.I 28766,
      txInfoTreasuryDonation := PlutusCore.Data.PlutusCore.DataInternal.Data.I 12797 },
  scriptContextRedeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 [],
  scriptContextScriptInfo := Contexts.ScriptInfo.MintingScript { data := "A" } } : ScriptContext)
