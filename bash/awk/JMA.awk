BEGIN {i=1;j=1;} 
{ 

    if ($1 == "#" ) { 
        Jahr= $2; 
        Monat = $3; 
        i = 1 ;
        j = 1 ; 
    } 
    else {
        lat = 87.5 -  (i -1 ) * 5 ;
        
        for ( j = 1; j < 73 ; j = j + 1 ) {
            lon = ( j -1 ) * 5 + 2.5
            if ( lon > 180 ) { lon = lon - 360 ; } ;
            if ( $j != -9999.00 ) {
                print(Jahr "," Monat "," lat "," lon "," $j );
            }  
        } ;
        i = i + 1 ;
    }       

}
