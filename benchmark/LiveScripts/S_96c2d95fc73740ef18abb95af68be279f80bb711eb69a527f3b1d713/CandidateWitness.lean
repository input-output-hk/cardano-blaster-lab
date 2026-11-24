import CardanoLedgerApi.V2
import LiveScripts.S_96c2d95fc73740ef18abb95af68be279f80bb711eb69a527f3b1d713.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({ datum := PlutusCore.Data.PlutusCore.DataInternal.Data.I 22, redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "ù" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "©" },
                        addressStakingCredential := none },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 24476)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 22),
                    txOutReferenceScript := none } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 24476)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [],
          txInfoWdrl :=
            [(CardanoLedgerApi.V1.Credential.StakingCredential.StakingHash
                  (CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                    { data := "Mù©bQ¹ã%FèjçõÐë
99ÈNe\\c|U" }),
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
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "ù" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
          txInfoData := [], txInfoId := { data := "ù" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "ù" }, txOutRefIdx := 5 } } } : SpendingInput)
