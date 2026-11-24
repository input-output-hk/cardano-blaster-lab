import CardanoLedgerApi.V2
import LiveScripts.S_9fb4b54c367463bd3da3d2e8aa9357133ef7b489adb1cf9cb2e8dd70.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({ datum := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22, redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "è" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := " " },
                        addressStakingCredential := none },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 274657)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 22),
                    txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 274657)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [],
          txInfoWdrl :=
            [(CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                  (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                    { data := "èà1 ~ûk´ÇòÒùQ\x1a5ErfÍå7\x07û\x7fñ\x0e" }),
                7)],
          txInfoValidRange :=
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []]],
          txInfoSignatories := [],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "è" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
          txInfoData := [], txInfoId := { data := "è" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "è" }, txOutRefIdx := 5 } } } : SpendingInput)
