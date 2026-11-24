import CardanoLedgerApi.V2
import LiveScripts.S_fffee534d121ebcf3085ec2c170c8b98281211c9bc6c2fc7ad351dc4.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({
  datum :=
    PlutusCore.Data.PlutusCore.DataInternal.Data.List
      [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
              [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }]]], redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 15 16 17) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 683248)])],
                    txOutDatum :=
                      Tx.OutputDatum.OutputDatum
                        (PlutusCore.Data.PlutusCore.DataInternal.Data.List
                          [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 8
                              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1
                                  [PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" }]]]),
                    txOutReferenceScript := some { data := "" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 683248)])],
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
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
          txInfoData := [], txInfoId := { data := "" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "" }, txOutRefIdx := 5 } } } : SpendingInput)
