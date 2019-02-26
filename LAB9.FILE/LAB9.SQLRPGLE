000100180405     F**************************************************************************
000101180405     F*  CUSTOMER18 READ BY NATIVE LANGUAGE (ILE RPG)
000102180405     F*  CONTACTW18 ROW RETRIEVED WITH EMBEDDED SQL
000103180405     F*  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER18 AND CONTACTW18
000104180405     F*  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000105180405     F**************************************************************************
000106180405
000107180405     FCUSTOMER18IF   E             DISK    RENAME(CUSTOMER18:CUSTOMERRF)
000108180405     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(30) FORMLEN(66)
000109180405
000110180405     D*  H O S T   V A R I A B L E S
000111180405
000112180405     D CONTACTW18    E DS
000113180405     D ContactTotal    S              5  0
000114180405     D CustomerTotal   S              5  0
000115180405     D UnknownTotal    S              5  0
000116180405     D OldestDate      S               D
000117180405     D MostRecentDate  S               D
000118180405     D User            S             10
000119180405     D Server          S             10
000120180405     D TimeStamp       S               Z
000121180405     D DateIn          S              5  0
000122180405
000123180405     D*  I N D I C A T O R   V A R I A B L E S
000124180405
000125180405     D IndLastDateC    S              4B 0
000126180405
000127180405     D IndNextDateC    S              4B 0
000128180405
000129180405     D Dummy           S              1  0
000130180405     D Flag            S              7
000131180405       //D/EJECT
000132180405     D NextCallDate    S               D
000186180405     C/EJECT
000187180405     C**************************************************************************
000188180405     C*                        ***   M A I N   R O U T I N E   ***
000189180405     C**************************************************************************
000190180405      /FREE
000191180405                EXSR SummaryInfo;
000192180405                EXCEPT HEADINGS;
000193180405                READ CUSTOMER18;
000194180405                DOW NOT %EOF;
000195180405                    EXSR SQLSelect;
000196180405                    IF *INOF = *ON;
000197180405                       EXCEPT HEADINGS;
000198180405                       *INOF = *OFF;
000199180405                    ENDIF;
000200180405                    EXCEPT DETAIL;
000201180405                   READ CUSTOMER18;
000202180405                ENDDO;
000203180405                EXCEPT TOTALS;
000204180405                *INLR = *ON;
000205180405                RETURN;
000206180405 
000207180405         //*************************************************************************
000208180405         //   S Q L S E L E C T   S U B R O U T I N E
000209180405         //********************************************************************
000210180405         // A row from the contacts table has the same customer number found in the record
000211180405        // read from the CUSTOMER18 file. That row is retrieved to find out the last date
000212180405       // called, phone number, comments and the salesperson number.
000213180405
000214180405       //  The call back interval is added to the last date called to determine the
000215180405       //  next date to call.  Since null values may be stored in the last date called
000216180405       // indicator variables are used.
000217180405                BEGSR  SqlSelect;
000218180405       EXEC SQL
000219180405         SELECT PHNLDC + PHNCIT DAYS,
000220180405          PHNLDC,CSTPHN , PHNCOM,CSTSLN
000221180405          INTO : NextCallDate : IndNextDateC, : PHNLDC : IndLastDateC,
000222180405          : CSTPHN, : PHNCOM, : CSTSLN
000224180405          from BCI433LIB/CONTACTW18
000225180405          where CSTNUM = :CSTNUM;
000226180405        if IndLastDateC =-1;
000227180405          CSTPHN='unknown date';
000228180405          NextCallDate=D'9999-09-09';
000229180405          PHNLDC = D'9999-09-09';
000230180405        else;
000231180405          if IndLastDateC <> 0;
000232180405            CSTPHN='Date Problem';
000233180405            NextCallDate=D'9999-09-09';
000234180405            PHNLDC = D'9999-09-09';
000235180405          ENDIF;
000236180405        ENDIF;
000237180405        select;
000238180405          when sqlstate= '00000';
000239180405            dummy=0;
000240180405          when sqlstate= '02000';
000241180405            cstphn='Not Found';
000242180405            NextCallDate=D'9999-09-09';
000243180405            phnldc=D'9999-09-09';
000244180405            phncom=*ALL'*' ;
000245180405            cstsln=*ALL'*' ;
000246180405          when %subst(sqlstate :1 :2) ='01';
000247180405            cstphn=*ALL'*';
000248180405            NextCallDate=D'9999-09-09';
000249180405            phnldc=D'9999-09-09';
000250180405            phncom=*ALL'*' ;
000251180405            cstsln=*ALL'*' ;
000252180405          other;
000253180405            cstphn=*ALL'*';
000254180405            NextCallDate=D'9999-09-09';
000255180405            phnldc=D'9999-09-09';
000256180405            phncom=*ALL'*' ;
000257180405            cstsln=*ALL'*' ;
000258180405        ENDSL;
000259180405
000260180405       ENDSR;
000261180405 
000262180405
000263180405        //**********************************************************************
000264180405        // S U M M A R Y I N F O   S U B R O U T I N E
000265180405        //**********************************************************************
000266180405       BEGSR  SummaryInfo;
000267180405        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW18 & CUSTOMER18
000268180405          EXEC SQL
000269180409          SELECT COUNT(*) into : ContactTotal
000270180409          FROM BCI433LIB/CONTACTW18;
000271180409          if (sqlcode <> 0) or (SQLWN0='W');
000272180409            ContactTotal=-99999;
000273180409          endif;
000275180405
000276180405        EXEC SQL
000277180405          SELECT COUNT(*) into : CustomerTotal
000278180405          FROM BCI433LIB/CUSTOMER18;
000279180405          if (sqlcode <> 0) or (SQLWN0='W');
000280180405            CustomerTotal=-99999;
000281180405          endif;
000282180405        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   L A S T   D A T E
000283180405        //  C A L L E D   R E C O R D S
000284180405        EXEC SQL
000285180405        select count(*)
000286180405        into: unknowntotal
000287180405        from BCI433LIB/CONTACTW18
000288180405        where cstlastcalldate is null;
000289180405
000290180405        if (sqlcode = 0) or (SQLWN0='W');
000291180405          contacttotal=unknowntotal;
000292180405        ENDIF;
000293180409
000303180405        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
000304180405        //   C A L L B A C K   D A T E S
000305180405        EXEC SQL
000306180405        select Min(phnldc)
000307180405        into :oldestdate
000308180405        from BCI433LIB/CONTACTW18;
000309180405
000310180405        if (sqlcode = 0) or (SQLWN0='W') AND (SQLWN2 >'W');
000311180409          oldestdate=D'2017-02-01';
000312180405        ENDIF;
000313180409        EXEC SQL
000314180409        select Min(phnldc)
000315180409        into :mostrecentdate
000316180409        from BCI433LIB/CONTACTW18;
000317180409
000318180409        if (sqlcode = 0) or (SQLWN0='W') AND (SQLWN2 < 2);
000319180409          mostrecentdate=D'2017-06-25';
000320180409        ENDIF;
000321180405
000322180405
000323180405         // D E T E R M I N E   T H E   U S E R,  S E R V E R,  &   T I M E S T A M P
000324180405         EXEC SQL
000325180405         select user,current timestamp, current server
000326180405         into :user, :timestamp, :server
000327180405         from sysIBM/SYSdummy1;
000328180405
000329180405
000330180405
000331180405        ENDSR;
000332180405      /END-FREE
000333180405     OQPRINT    E            HEADINGS       2 02
000334180405     O                                            5 'USER:'
000335180405     O                       USER                16
000336180405     O                                           28 'TIMESTAMP:'
000337180405     O                       TIMESTAMP           55
000338180405     O                                           64 'SERVER:'
000339180405     O                       SERVER              75
000340180405     O                                           87 'PAGE:'
000341180405     O                       PAGE                90
000342180405     O          E            HEADINGS       2
000343180405     O                                           54 'Phone Log Report'
000344180405     O                       UDATE         Y     89
000345180405     O          E            HEADINGS       1
000346180405     O                                            5 'Sales'
000347180405     O                                           15 'Customer'
000348180405     O                                           31 'Customer Name'
000349180405     O                                           59 'Telephone'
000350180405     O                                           75 'Last Call'
000351180405     O                                           88 'Oldest Call'
000352180405     O                                          101 'Next Call'
000353180405     O          E            HEADINGS       2
000354180405     O                                            3 'ID'
000355180405     O                                           13 'Number'
000356180405     O                                           73 'Date'
000357180405     O                                           85 'Date'
000358180405     O                                           98 'Date'
000359180405     O          E            DETAIL         1
000360180405     O                       CSTSLN               3
000361180405     O                       CSTNUM              13
000362180405     O                       CSTNAM              48
000363180405     O                       CSTPHN              64
000364180405     O                       PHNLDC              75
000365180405     O                       FLAG                86
000366180405     O                       NextCallDate       101
000367180405     O          E            TOTALS      2  2
000368180405     O                                           32 'Summary Information'
000369180405     O          E            TOTALS         1
000370180405     O                                           26 'CONTACTW18 Total Records:'
000371180405     O                       ContactTotal  1     34
000372180405     O          E            TOTALS         1
000373180405     O                                           26 'CUSTOMER18 Total Records:'
000374180405     O                       CustomerTotal 1     34
000375180405     O          E            TOTALS      1  1
000376180405     O                                           27 'Oldest Last Callback Date:'
000377180405     O                       OldestDate          42
000378180405     O          E            TOTALS         1
000379180405     O                                           27 'Most Recent Callback Date:'
000380180405     O                       MostRecentDate      42
000381180405     O          E            TOTALS      2  1
000382180405     O                                           22 'Total Records with an'
000383180405     O                                           47 'Unknown Last Date Called'
000384180405     O                                           62 'in CONTACTW18:'
000385180405     O                       UnknownTotal        70
000386180405
