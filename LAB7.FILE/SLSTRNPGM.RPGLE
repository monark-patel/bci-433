000100171124     FSALESTRANSIF   E             DISK    RENAME(SALESTRANS:SALESTRANR)
000200010613     FSALESSTAF2UF A E           K DISK
000300010613     FQPRINT    O    F  132        PRINTER OFLIND(*INOF)
000400171124     D SALESTRANSDS    DS
000500071030     D   TDEPT
000600071030     D   TSALESID
000700071030     D   TFNAME
000800071030     D   TLNAME
000900071030     D   TCITY
001000071030     D   TADDRESS
001100071030     D   TPCODE
001200071030     D SALESSTAF2DS    DS
001300071030     D    DEPT
001400071030     D    SALESID
001500071030     D    FNAME
001600071030     D    LNAME
001700071030     D    CITY
001800071030     D    ADDRESS
001900071030     D    PCODE
002000101110     D FullKey         DS                  LikeRec(SALESTFR: *Key)
002100101110     C/FREE
002200180320                   EXCEPT HEADINGS;
002300180320                   READ   SALESTRANS;
002400180320                   DOW NOT %EOF;
002500180322                      FullKey = TDept + TSalesID;
002600180322                      CHAIN %KDS(FullKey) SalesStaf2;
002700101110                      SELECT;
002800180320                        WHEN %FOUND(SALESSTAF2);
002900101110                        SELECT;
003000180320                           WHEN TCODE = 'C';
003100180320                              EXSR CHGREC;
003200180320                           WHEN TCODE = 'D';
003300180320                              EXSR DELREC;
003400101110                           OTHER;
003500180320                              EXSR ERROR;
003600101110                        ENDSL;
003700180320                        WHEN NOT %FOUND(SALESSTAF2);
003800180320                           IF TCODE = 'A';
003900180320                              EXSR ADDREC;
004000180320                           ELSE;
004100180320                              EXSR ERROR;
004200101110                           ENDIF;
004300180320                        WHEN %ERROR;
004400180320                              EXSR ERROR;
004500101110                        ENDSL;
004600180320                        EXCEPT DETAIL;
004700180320                        READ SALESTRANS;
004800101110                   ENDDO;
004900101110                   *INLR = *ON;
005000101110                   RETURN;
005100101110         BEGSR  ADDREC;
005200180322                   SALESSTAF2DS = SALESTRANSDS;
005300180322                   Phone = %Dec(TPhone:10:0);
005400180320                   WRITE SALESTFR;
005500101110         ENDSR;
005600101110         BEGSR  CHGREC;
005700171124                   SALESSTAF2DS = SALESTRANSDS;
005800180320                   Phone        = %Dec(TPhone:10:0);
005900180320                   UPDATE SALESTFR;
006000101110         ENDSR;
006100101110         BEGSR  DELREC;
006200180320                   DELETE SALESTFR;
006300101110         ENDSR;
006400101110         BEGSR  ERROR;
006500101110                   TFNAME = 'UPDATE/DELETE/CHANGE';
006600101110                   TLNAME = 'E R R O R';
006700101110         ENDSR;
006800101110      /END-FREE
006900010613     OQPRINT    E            HEADINGS       2 02
007000010613     O                                            8 'PAGE'
007100010613     O                       PAGE                13
007200010613     O                                           50 'SALESSTAFF UPDATE'
007300010613     O                                           64 'DATE'
007400010613     O                       UDATE         Y     73
007500010613     O          E            HEADINGS       1
007600010613     O                                            4 'CODE'
007700010613     O                                           10 'DEPT'
007800011019     O                                           14 'ID'
007900010613     O                                           28 'FIRST NAME'
008000010613     O                                           49 'LAST NAME'
008100010613     O                                           66 'CITY'
008200010613     O                                           91 'ADDRESS'
008300071030     O                                          113 'PHONE'
008400071030     O                                          125 'POSTAL'
008500010613     O          E            HEADINGS       2
008600071030     O                                          124 'CODE'
008700010613     O          E            DETAIL         1
008800010613     O                       TCODE                2
008900010613     O                       TDEPT                9
009000010613     O                       TSALESID            15
009100010613     O                       TFNAME              38
009200010613     O                       TLNAME              60
009300010613     O                       TCITY               82
009400010613     O                       TADDRESS           102
009500071030     O                       TPHONE             116
009600071030     O                       TPCODE             125
