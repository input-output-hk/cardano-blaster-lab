import CardanoLedgerApi.V2
import LiveScripts.S_b0ebdd68bd00f3a633c5097fe0243d69fb27abacd7f6959bec63c4c4.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({
  datum :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
      [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "B\x07û\x14l·ÉÉ6K\x1c\x0bÓYÊ\x03Z_É÷T.?´" }], redeemer :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
      [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "withdraw" }], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "B" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                        addressStakingCredential := none },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 492029)])],
                    txOutDatum :=
                      Tx.OutputDatum.OutputDatum
                        (PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                          [PlutusCore.Data.PlutusCore.DataInternal.Data.B
                              { data := "B\x07û\x14l·ÉÉ6K\x1c\x0bÓYÊ\x03Z_É÷T.?´" }]),
                    txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 492029)])],
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
          txInfoSignatories := [{ data := "B\x07û\x14l·ÉÉ6K\x1c\x0bÓYÊ\x03Z_É÷T.?´" }],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "B" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "withdraw" }])],
          txInfoData := [], txInfoId := { data := "B" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "B" }, txOutRefIdx := 5 } } } : SpendingInput)
