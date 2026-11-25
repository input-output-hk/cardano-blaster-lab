import CardanoLedgerApi.V2
import LiveScripts.S_87f504b07add9e1d74ae102f53ab7f9ff2456dee897a43d8e27b348b.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({
  datum :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 26, PlutusCore.Data.PlutusCore.DataInternal.Data.I 25,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 24, PlutusCore.Data.PlutusCore.DataInternal.Data.I 23,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 22,
        PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }], redeemer :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
      [PlutusCore.Data.PlutusCore.DataInternal.Data.I 21, PlutusCore.Data.PlutusCore.DataInternal.Data.I 20,
        PlutusCore.Data.PlutusCore.DataInternal.Data.I 19, PlutusCore.Data.PlutusCore.DataInternal.Data.I 10], ctx :=
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
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 421753)])],
                    txOutDatum :=
                      Tx.OutputDatum.OutputDatum
                        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
                          [PlutusCore.Data.PlutusCore.DataInternal.Data.I 26,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 25,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 24,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 23,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.I 22,
                            PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }]),
                    txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 421753)])],
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
          txInfoSignatories := [{ data := "" }],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 9
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.I 21, PlutusCore.Data.PlutusCore.DataInternal.Data.I 20,
                    PlutusCore.Data.PlutusCore.DataInternal.Data.I 19,
                    PlutusCore.Data.PlutusCore.DataInternal.Data.I 10])],
          txInfoData := [], txInfoId := { data := "" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 } } } : SpendingInput)
