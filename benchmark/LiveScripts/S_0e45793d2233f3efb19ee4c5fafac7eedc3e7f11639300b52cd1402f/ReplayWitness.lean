import CardanoLedgerApi.V2
import LiveScripts.S_0e45793d2233f3efb19ee4c5fafac7eedc3e7f11639300b52cd1402f.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : RewardingInput := ({ redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 48, ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "É" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.PubKeyCredential { data := "ü" },
                        addressStakingCredential := none },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 778635)])],
                    txOutDatum := Tx.OutputDatum.NoOutputDatum, txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 778635)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [],
          txInfoWdrl :=
            [(CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                  (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x06" }),
                7)],
          txInfoValidRange :=
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
          txInfoSignatories := [{ data := "Év\x18\x02\x06üÂ©,hÒ\x0bÝè\t-_#úa\x19wÐQ" }],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Rewarding
                  (CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                    (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x06" })),
                PlutusCore.Data.PlutusCore.DataInternal.Data.I 48)],
          txInfoData := [], txInfoId := { data := "É" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Rewarding
          (CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
            (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "\x06" })) } } : RewardingInput)
