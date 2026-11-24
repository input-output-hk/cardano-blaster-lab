import CardanoLedgerApi.V2
import LiveScripts.S_5a04e05f6fd8b6e03c19619417abfec145b44f237d58bed30dc9f694.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({
  datum :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 32, PlutusCore.Data.PlutusCore.DataInternal.Data.I 31,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 30, PlutusCore.Data.PlutusCore.DataInternal.Data.I 29,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 28,
        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "𠀀" }], redeemer :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 27, PlutusCore.Data.PlutusCore.DataInternal.Data.I 26,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 25, PlutusCore.Data.PlutusCore.DataInternal.Data.I 10], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                        addressStakingCredential := none },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 529873)])],
                    txOutDatum :=
                      Tx.OutputDatum.OutputDatum
                        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
                          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 32,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 31,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 30,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 29,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 28,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "𠀀" }]),
                    txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 529873)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [], txInfoWdrl := [],
          txInfoValidRange :=
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 2 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
          txInfoSignatories := [{ data := "𠀀" }],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 27, PlutusCore.Data.PlutusCore.DataInternal.Data.I 26,
                    PlutusCore.Data.PlutusCore.DataInternal.Data.I 25,
                    PlutusCore.Data.PlutusCore.DataInternal.Data.I 10])],
          txInfoData := [], txInfoId := { data := "" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 } } } : SpendingInput)
