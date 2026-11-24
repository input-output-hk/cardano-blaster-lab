import CardanoLedgerApi.V2
import LiveScripts.S_51ded1374aa111991a755ee426baab8fed0de6831e7c757b269ebee9.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({ datum := PlutusCore.Data.PlutusCore.DataInternal.Data.I 17, redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 97, ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "R" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      {
                        addressCredential :=
                          CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                            { data := "RMèeÄ¨;×C\x10W['ôkµm*\x0c\x00\x0e¤%u1ý" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 9 10 11) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 565203)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 17),
                    txOutReferenceScript := some { data := "×" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 565203)])],
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
          txInfoSignatories := [],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "R" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.I 97)],
          txInfoData := [], txInfoId := { data := "R" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "R" }, txOutRefIdx := 5 } } } : SpendingInput)
