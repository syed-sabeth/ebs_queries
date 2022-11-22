SELECT 'OCT-22' PERIOD,
		 LEDGER_ID,
         AC_CODE,
         CASE
            WHEN AC_CODE LIKE '1%' THEN 'Asset'
            WHEN AC_CODE LIKE '2%' THEN 'Equities'
            WHEN AC_CODE LIKE '3%' THEN 'Liability'
            WHEN AC_CODE LIKE '4%' THEN 'Revenue'
            WHEN AC_CODE LIKE '5%' THEN 'Expense'
            ELSE 'Others'
         END
            AC_TYPE,
         L1.LEVEL_NO,
         L1.LEVEL_SL L1SL,
         VL.ATTRIBUTE1 LEVEL1,
         L1.LEVEL_NAME LEVEL1_NAME,
         L2.LEVEL_SL L2SL,
         VL.ATTRIBUTE2 LEVEL2,
         L2.LEVEL_NAME LEVEL2_NAME,
         L3.LEVEL_SL L3SL,
         VL.ATTRIBUTE3 LEVEL3,
         L3.LEVEL_NAME LEVEL3_NAME,
         APPS.SOFTLN_COM_PKG.GET_FLEX_VALUES_FROM_FLEX_ID (AC_CODE, 5) AC_NAME,
         OPEN_BAL,
         NET_DR,
         NET_CR,
         NET_DR - NET_CR PER_NET,
         CLS_BAL
    FROM APPS.XX_WALTON_COO_LEVEL L3,
         APPS.XX_WALTON_COO_LEVEL L2,
         APPS.XX_WALTON_COO_LEVEL L1,
         (SELECT *
            FROM APPS.FND_FLEX_VALUES_VL
           WHERE FLEX_VALUE_SET_ID = 1016488) VL,
         (  SELECT LEDGER_ID,
                   AC_CODE,
                   SUM (OPEN_BAL) OPEN_BAL,
                   SUM (NET_DR) NET_DR,
                   SUM (NET_CR) NET_CR,
                   SUM (CLS_BAL) CLS_BAL
              FROM (SELECT GB.LEDGER_ID,
                           GCC.SEGMENT1 OU_CODE,
                           GCC.SEGMENT5 AC_CODE,
                           NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)
                              OPEN_BAL,
                           0 NET_DR,
                           0 NET_CR,
                           0 CLS_BAL
                      FROM APPS.GL_CODE_COMBINATIONS GCC,
                           APPS.GL_PERIOD_STATUSES GPS,
                           APPS.GL_BALANCES GB
                     WHERE     1 = 1
                           AND GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
                           AND GPS.EFFECTIVE_PERIOD_NUM < (SELECT DISTINCT EFFECTIVE_PERIOD_NUM  FROM     APPS.GL_PERIOD_STATUSES
WHERE  PERIOD_NAME='OCT-22')
                           AND NVL (GPS.ADJUSTMENT_PERIOD_FLAG, 'O') = 'N'
                           AND GPS.APPLICATION_ID = 101
                           AND GPS.PERIOD_TYPE = GB.PERIOD_TYPE
                           AND GB.LEDGER_ID = GPS.LEDGER_ID
                           AND GPS.PERIOD_NUM = GB.PERIOD_NUM
                           AND GPS.PERIOD_YEAR = GB.PERIOD_YEAR
                           AND GB.CURRENCY_CODE =
                                  (SELECT CURRENCY_CODE
                                     FROM APPS.GL_LEDGERS
                                    WHERE LEDGER_ID = GB.LEDGER_ID)
                           AND GB.ACTUAL_FLAG = 'A'
                           AND GB.LEDGER_ID = 2021
                    UNION ALL
                    SELECT GB.LEDGER_ID,
                           GCC.SEGMENT1 OU_CODE,
                           GCC.SEGMENT5 AC_CODE,
                           0 OPEN_BAL,
                           NVL (GB.PERIOD_NET_DR, 0) NET_DR,
                           NVL (GB.PERIOD_NET_CR, 0) NET_CR,
                           0 CLS_BAL
                      FROM APPS.GL_CODE_COMBINATIONS GCC,
                           APPS.GL_PERIOD_STATUSES GPS,
                           APPS.GL_BALANCES GB
                     WHERE     1 = 1
                           AND GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
                           AND GPS.EFFECTIVE_PERIOD_NUM BETWEEN (SELECT DISTINCT EFFECTIVE_PERIOD_NUM  FROM     APPS.GL_PERIOD_STATUSES
WHERE  PERIOD_NAME='OCT-22')
                                                            AND (SELECT DISTINCT EFFECTIVE_PERIOD_NUM  FROM     APPS.GL_PERIOD_STATUSES
WHERE  PERIOD_NAME='OCT-22')
                           AND NVL (GPS.ADJUSTMENT_PERIOD_FLAG, 'O') = 'N'
                           AND GPS.APPLICATION_ID = 101
                           AND GPS.PERIOD_TYPE = GB.PERIOD_TYPE
                           AND GB.LEDGER_ID = GPS.LEDGER_ID
                           AND GPS.PERIOD_NUM = GB.PERIOD_NUM
                           AND GPS.PERIOD_YEAR = GB.PERIOD_YEAR
                           AND GB.CURRENCY_CODE =
                                  (SELECT CURRENCY_CODE
                                     FROM APPS.GL_LEDGERS
                                    WHERE LEDGER_ID = GB.LEDGER_ID)
                           AND GB.ACTUAL_FLAG = 'A'
                           AND GB.LEDGER_ID = 2021
                    UNION ALL
                    SELECT GB.LEDGER_ID,
                           GCC.SEGMENT1 OU_CODE,
                           GCC.SEGMENT5 AC_CODE,
                           0 OPEN_BAL,
                           0 NET_DR,
                           0 NET_CR,
                           NVL (GB.PERIOD_NET_DR, 0) - NVL (GB.PERIOD_NET_CR, 0)
                              CLS_BAL
                      FROM APPS.GL_CODE_COMBINATIONS GCC,
                           APPS.GL_PERIOD_STATUSES GPS,
                           APPS.GL_BALANCES GB
                     WHERE     1 = 1
                           AND GCC.CODE_COMBINATION_ID = GB.CODE_COMBINATION_ID
                           AND GPS.EFFECTIVE_PERIOD_NUM <= (SELECT DISTINCT EFFECTIVE_PERIOD_NUM  FROM     APPS.GL_PERIOD_STATUSES
WHERE  PERIOD_NAME='OCT-22')
                           AND NVL (GPS.ADJUSTMENT_PERIOD_FLAG, 'O') = 'N'
                           AND GPS.APPLICATION_ID = 101
                           AND GPS.PERIOD_TYPE = GB.PERIOD_TYPE
                           AND GB.LEDGER_ID = GPS.LEDGER_ID
                           AND GPS.PERIOD_NUM = GB.PERIOD_NUM
                           AND GPS.PERIOD_YEAR = GB.PERIOD_YEAR
                           AND GB.CURRENCY_CODE =
                                  (SELECT CURRENCY_CODE
                                     FROM APPS.GL_LEDGERS
                                    WHERE LEDGER_ID = GB.LEDGER_ID)
                           AND GB.ACTUAL_FLAG = 'A'
                           AND GB.LEDGER_ID = 2021)
          GROUP BY LEDGER_ID, AC_CODE)
   WHERE     L3.LEVEL_ID(+) = VL.ATTRIBUTE3
         AND L2.LEVEL_ID(+) = VL.ATTRIBUTE2
         AND L1.LEVEL_ID(+) = VL.ATTRIBUTE1
         AND VL.FLEX_VALUE_MEANING(+) = AC_CODE
         AND ABS (OPEN_BAL) + ABS (NET_DR) + ABS (NET_CR) + ABS (CLS_BAL) > 0
ORDER BY AC_CODE