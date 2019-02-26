000100180409     F************************************************************************************     ,
000101180409     F* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE THAT JOINS THE ORDERS
000102180409     F*F* ORDERLINE, CUSTOMER, PART AND SALESREP TABLES.  ORDER NUMBER IS USED AS A CONTROL*
000103180409     F* BREAK FIELD WHERE CUSTOMER TOTALS ARE PRINTED ON NEW ORDER NUMBERS               *
000104180409     F************************************************************************************
000105180409
000106180409     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(60) FORMLEN(66)
000107180409     D CustomerRecord  DS
000108180409     D CustId                         6
000109180409     D FullName                      31
000110180409     D City                          20
000111180409     D Purchase                       7  2
000112180409     D PDate                           D
000113180409     D Province                      10
000114180409     D ProvinceH       S             10
000115180409
000116180409
000117180409     D TotalCost       S              8  2
000118180409     D TotalRecords    S              5  0
000119180409     D TotalExtended   S              9  2
000120180409     D OntarioTot      S              3  0
000121180409     D QuebecTot       S              3  0
000122180409     D ManitobaTot     S              3  0
000123180409     D EndOfFile       S               N
000124180409     C/EJECT
000125180409     C************************************************************************************
000126180409     C*                        ***   M A I N   R O U T I N E   ***                       *
000127180409     C************************************************************************************
000128180409      /FREE
000129180409                EXSR PrepareFiles;
000130180409                EXCEPT HEADINGS;
000131180409                EXSR GetRow;
000132180409                Except NewProv;
000133180409                ProvinceH = Province;
000134180409                DOW NOT EndOfFile;
000135180409                    IF *INOF = *ON;
000136180409                        EXCEPT HEADINGS;
000137180409                       *INOF = *OFF;
000138180409                    ENDIF;
000139180409                    If ProvinceH = Province;
000140180409                       Except Detail;
000141180409                    Else;
000142180409                       ProvinceH = Province;
000143180409                       Except NewProv;
000144180409                       Except Detail;
000145180409                    EndIf;
000146180409                    TotalCost     = TotalCost     + Purchase;
000147180409                    TotalRecords= TotalRecords + 1;
000148180409                    EXSR GetRow;
000149180409                ENDDO;
000150180409                EXSR WRAPUP;
000151180409                EXCEPT Totals;
000152180409                *INLR = *ON;
000153180409                RETURN;
000154180409
000155180409
000156180409        // O P E N F I L E S   S U B R O U T I N E
000157180409
000158180409           BEGSR  PrepareFiles;
000159180409        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  S T R U C T U R E
000160180409           EXEC SQL
000161180409             DECLARE ALLPROVCURSOR CURSOR
000162180409             FOR
000163180409             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000164180409                    CITY, PURCHASE, PDATE, 'Ontario' AS PROVINCE
000165180409             FROM BCI433LIB/ONTARIO
000166180409             WHERE PURCHASE > 150
000167180409             UNION ALL
000168180409             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000169180409                    CITY, PURCHASE, PDATE, 'Quebec' AS PROVINCE
000170180409             FROM BCI433LIB/QUEBEC
000171180409             WHERE PURCHASE > 150
000172180409             UNION ALL
000173180409             SELECT CUSTID, TRIM(FNAME)|| ' ' || TRIM(LNAME),
000174180409                    CITY, PURCHASE, PDATE, 'Manitoba' AS PROVINCE
000175180409             FROM BCI433LIB/MANITOBA
000176180409             WHERE PURCHASE > 150
000177180409             FOR READ ONLY;
000178180409
000179180409        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
000180180409           EXEC SQL
000181180409             OPEN ALLPROVCURSOR;
000182180409             IF SQLCODE <> 0 OR SQLWN0 = 'W';
000183180409                ENDOFFILE = *ON;
000184180409             ENDIF;
000185180409
000186180409            ENDSR;
000187180409
000188180409
000189180409       BEGSR GETROW;
000190180409
000191180409          EXEC SQL
000192180409            FETCH NEXT
000193180409             FROM ALLPROVCURSOR
000194180409             INTO :CustomerRecord;
000195180409           IF SQLCODE <> 0 OR SQLWN0 ='W';
000196180409            EndOfFile = *on;
000197180409           ENDIF;
000198180409
000199180409       ENDSR;
000200180409
000201180409
000202180409
000203180409        // W R A P U P     S U B R O U T I N E
000204180409
000205180409       BEGSR WRAPUP;
000206180409           EXEC SQL
000207180409             CLOSE ALLPROVCURSOR;
000208180409              IF SQLCODE <> 0 OR SQLWN0 ='W';
000209180409                EndOfFile = *ON;
000210180409             ENDIF;
000211180409
000212180409           EXEC SQL
000213180409
000214180409              SELECT COUNT(*) INTO :OntarioTot
000215180409              FROM BCI433LIB/ONTARIO
000216180409              WHERE  PURCHASE <= 150;
000217180409             IF SQLCODE <> 0 OR SQLWN0 ='W';
000218180409              OntarioTot = -999;
000219180409             ENDIF;
000220180409
000221180409           EXEC SQL
000222180409
000223180409              SELECT COUNT(*) INTO :QuebecTot
000224180409              FROM BCI433LIB/QUEBEC
000225180409              WHERE  PURCHASE <= 150;
000226180409              IF SQLCODE <> 0 OR SQLWN0 ='W';
000227180409               QuebecTot = -999;
000228180409              ENDIF;
000229180409
000230180409           EXEC SQL
000231180409
000232180409             SELECT COUNT(*) INTO :ManitobaTot
000233180409             FROM BCI433LIB/MANITOBA
000234180409             WHERE  PURCHASE <= 150;
000235180409            IF SQLCODE <> 0 OR SQLWN0 ='W';
000236180409              ManitobaTot = -999;
000237180409            ENDIF;
000238180409
000239180409       ENDSR;
000240180409      /END-FREE
000241180409
000242180409     OQPRINT    E            HEADINGS       2 02
000243180409     O                                           67 'Customers > $150.00'
000244180409     O                                          110 'Page:'
000245180409     O                       PAGE               115
000246180409     O          E            HEADINGS       1
000247180409     O                                            8 'Province'
000248180409     O                                           23 'Customer ID'
000249180409     O                                           42 'Full Name'
000250180409     O                                           64 'City'
000251180409     O                                           90 'Purchase'
000252180409     O                                          101 'Purchase'
000253180409     O          E            HEADINGS       2
000254180409     O                                           89 'Amount'
000255180409     O                                           99 'Date'
000256180409     o          E            NewProv        1
000257180409     O                       Province            10
000258180409     o          E            DETAIL         1
000259180409     O                       CustID              20
000260180409     O                       FullName            61
000261180409     O                       City                74
000262180409     O                       Purchase      1     90
000263180409     O                       PDate              103
000264180409     O          E            Totals      2  1
000265180409     O                                           79 'Total Amount:'
000266180409     O                       TotalCost     1     90
000267180409     O          E            Totals      1  1
000268180409     O                                           17 'Total Customers:'
000269180409     O                       TotalRecords  1     24
000270180409     O          E            TOTALS         2 02
000271180409     O                                           67 'Customers <= $150.00'
000272180409     O                                          110 'Page:'
000273180409     O                       PAGE               115
000274180409     O          E            Totals         2
000275180409     O                                           18 'Ontario'
000276180409     O                                           41 'Quebec'
000277180409     O                                           69 'Manitoba'
000278180409     O          E            Totals         1
000279180409     O                       OntarioTot    1     15
000280180409     O                       QuebecTot     1     38
000281180409     O                       ManitobaTot   1     66
000282180409
000283180409
000284180405
000285180409
