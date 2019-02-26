000235180409     F**************************
000236180409     F*  CUSTOMER18 READ BY NATIVE LANGUAGE (ILE RPG)
000237180409     F*  CONTACTW18 ROW RETRIEVED WITH EMBEDDED SQL
000238180409     F*  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER18 AND CONTACTW18
000239180409     F*  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000240180409     F**************************
000241180409
000242180409     FCUSTOMER18IF   E             DISK    RENAME(CUSTOMER18:CUSTOMERRF)
000243180409     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(30) FORMLEN(66)
000244180409
000245180409     D*  H O S T   V A R I A B L E S
000246180409
000247180409     D ContactW18    E DS
000248180409     D ContactTotal    S              5  0
000249180409     D CustomerTotal   S              5  0
000250180409     D UnknownTotal    S              5  0
000251180409     D OldestDate      S               D
000252180409     D MostRecentDate  S               D
000253180409     D User            S             10
000254180409     D Server          S             10
000255180409     D TimeStamp       S               Z
000256180409     D DateIn          S              5  0
000257180409
000258180409     D*  I N D I C A T O R   V A R I A B L E S
000259180409
000260180409     D INDLASTDATEC    S              4B 0
000261180409
000262180409     D INDNEXTDATEC    S              4B 0
000263180409
000264180409     D Dummy           S              1  0
000265180409     D Flag            S              7
000266180409     D NextCallDate    S               D
000267180409     C/EJECT
000268180409     C**************************
000269180409     C*                        *   M A I N   R O U T I N E   *
000270180409     C**************************
000271180409      /FREE
000272180409                EXSR SummaryInfo;
000273180409                EXCEPT HEADINGS;
000274180409                READ CUSTOMER18;
000275180409                DOW NOT %EOF;
000276180409                    EXSR SQLSelect;
000277180409                    IF *INOF = *ON;
000278180409                       EXCEPT HEADINGS;
000279180409                       *INOF = *OFF;
000280180409                    ENDIF;
000281180409                    EXCEPT DETAIL;
000282180409                   READ CUSTOMER18;
000283180409                ENDDO;
000284180409                EXCEPT TOTALS;
000285180409                *INLR = *ON;
000286180409                RETURN;
000287180409
000288180409
000289180409
000290180409       BEGSR SQLSelect;
000291180409                 EXEC SQL
000292180409                 SELECT PHNLDC + PHNCIT DAYS, PHNLDC, CSTPHN, PHNCOM, CSTSLN
000293180409                 INTO :NextCallDate  :INDNEXTDATEC,  :PHNLDC :INDLASTDATEC,
000294180409                 :CSTPHN, :PHNCOM, :CSTSLN
000295180409                 FROM BCI433LIB/CONTACTW18
000296180409                 WHERE CSTNUM  =: CSTNUM;
000297180409
000298180409       IF IndLastDateC = -1;
000299180409         CSTPHN = 'UNKNOWN DATE';
000300180409         NextCallDate = D'9999-09-09';
000301180409         PHNLDC = D'9999-09-09';
000302180409
000303180409       ELSE;
000304180409         IF IndLastDateC <> 0;
000305180409           CSTPHN ='Date Problem';
000306180409           NextCallDate = D'9999-09-09';
000307180409           PHNLDC = D'9999-09-09';
000308180409
000309180409         ENDIF;
000310180409       ENDIF;
000311180409
000312180409       SELECT;
000313180409         WHEN SQLSTATE = '00000';
000314180409           DUMMY = 0;
000315180409           WHEN SQLSTATE = '02000';
000316180409           CSTPHN = 'NOT FOUND';
000317180409           NextCallDate = D'9999-09-09';
000318180409           PHNLDC = D'9999-09-09';
000319180409           PHNCOM = *ALL'*';
000320180409           CSTSLN = *ALL'*';
000321180409         WHEN %SUBST(SQLSTATE :1 :2) = '01';
000322180409           NextCallDate = D'9999-09-09';
000323180409           PHNLDC =D'9999-09-09';
000324180409           PHNCOM = *ALL'*';
000325180409           CSTSLN = *ALL'*';
000326180409           CSTPHN = *ALL'*';
000327180409
000328180409       OTHER;
000329180409         CSTPHN = *ALL'*';
000330180409         NextCallDate = D'9999-09-09';
000331180409         PHNLDC = D'9999-09-09';
000332180409         PHNCOM = *ALL'*';
000333180409         CSTSLN = *ALL'*';
000334180409       ENDSL;
000335180409        EXEC SQL
000336180409         SELECT MIN(PHNLDC)
000337180409            INTO :OLDESTDATE
000338180409           FROM BCI433LIB/CONTACTW18;
000339180409           IF FLAG = '';
000340180409             IF OLDESTDATE = PHNLDC;
000341180409               FLAG = '<-----';
000342180409             ENDIF;
000343180409           ENDIF;
000344180409           IF FLAG = '<-----';
000345180409             IF NOT (OLDESTDATE = PHNLDC);
000346180409               FLAG = '';
000347180409             ENDIF;
000348180409           ENDIF;
000349180409
000350180409
000351180409       ENDSR;
000352180409
000353180409
000354180409       BEGSR  SummaryInfo;
000355180409
000356180409       EXEC SQL
000357180409         SELECT COUNT(*) INTO : CONTACTTOTAL
000358180409           FROM BCI433LIB/CONTACTW18;
000359180409       IF (SQLCODE <> 0) OR (SQLWN0 ='W');
000360180409         CONTACTTOTAL = -9999;
000361180409       ENDIF;
000362180409
000363180409       EXEC SQL
000364180409         SELECT COUNT(*) INTO : CUSTOMERTOTAL
000365180409           FROM BCI433LIB/CUSTOMER18;
000366180409       IF (SQLCODE <> 0) OR (SQLWN0 ='W');
000367180409         CUSTOMERTOTAL = -9999;
000368180409
000369180409       ENDIF;
000370180409
000371180409       EXEC SQL
000372180409             SELECT COUNT(*)
000373180409               INTO : UNKNOWNTOTAL
000374180409             FROM BCI433LIB/CONTACTW18
000375180409             WHERE CSTLASTCALLDATE IS NULL;
000376180409       IF NOT (SQLCODE = 0) OR (SQLWN0 = 'W');
000377180409             UNKNOWNTOTAL =-9999;
000378180409
000379180409       ENDIF;
000380180409
000381180409
000382180409       EXEC SQL
000383180409         SELECT MIN(PHNLDC)
000384180409            INTO :OLDESTDATE
000385180409           FROM BCI433LIB/CONTACTW18;
000386180409
000387180409           IF (SQLCODE <> 0 ) OR (SQLWN0 = 'W')AND (SQLWN2 <> 'W');
000388180409             OLDESTDATE = D'9999-09-09';
000389180409           ENDIF;
000390180409
000391180409         EXEC SQL
000392180409         SELECT MAX(PHNLDC)
000393180409            INTO :MOSTRECENTDATE
000394180409           FROM BCI433LIB/CONTACTW18;
000395180409           IF (SQLCODE <> 0 ) OR (SQLWN0 = 'W')AND (SQLWN2 <> 'W');
000396180409             MOSTRECENTDATE = D'9999-09-09';
000397180409           ENDIF;
000398180409
000399180409       EXEC SQL
000400180409         SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
000401180409           INTO :USER, :TIMESTAMP, :SERVER
000402180409           FROM SYSIBM/SYSDUMMY1;
000403180409
000404180409
000405180409       ENDSR;
000406180409
000407180409
000408180409      /END-FREE
000409180409     OQPRINT    E            HEADINGS       2 02
000410180409     O                                            5 'USER:'
000411180409     O                       USER                16
000412180409     O                                           28 'TIMESTAMP:'
000413180409     O                       TIMESTAMP           55
000414180409     O                                           64 'SERVER:'
000415180409     O                       SERVER              75
000416180409     O                                           87 'PAGE:'
000417180409     O                       PAGE                90
000418180409     O          E            HEADINGS       2
000419180409     O                                           54 'Phone Log Report'
000420180409     O                       UDATE         Y     89
000421180409     O          E            HEADINGS       1
000422180409     O                                            5 'Sales'
000423180409     O                                           15 'Customer'
000424180409     O                                           31 'Customer Name'
000425180409     O                                           59 'Telephone'
000426180409     O                                           75 'Last Call'
000427180409     O                                           88 'Oldest Call'
000428180409     O                                          101 'Next Call'
000429180409     O          E            HEADINGS       2
000430180409     O                                            3 'ID'
000431180409     O                                           13 'Number'
000432180409     O                                           73 'Date'
000433180409     O                                           85 'Date'
000434180409     O                                           98 'Date'
000435180409     O          E            DETAIL         1
000436180409     O                       CSTSLN               3
000437180409     O                       CSTNUM              13
000438180409     O                       CSTNAM              48
000439180409     O                       CSTPHN              64
000440180409     O                       PHNLDC              75
000441180409     O                       FLAG                86
000442180409     O                       NextCallDate       101
000443180409     O          E            TOTALS      2  2
000444180409     O                                           32 'Summary Information'
000445180409     O          E            TOTALS         1
000446180409     O                                           26 'CONTACTW18 Total Records:'
000447180409     O                       ContactTotal  1     34
000448180409     O          E            TOTALS         1
000449180409     O                                           26 'CUSTOMER18 Total Records:'
000450180409     O                       CustomerTotal 1     34
000451180409     O          E            TOTALS      1  1
000452180409     O                                           27 'Oldest Last Callback Date:'
000453180409     O                       OldestDate          42
000454180409     O          E            TOTALS         1
000455180409     O                                           27 'Most Recent Callback Date:'
000456180409     O                       MostRecentDate      42
000457180409     O          E            TOTALS      2  1
000458180409     O                                           22 'Total Records with an'
000459180409     O                                           47 'Unknown Last Date Called'
000460180409     O                                           62 'in CONTACTW18:'
000461180409     O                       UnknownTotal        70
