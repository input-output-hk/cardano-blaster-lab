import CardanoLedgerApi.V2
import LiveScripts.S_7bb08afe982c7a9ef54f0ab7d2de48d80d27b9650fb1d7083ddf2d7b.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : RewardingInput := ({ redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [PlutusCore.Data.PlutusCore.DataInternal.Data.I 0], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 19 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      {
                        addressCredential :=
                          CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                            { data := "ÚÐßHþfùx[2s!«µ\x0b#Ô³{Ä%\x05\x04c+å" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 29 30 31) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 316514)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 32),
                    txOutReferenceScript := some { data := "2" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 316514)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [],
          txInfoWdrl :=
            [(CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                  (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "Ð" }),
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
                    (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "Ð" })),
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 0])],
          txInfoData := [], txInfoId := { data := "ÚÐßHþfùx[2s!«µ\x0b#Ô³{Ä%\x05\x04c+å" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Rewarding
          (CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
            (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "Ð" })) } } : RewardingInput)
