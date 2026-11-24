import CardanoLedgerApi.V2
import LiveScripts.S_64e5f6469ae338667af6c9400c6a14b199fd48eb5c130271969dbda5.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({ datum := PlutusCore.Data.PlutusCore.DataInternal.Data.I 7, redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [], ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "i" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      { addressCredential := CardanoLedgerApi.V1.Credential.Credential.ScriptCredential { data := "³" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 10 9 8) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 381078)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 7),
                    txOutReferenceScript := some { data := "" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 381078)])],
          txInfoMint :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 0)])],
          txInfoDCert := [], txInfoWdrl := [],
          txInfoValidRange :=
            PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
              [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
          txInfoSignatories := [{ data := "³=ái!m^Àµä·øÝ;píÏuàgÉÞ5Jü" }],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "i" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [])],
          txInfoData := [], txInfoId := { data := "i" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "i" }, txOutRefIdx := 5 } } } : SpendingInput)
