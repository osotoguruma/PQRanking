let fnGetParameter =
    (
        pTable          as any, 
        pName           as text,
        optional pParam as text,
        optional pVal   as text
    ) =>

    let
        ParamSource = if pTable is text then
                         Excel.CurrentWorkbook(){[Name=pTable]}[Content]
                         else pTable,

        Parametre   = if pParam <> null then 
                         pParam 
                         else "PARAMETRE",

        Valeur      = if pVal <> null then 
                         pVal 
                         else "VALEUR",

        StrParam="each ([" & Parametre & "]) = " & """" & pName & """",
        EvalParam=Expression.Evaluate(StrParam,[ParamSource=ParamSource]),        
        
        ParamRow = Table.SelectRows(ParamSource, EvalParam),
        
        Value= if Table.IsEmpty(ParamRow)=true
                  then null
                  else Record.Field(ParamRow{0},Valeur)
    in
        Value
in 
    fnGetParameter