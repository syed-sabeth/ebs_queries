SELECT P.PERIOD,
       NVL (P.SALES_CHANNEL_CODE, Q.SALES_CHANNEL_CODE) SALES_CHANNEL_CODE,
       NVL (TARGET_QTY, 0) TARGET_QTY,
       NVL (P.DELIVARY_QTY, 0) DELIVERY_QTY,
       NVL (P.DELIVARY_AMOUNT, 0) DELIVERY_AMOUNT,
       NVL (P.TFA_SHIP_QTY, 0) TFA_SHIP_QTY,
       NVL (P.TFA_SHIP_AMOUNT, 0) TFA_SHIP_AMOUNT,
       NVL (P.TARGET_AMOUNT, 0) TARGET_AMOUNT,
       NVL (P.FINAL_TARGET, 0) FINAL_TARGET,
       ROUND (NVL (P.ACHIEVE, 0), 2) ACHIEVE,
       NVL (Q.R_RECEIPT_AMOUNT, 0) R_RECEIPT_AMOUNT,
       NVL (Q.C_RECEIPT_AMOUNT, 0) C_RECEIPT_AMOUNT
  FROM (  SELECT PERIOD,
                 SALES_CHANNEL_CODE,
                 SUM (NVL (DELIVARY_QTY, 0)) DELIVARY_QTY,
                 SUM (NVL (DELIVARY_AMOUNT, 0)) DELIVARY_AMOUNT,
                 SUM (NVL (TFA_SHIP_QTY, 0)) TFA_SHIP_QTY,
                 SUM (NVL (TFA_SHIP_AMOUNT, 0)) TFA_SHIP_AMOUNT,
                 SUM (NVL (TARGET_QTY, 0)) TARGET_QTY,
                 SUM (NVL (TARGET_AMOUNT, 0)) TARGET_AMOUNT,
                 SUM (NVL (FINAL_TARGET, 0)) FINAL_TARGET,
                 (  (  SUM (NVL (DELIVARY_AMOUNT, 0))
                     / NULLIF (SUM (NVL (FINAL_TARGET, 0)), 0))
                  * 100)
                    ACHIEVE
            FROM (SELECT NVL (S.PERIOD, T.PERIOD) PERIOD,
                         NVL (S.ORG_ID, T.ORG_ID) ORG_ID,
                         NVL (S.AREA, T.AREA) AREA,
                         NVL (S.SALES_CHANNEL_CODE, T.CHANNEL)
                            SALES_CHANNEL_CODE,
                         NVL (S.SHIP_QTY, 0) DELIVARY_QTY,
                         ROUND (NVL (S.SHIP_AMOUNT, 0)) DELIVARY_AMOUNT,
                         NVL (S.TFA_SHIP_QTY, 0) TFA_SHIP_QTY,
                         NVL (S.TFA_SHIP_AMOUNT, 0) TFA_SHIP_AMOUNT,
                         ROUND (
                            (  NVL (S.SHIP_AMOUNT, 0)
                             / NULLIF (NVL (S.SHIP_QTY, 0), 0)),
                            0)
                            AVG_SALES_PRICE,
                         NVL (T.QUANTITY, 0) TARGET_QTY,
                         NVL (T.TARGET, 0) TARGET_AMOUNT,
                         ROUND (
                            CASE
                               WHEN NVL (T.TARGET, 0) = 0
                               THEN
                                  (  ROUND (
                                        (  NVL (S.SHIP_AMOUNT, 0)
                                         / NULLIF (NVL (S.SHIP_QTY, 0), 0)),
                                        0)
                                   * NVL (T.QUANTITY, 0))
                               ELSE
                                  NVL (T.TARGET, 0)
                            END)
                            FINAL_TARGET
                    FROM ( 
                    
                    
                    
                    
 SELECT 
 ORG_ID,
 PERIOD,
 SALES_CHANNEL_CODE,
 AREA,
 SUM(NVL(SHIP_QTY,0)) SHIP_QTY,
 SUM(NVL(SHIP_AMOUNT,0)) SHIP_AMOUNT,
 SUM(NVL(TFA_SHIP_QTY,0)) TFA_SHIP_QTY,
 SUM(NVL(TFA_SHIP_AMOUNT,0)) TFA_SHIP_AMOUNT
 
 
 
 FROM 
 
 (
 
 SELECT OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE, 'MON-YYYY')
                                      PERIOD,
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA,
                                   SUM (NVL (OL.SHIPPED_QUANTITY, 0)) SHIP_QTY,
                                   SUM (
                                        NVL (OL.SHIPPED_QUANTITY, 0)
                                      * (  NVL (OL.UNIT_SELLING_PRICE, 0)
                                         * NVL (CONVERSION_RATE, 1)))
                                      SHIP_AMOUNT,0 TFA_SHIP_QTY, 0 TFA_SHIP_AMOUNT
                              FROM APPS.OE_ORDER_HEADERS_ALL OH,
                                   APPS.OE_ORDER_LINES_ALL OL,
                                   APPS.HR_OPERATING_UNITS OU,
                                   APPS.SOFTLN_AR_CUSTOMERS_ALL_V CUST,
                                   APPS.SOFTLN_INV_FG_CATEGORY_V CAT
                             WHERE     OH.HEADER_ID = OL.HEADER_ID
                                   AND OH.ORDER_CATEGORY_CODE = 'ORDER'
                                   AND OL.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
                                   AND OL.ORG_ID = OU.ORGANIZATION_ID
                                   AND OL.SHIP_FROM_ORG_ID = CAT.ORGANIZATION_ID
                                   AND OL.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID   
                                   -- AND CAT.PRODUCT<>'AIRCONDITIONER-OUTDOOR'
                                   AND OH.BOOKED_FLAG = 'Y'
                                   AND OL.ACTUAL_SHIPMENT_DATE IS NOT NULL
                                   AND ( '$le' IS NULL OR OU.SET_OF_BOOKS_ID = '2021')
                                   --AND ( '$unit' IS NULL OR OH.ORG_ID ='$unit')                                  
                                   AND TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                                'MON-YYYY') = 'NOV-2022'
                          GROUP BY OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                            'MON-YYYY'),
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA
                                   



UNION ALL


SELECT OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE, 'MON-YYYY')
                                      PERIOD,
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA,
                                    0 SHIP_QTY,
                                    0 SHIP_AMOUNT,
                                   SUM (NVL (OL.SHIPPED_QUANTITY, 0)) TFA_SHIP_QTY ,
                                   0 TFA_SHIP_AMOUNT
                              FROM APPS.OE_ORDER_HEADERS_ALL OH,
                                   APPS.OE_ORDER_LINES_ALL OL,
                                   APPS.HR_OPERATING_UNITS OU,
                                   APPS.SOFTLN_AR_CUSTOMERS_ALL_V CUST,
                                   APPS.SOFTLN_INV_FG_CATEGORY_V CAT
                             WHERE     OH.HEADER_ID = OL.HEADER_ID
                                   AND OH.ORDER_CATEGORY_CODE = 'ORDER'
                                   AND OL.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
                                   AND OL.ORG_ID = OU.ORGANIZATION_ID
                                   AND OH.BOOKED_FLAG = 'Y'
                                   AND OL.SHIP_FROM_ORG_ID = CAT.ORGANIZATION_ID
                                   AND OL.INVENTORY_ITEM_ID =
                                          CAT.INVENTORY_ITEM_ID
                                    --AND CAT.PRODUCT<>'AIRCONDITIONER-OUTDOOR'
                                   AND OL.ACTUAL_SHIPMENT_DATE IS NOT NULL
                                   AND ( '$le' IS NULL OR OU.SET_OF_BOOKS_ID = '2021')
                                   AND OH.ORG_ID  IN (182,101,202)
                                   --AND ( '$unit' IS NULL OR OH.ORG_ID ='$unit') 
                                   AND TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                                'MON-YYYY') = 'NOV-2022'
                          GROUP BY OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                            'MON-YYYY'),
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA
                                   
UNION ALL                                 
                                   
SELECT OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE, 'MON-YYYY')
                                      PERIOD,
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA,
                                   0 SHIP_QTY,
                                   0 SHIP_AMOUNT,
                                   0 TFA_SHIP_QTY,
                                   SUM (
                                        NVL (OL.SHIPPED_QUANTITY, 0)
                                      * (  NVL (OL.UNIT_SELLING_PRICE, 0)
                                         * NVL (CONVERSION_RATE, 1)))
                                      TFA_SHIP_AMOUNT
                              FROM APPS.OE_ORDER_HEADERS_ALL OH,
                                   APPS.OE_ORDER_LINES_ALL OL,
                                   APPS.HR_OPERATING_UNITS OU,
                                   APPS.SOFTLN_AR_CUSTOMERS_ALL_V CUST,
                                   APPS.SOFTLN_INV_FG_CATEGORY_V CAT
                             WHERE     OH.HEADER_ID = OL.HEADER_ID
                                   AND OH.ORDER_CATEGORY_CODE = 'ORDER'
                                   AND OL.SOLD_TO_ORG_ID = CUST.CUSTOMER_ID
                                   AND OL.ORG_ID = OU.ORGANIZATION_ID
                                   AND OH.BOOKED_FLAG = 'Y'
                                   AND OL.ACTUAL_SHIPMENT_DATE IS NOT NULL
                                   AND OL.SHIP_FROM_ORG_ID = CAT.ORGANIZATION_ID
                                   AND OL.INVENTORY_ITEM_ID = CAT.INVENTORY_ITEM_ID                 
                                   --AND CAT.PRODUCT<>'AIRCONDITIONER-OUTDOOR'
                                   AND ( '$le' IS NULL OR OU.SET_OF_BOOKS_ID = '2021')
                                   AND OH.ORG_ID  IN (142,203)
                                   --AND ( '$unit' IS NULL OR OH.ORG_ID ='$unit') 
                                   AND TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                                'MON-YYYY') = 'NOV-2022'
                          GROUP BY OH.ORG_ID,
                                   TO_CHAR (OL.ACTUAL_SHIPMENT_DATE,
                                            'MON-YYYY'),
                                   CUST.SALES_CHANNEL_CODE,
                                   CUST.AREA)
                                   
                                   GROUP BY 
                                    ORG_ID,
 PERIOD,
 SALES_CHANNEL_CODE,
 AREA
            ) S FULL OUTER JOIN
                         (  SELECT ST.ORG_ID,
                                   TO_CHAR (ST.T_DATE, 'MON-YYYY') PERIOD,
                                   ST.CHANNEL,
                                   ST.AREA,
                                   SUM (NVL (ST.QUANTITY, 0)) QUANTITY,
                                   SUM (NVL (ST.TARGET, 0)) TARGET
                              FROM APPS.XX_LOCAL_SALES_TARGET ST,
                                   APPS.HR_OPERATING_UNITS OU
                             WHERE     1 = 1
                                   AND ST.ORG_ID = OU.ORGANIZATION_ID
                                   AND ( '$le' IS NULL OR OU.SET_OF_BOOKS_ID = '2021')
                                    --AND ('$unit' IS NULL OR ST.ORG_ID = '$unit')
                                   AND TO_CHAR (ST.T_DATE, 'MON-YYYY') =
                                          'NOV-2022'
                          GROUP BY ST.ORG_ID,
                                   TO_CHAR (ST.T_DATE, 'MON-YYYY'),
                                   ST.CHANNEL,
                                   ST.AREA) T
                   ON     1 = 1
                         AND S.SALES_CHANNEL_CODE = T.CHANNEL
                         AND S.PERIOD = T.PERIOD
                         AND S.ORG_ID = T.ORG_ID
                         AND S.AREA = T.AREA
                         )
        GROUP BY PERIOD, SALES_CHANNEL_CODE) P
       LEFT JOIN
       (  SELECT SALES_CHANNEL_CODE,
                 SUM (NVL (R_RECEIPT_AMOUNT, 0)) R_RECEIPT_AMOUNT,
                 SUM (NVL (C_RECEIPT_AMOUNT, 0)) C_RECEIPT_AMOUNT
            FROM (  SELECT CR.SET_OF_BOOKS_ID,
                           CR.ORG_ID,
                           CUST.SALES_CHANNEL_CODE,
                           0 R_RECEIPT_AMOUNT,
                           SUM (CR.AMOUNT * NVL(CR.EXCHANGE_RATE,1)) C_RECEIPT_AMOUNT
                      FROM APPS.AR_CASH_RECEIPTS_ALL CR,
                           APPS.AR_CASH_RECEIPT_HISTORY_ALL CRH,
                           APPS.HZ_CUST_ACCOUNTS CUST,
                           APPS.HZ_PARTIES PARTY
                     WHERE     CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                           AND CR.PAY_FROM_CUSTOMER = CUST.CUST_ACCOUNT_ID(+)
                           AND CUST.PARTY_ID = PARTY.PARTY_ID(+)
                           AND CRH.CURRENT_RECORD_FLAG = 'Y'
                           AND CRH.STATUS = 'CLEARED'
                           AND TO_CHAR (TRUNC (CRH.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                  GROUP BY CR.SET_OF_BOOKS_ID,
                           CR.ORG_ID,
                           CUST.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT CR.SET_OF_BOOKS_ID,
                           CR.ORG_ID,
                           CUST.SALES_CHANNEL_CODE,
                           SUM (CR.AMOUNT* NVL(CR.EXCHANGE_RATE,1)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.AR_CASH_RECEIPTS_ALL CR,
                           APPS.AR_CASH_RECEIPT_HISTORY_ALL CRH,
                           APPS.HZ_CUST_ACCOUNTS CUST,
                           APPS.HZ_PARTIES PARTY
                     WHERE     CR.CASH_RECEIPT_ID = CRH.CASH_RECEIPT_ID
                           AND CR.PAY_FROM_CUSTOMER = CUST.CUST_ACCOUNT_ID(+)
                           AND CUST.PARTY_ID = PARTY.PARTY_ID(+)
                           AND CRH.CURRENT_RECORD_FLAG = 'Y'
                           AND CRH.STATUS = 'REMITTED'
                           AND TO_CHAR (TRUNC (CRH.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                  GROUP BY CR.SET_OF_BOOKS_ID,
                           CR.ORG_ID,
                           CUST.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           101 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (WRC_CLEARED, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           142 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_EAP, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           182 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_WTV, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           202 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_WAC, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           203 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_HAP, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           142 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_FAN, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           142 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_SST, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE
                  UNION ALL
                    SELECT 2021 SET_OF_BOOKS_ID,
                           142 ORG_ID,
                           C.SALES_CHANNEL_CODE,
                           SUM (NVL (AMOUNT_LED, 0)) R_RECEIPT_AMOUNT,
                           0 C_RECEIPT_AMOUNT
                      FROM APPS.XX_CNTRL_COLLECTION B,
                           (SELECT DISTINCT PARTY_ID, SALES_CHANNEL_CODE
                              FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V
                             WHERE     SALES_CHANNEL_CODE IS NOT NULL
                                   AND STATUS = 'A') C
                     WHERE     1 = 1
                           AND TO_CHAR (TRUNC (B.GL_DATE), 'MON-YYYY') =
                                  'NOV-2022'
                           AND B.STATUS NOT IN ('CLEARED', 'REJECTED')
                           AND B.PARTY_ID = C.PARTY_ID
                  GROUP BY C.SALES_CHANNEL_CODE)
           WHERE     1 = 1
                 AND ( '$le' IS NULL OR SET_OF_BOOKS_ID = '2021')
                 --AND ('$unit' IS NULL OR ORG_ID = '$unit')
        GROUP BY SALES_CHANNEL_CODE) Q
          ON P.SALES_CHANNEL_CODE = Q.SALES_CHANNEL_CODE