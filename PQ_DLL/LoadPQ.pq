(
    pCodeName            as text,  // Nom du module à charger
    optional pExtension  as text,  // Extension du module (.pq par défaut)
    optional pFolder     as text   // Dossier où est stocké le module
) as any =>

let
    //---------------------------------------------------------------------------
    // Construction du nom du module à charger
    // Il est chargé et renvoyé en tant que fonction pour être exécuté
    //---------------------------------------------------------------------------
    ParamPathDefaut  = fnGetParameter("TB_PARAMS", "DOSSIER_DLL"),
    ParamExtDefaut   = fnGetParameter("TB_PARAMS", "EXTENSION_DLL"),
    ParamFolderPQ_DLL= fnGetParameter("TB_PARAMS", "SOUS_DOSSIER_DLL"),
    
    DEFAULT = ParamPathDefaut & "\" & ParamFolderPQ_DLL,
    BACK_SLASH="\",
    Extension =  if pExtension is null then 
                    if ParamExtDefaut is null then 
                       ".pq" else 
                       ParamExtDefaut
                    else pExtension,
                    
    PathInitial = if (pFolder <> null) then pFolder else DEFAULT,
    PathProcedure = PathInitial & (if Text.End(PathInitial, 1) <> BACK_SLASH then BACK_SLASH else ""),
    FileProcedure = PathProcedure & pCodeName & Extension,
    
    //---------------------------------------------------------------------------
    // Chargement du module en mémoire dans le contexte PowerQuery
    //---------------------------------------------------------------------------
    ReturnFunction = 
            try
                //-----------------------------------------------------------------------------------                
                // Si la fonction existe on la reprend tel quel 
                // Astuce on lance un code bidon afin de voir si ça plante ou pas
                // Si ça ne plante pas alors le module est bien chargé en mémoire par #shared
                // Cas en fait si la requête est présente dans l'espace powerquery
                // sinon on va le charger à partir du disque
                //----------------------------------------------------------------------------------
                Expression.Evaluate(Text.Replace(pCodeName, ".", "_"), #shared)
	            otherwise 
                   // try 
                        //---------------------------------------------------------------------
                        // Si la fonction n'est pas dans le contexte PowerQuery on la charge
                        // #shared permet de l'ajouter au contexte d'exécution de powerquery
                        //--------------------------------------------------------------------
                        Expression.Evaluate(Text.FromBinary(Binary.Buffer(File.Contents(FileProcedure))), #shared)
                        // Dans la négative on ne lance aucun traitement
	            //    otherwise 
                //        "Err"
in
	//FileProcedure
    //ParamPathDefaut
    ReturnFunction
    //Expression.Evaluate(Text.Replace(pCodeName, ".", "_"), #shared)
     //Expression.Evaluate(Text.FromBinary(Binary.Buffer(File.Contents(FileProcedure))), #shared)