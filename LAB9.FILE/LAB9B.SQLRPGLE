000100180405     F************************************************************************************     F* TH
000101180405     F* ORDERLINE, CUSTOMER, PART AND SALESREP TABLES.  ORDER NUMBER IS USED AS A CONTROL*
000102180405     F* BREAK FIELD WHERE CUSTOMER TOTALS ARE PRINTED ON NEW ORDER NUMBERS               *
000103180405
000104180405     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(60) FORMLEN(66)
000105180405     D CustomerRecord  DS
000106180405     D CustId                         6
000107180405     D FullName                      31
000108180405     D City                          20
000109180405     D Purchase                       7  2
000110180405     D PDate                           D
000111180405     D Province                      10
000112180405     D ProvinceH       S             10
000113180405     D TotalCost       S              8  2
000114180405     D TotalRecords    S              5  0
000115180405     D TotalExtended   S              9  2
000116180405     D OntarioTot      S              3  0
000117180405     D QuebecTot       S              3  0
000118180405     D ManitobaTot     S              3  0
000119180405     D EndOfFile       S               N
000120180405     C/EJECT
000121180405     C************************************************************************************
000122180405     C*                        ***   M A I N   R O U T I N E   ***                       *
000123180405     C************************************************************************************
000124180405      /FREE
000125180405                EXSR PrepareFiles;
000126180405                EXCEPT HEADINGS;
000127180405                EXSR GetRow;
000128180405                Except NewProv;
000129180405                ProvinceH = Province;
000130180405                DOW NOT EndOfFile;
000131180405                    IF *INOF = *ON;
000132180405                        EXCEPT HEADINGS;
000133180405                       *INOF = *OFF;
000134180405                    ENDIF;
000135180405                    If ProvinceH = Province;
000136180405                       Except Detail;
000137180405                    Else;
000138180405                       ProvinceH = Province;
000139180405                       Except NewProv;
000140180405                       Except Detail;
000141180405                    EndIf;
000142180405                    TotalCost     = TotalCost     + Purchase;
000143180405                    TotalRecords= TotalRecords + 1;
000144180405                    EXSR GetRow;
000145180405                ENDDO;
000146180405                EXSR   WRAPUP;
000147180405                EXCEPT Totals;
000148180405                *INLR = *ON;
000149180405                RETURN;
000150180405
000151180405 
000152180405        // O P E N F I L E S   S U B R O U T I N E
000153180405
000154180405         BEGSR  PrepareFiles;
000155180405        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
000156180405        EXEC SQL
000157180405            Declare ALLPROVCURSOR CURSOR
000158180405            for
000159180405              select custid, trim(Fname)|| ' ' || trim(Lname),
000160180405                     city, purchase, pdate,
000161180405                     'Ontario' as Povince
000162180405              from BCI433LIB/ONTARIO
000163180405              where purchase > 150
000164180409              UNION ALL
000165180405              select custid, trim(Fname)|| ' ' || trim(Lname),
000166180405                     city, purchase, pdate,
000167180405                     'Quebec' as Povince
000168180405              from BCI433LIB/QUEBEC
000169180405              where purchase > 150
000170180405              UNION ALL
000171180405              select custid, trim(Fname)|| ' ' || trim(Lname),
000172180405                     city, purchase, pdate,
000173180405                     'Manitoba' as Povince
000174180405              from BCI433LIB/MANITOBA
000175180405              where purchase > 150
000176180405              FOR READ ONLY;
000177180405
000190180405        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
000191180405        EXEC SQL
000192180405            OPEN ALLPROVCURSOR;
000193180405
000194180405             if sqlcode <> 0 OR SQLWN0 = 'W';
000195180405                    EndOfFile = *ON;
000196180405                  ENDIF;
000201180405            ENDSR;
000202180405
000203180405        //   G E T     R O W    S U B R O U T I N E
000204180405
000205180405            BEGSR     GETROW;
000206180405             EXEC SQL
000207180405               FETCH NEXT
000208180405                 FROM ALLPPROVCURSOR
000209180405                 INTO CustomerRecord;
000210180405
000211180405                  if sqlcode<>0 OR SQLWN0 = 'W';
000212180405                    EndOfFile = *ON;
000213180405                  ENDIF;
000214180405             ENDSR;
000215180405
000218180405        // W R A P U P     S U B R O U T I N E
000219180405
000220180405           BEGSR WRAPUP;
000221180405           EXEC SQL
000222180405             CLOSE ALLPROVCURSOR;
000223180405
000224180405              if sqlcode<>0 OR SQLWN0 = 'W';
000225180405                    EndOfFile = *ON;
000226180405                  ENDIF;
000227180405
000228180405           EXEC SQL
000229180405             SELECT COUNT(*) INTO :OntarioTot
000230180405               from BCI433LIB/ONTARIO
000231180405               Where Purchase <= 150;
000232180405
000233180405                if sqlcode<>0 OR SQLWN0 = 'W';
000234180405                    OntarioTot = -999;
000235180405                  ENDIF;
000236180409            EXEC SQL
000237180409              SELECT COUNT(*) INTO :QuebecTot
000238180409               from BCI433LIB/QUEBEC
000239180409               Where Purchase <= 150;
000240180409
000241180409                if sqlcode<>0 OR SQLWN0 = 'W';
000242180409                    QuebecTot = -999;
000243180409                  ENDIF;
000244180409            EXEC SQL
000245180409               SELECT COUNT(*) INTO :ManitobaTot
000246180409               from BCI433LIB/MANITOBA
000247180409               Where Purchase <= 150;
000248180409
000249180409                if sqlcode<>0 OR SQLWN0 = 'W';
000250180409                    ManitobaTot = -999;
000251180409                  ENDIF;
000252180405
000285180405
000286180405          ENDSR;
000287180405      /END-FREE
000288180405
000289180405     OQPRINT    E            HEADINGS       2 02
000290180405     O                                           67 'Customers > $150.00'
000291180405     O                                          110 'Page:'
000292180405     O                       PAGE               115
000293180405     O          E            HEADINGS       1
000294180405     O                                            8 'Province'
000295180405     O                                           23 'Customer ID'
000296180405     O                                           42 'Full Name'
000297180405     O                                           64 'City'
000298180405     O                                           90 'Purchase'
000299180405     O                                          101 'Purchase'
000300180405     O          E            HEADINGS       2
000301180405     O                                           89 'Amount'
000302180405     O                                           99 'Date'
000303180405     o          E            NewProv        1
000304180405     O                       Province            10
000305180405     o          E            DETAIL         1
000306180405     O                       CustID              20
000307180405     O                       FullName            61
000308180405     O                       City                74
000309180405     O                       Purchase      1     90
000310180405     O                       PDate              103
000311180405     O          E            Totals      2  1
000312180405     O                                           79 'Total Amount:'
000313180405     O                       TotalCost     1     90
000314180405     O          E            Totals      1  1
000315180405     O                                           17 'Total Customers:'
000316180405     O                       TotalRecords  1     24
000317180405     O          E            TOTALS         2 02
000318180405     O                                           67 'Customers <= $150.00'
000319180405     O                                          110 'Page:'
000320180405     O                       PAGE               115
000321180405     O          E            Totals         2
000322180405     O                                           18 'Ontario'
000323180405     O                                           41 'Quebec'
000324180405     O                                           69 'Manitoba'
000325180405     O          E            Totals         1
000326180405     O                       OntarioTot    1     15
000327180405     O                       QuebecTot     1     38
000328180405     O                       ManitobaTot   1     66
000329180405
