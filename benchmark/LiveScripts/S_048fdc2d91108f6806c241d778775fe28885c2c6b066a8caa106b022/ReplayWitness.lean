import CardanoLedgerApi.V2
import LiveScripts.S_048fdc2d91108f6806c241d778775fe28885c2c6b066a8caa106b022.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : RewardingInput := ({ redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [PlutusCore.Data.PlutusCore.DataInternal.Data.I 0], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 19 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      {
                        addressCredential :=
                          CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                            { data := "Ábªñp9Ë?IÜ×ü]\x02\x0bË\x18ÝvM+!ÝÚ¼" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 34 33 32) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 747369)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 31),
                    txOutReferenceScript := some { data := "I" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 747369)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [],
          txInfoWdrl :=
            [(CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                  (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "b" }),
                22)],
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
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Rewarding
                  (CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                    (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "b" })),
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 0])],
          txInfoData := [], txInfoId := { data := "" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Rewarding
          (CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
            (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "b" })) } } : RewardingInput)
