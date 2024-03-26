let
    //----------------------------------------------------------------------------------------------
    // La fonction attend la table des types pour chaque colonne
    // La table passée en paramètre peut être soit de type text soit de type table
    //----------------------------------------------------------------------------------------------

    fnTransformTypes=(pTable as any) as list =>
    let
        //------------------------------------------------------------------------------------------
        // On évalue le type de paramètre table
        //------------------------------------------------------------------------------------------
        Source= if pTable is text 
                then Excel.CurrentWorkbook(){[Name=pTable]}[Content]
                else if pTable is table then pTable else null,
                
        //-----------------------------------------------------------------------------------------------
        // La table des types doit comporter deux colonnes
        // colonne 1 : nom de la colonne à transformer
        // colonne 2 : type de la colonne
        // les noms des colonnes ne sont pas imposés puisque la fonction les détecte à la ligne suivante
        //------------------------------------------------------------------------------------------------
        LstCol=Table.ColumnNames(Source),   

        //------------------------------------------------------------------------------------------
        // Les noms des colonnes sont récupérés dans la variable de liste LstCol
        // LstCol{0} = colonne 1 - nom des colonnes
        // LstCol{0} = colonne 2 - types de colonnes
        //------------------------------------------------------------------------------------------
        ChangeColTypes = Table.TransformColumnTypes(Source,{{LstCol{0}, type text}, {LstCol{1}, type text}}),            

        //------------------------------------------------------------------------------------------
        // On prend aussi en compte les types non primitifs
        // [Currency.Type=Currency.Type, Int64.Type=Int64.Type, Percentage.Type=Percentage.Type]
        // Astuce importante : 
        //     Il est nécessaire de les déclarer afin qu'ils soient reconnus dans le contexte PQ
        //------------------------------------------------------------------------------------------
        ToType = Table.TransformColumns(ChangeColTypes,{{LstCol{1}, each Expression.Evaluate(_, [Currency.Type=Currency.Type, Int64.Type=Int64.Type, Percentage.Type=Percentage.Type])}}),
        ToField = Table.AddColumn(ToType, "CustomTypes", each Record.FieldValues(_)),

        //------------------------------------------------------------------------------------------
        // Création de la liste des types à appliquer à chaque colonne
        //------------------------------------------------------------------------------------------
        RemoveOtherCols = Table.SelectColumns(ToField,{"CustomTypes"}),
        ToList = RemoveOtherCols[CustomTypes]
    in
        try ToList otherwise null

in 
    try fnTransformTypes otherwise null