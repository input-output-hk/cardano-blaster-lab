import CardanoLedgerApi.V2
import LiveScripts.S_07de5eb4fdb9f6bd23c7bc3c588306f03d46c8c59ee980223132c87e.Script

open CardanoLedgerApi.V2

/-- Typed context reconstructed from a native Z3 model. -/
def replayInput : SpendingInput := ({ datum := PlutusCore.Data.PlutusCore.DataInternal.Data.I 17, redeemer := PlutusCore.Data.PlutusCore.DataInternal.Data.I 133, ctx :=
    {
      scriptContextTxInfo :=
        {
          txInfoInputs :=
            [{ txInInfoOutRef := { txOutRefId := { data := "\x15" }, txOutRefIdx := 5 },
                txInInfoResolved :=
                  {
                    txOutAddress :=
                      {
                        addressCredential :=
                          CardanoLedgerApi.V1.Credential.Credential.ScriptCredential
                            { data := "ì\x15Ã-Ò\x07¢:>I I/üøªEÖx=ê\x18oæ5ï" },
                        addressStakingCredential :=
                          some (CardanoLedgerApi.V1.Credential.StakingCredential.StakingPtr 8 9 10) },
                    txOutValue :=
                      [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                          PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                                PlutusCore.Data.PlutusCore.DataInternal.Data.I 448567)])],
                    txOutDatum := Tx.OutputDatum.OutputDatum (PlutusCore.Data.PlutusCore.DataInternal.Data.I 17),
                    txOutReferenceScript := some { data := ":" } } }],
          txInfoReferenceInputs := [], txInfoOutputs := [],
          txInfoFee :=
            [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                PlutusCore.Data.PlutusCore.DataInternal.Data.Map
                  [(PlutusCore.Data.PlutusCore.DataInternal.Data.B { data := "" },
                      PlutusCore.Data.PlutusCore.DataInternal.Data.I 448567)])],
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
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 []],
                PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0
                  [PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 0 [],
                    PlutusCore.Data.PlutusCore.DataInternal.Data.Constr 1 []]],
          txInfoSignatories := [],
          txInfoRedeemers :=
            [(CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending
                  { txOutRefId := { data := "\x15" }, txOutRefIdx := 5 },
                PlutusCore.Data.PlutusCore.DataInternal.Data.I 133)],
          txInfoData := [], txInfoId := { data := "\x15" } },
      scriptContextPurpose :=
        CardanoLedgerApi.V1.Contexts.ScriptPurpose.Spending { txOutRefId := { data := "\x15" }, txOutRefIdx := 5 } } } : SpendingInput)
