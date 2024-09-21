BEGIN {
    Station = "" ; 
    } 

{ 
    if ($1 == "S") 
        { Station = $2 } 
    else { 
        Jahr = $1 ;
        print ( Station "," Jahr ",1," $2/100 ",0" ) 
        print ( Station "," Jahr ",2," $3/100 ",0" ) 
        print ( Station "," Jahr ",3," $4/100 ",0" ) 
        print ( Station "," Jahr ",4," $5/100 ",0" ) 
        print ( Station "," Jahr ",5," $6/100 ",0" ) 
        print ( Station "," Jahr ",6," $7/100 ",0" ) 
        print ( Station "," Jahr ",7," $8/100 ",0" ) 
        print ( Station "," Jahr ",8," $9/100 ",0" ) 
        print ( Station "," Jahr ",9," $10/100 ",0" ) 
        print ( Station "," Jahr ",10," $11/100 ",0" ) 
        print ( Station "," Jahr ",11," $12/100 ",0" ) 
        print ( Station "," Jahr ",12," $13/100 ",0" ) 
        
    } 
}
