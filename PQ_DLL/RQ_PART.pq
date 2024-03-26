let 
    fnExpandTableRanking = (
            pTable                       as any,
            pFieldAscending              as text,
            pFieldDescending             as text,
            optional ppFieldIndex        as text 
        ) => 

        let
            
            pFieldData="Data",            
            pFieldPartioned="Partitioned",

            pFieldIndex=if ppFieldIndex is null then 
                           "Index" 
                           else ppFieldIndex,

            Source = Table.Buffer(if pTable is table then 
                        pTable 
                        else Excel.CurrentWorkbook(){[Name=pTable]}[Content]),

            ChangedType = Table.TransformColumnTypes(Source,{{pFieldAscending, type text}, {pFieldDescending, type number}}),

            
            SortedRows =  Table.Sort(ChangedType,{   
                                                {pFieldAscending, Order.Ascending},
                                                {pFieldDescending, Order.Descending}                                                
                                            }
                                        ),

            GroupedRows = Table.Group(SortedRows, {pFieldAscending}, {{pFieldData, each _, type table}}),                      
            AddedCustom = Table.AddColumn(GroupedRows, pFieldPartioned, each Table.AddIndexColumn([Data], pFieldIndex, 1, 1)),
            RemovedColumns = Table.RemoveColumns(AddedCustom,{pFieldData}),
            DrillDownPartioned=Table.Column(RemovedColumns,pFieldPartioned),
            ListColumnsFromTableFirstRow=Table.ColumnNames(DrillDownPartioned{0}),
            DeleteFieldAscending=  List.RemoveMatchingItems(ListColumnsFromTableFirstRow,{pFieldAscending}),
            ExpandToTable = Table.ExpandTableColumn(RemovedColumns, pFieldPartioned, DeleteFieldAscending, DeleteFieldAscending),
            TransformType=LoadPQ("fnTransformTypes"),
            ToTable=Table.TransformColumnTypes(ExpandToTable,TransformType("TB_TYPES"))
        in
            ToTable
in 
    fnExpandTableRanking

