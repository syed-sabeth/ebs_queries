-- Date format for To_date and From_date is '31-AUG-2022' format:

SELECT 
CUSTOMER_CATEGORY,
AREA_NAME,
PARTY_NUMBER,
PARTY_ID,
PARTY_NAME,
MAX(DAY_COUNT) DAYS,
SUM(NVL (OPENING_BALANCE, 0)) OPENING_BALANCE,
SUM(NVL (SALES_AMOUNT, 0)) SALES_AMOUNT,
SUM(NVL (DEBIT_AMOUNT, 0))  DEBIT_AMOUNT,
SUM(NVL (CREDIT_AMOUNT, 0))  CREDIT_AMOUNT,
SUM(NVL (CLEARED_RECEIPT, 0))  CLEARED_RECEIPT,   
SUM(NVL (SALES_RETURN, 0))  SALES_RETURN,
SUM(NVL (CLOSING_BALANCE, 0))  CLOSING_BALANCE,
--SUM(NVL (CLEARED_T_RECEIPT_AMOUNT, 0))  CLEARED_T_RECEIPT_AMOUNT,
         NVL(ROUND(((((SUM(NVL (CLEARED_T_RECEIPT_AMOUNT, 0))/NULLIF((CASE 
WHEN MAX(DAY_COUNT) >= 365  THEN 365 ELSE MAX(DAY_COUNT)  END),0))*30)/NULLIF (SUM(NVL (CLOSING_BALANCE, 0)),0))*100),2),0)||'%'   AVG_BALANCE
FROM (WITH CUSTOMER_ZONE
               AS (SELECT DISTINCT CUST.SALES_CHANNEL_CODE CUSTOMER_CATEGORY,
                          ZON.ATTRIBUTE2 AREA_NAME,
                          CUST.PARTY_ID,
                          CUST.PARTY_NUMBER,
                          CUST.CUSTOMER_NAME PARTY_NAME,
                          CUST.CUSTOMER_ID,
                          CUST.CUSTOMER_NUMBER,
                          CUST.ACCOUNT_DESCRIPTION CUSTOMER_NAME,
                          DECODE (CUST.ADDRESS2,
                                  NULL, CUST.ADDRESS1,
                                  CUST.ADDRESS1 || ' ' || CUST.ADDRESS2)
                             ADDRESS,
                          NULL CATEGORY
                     FROM APPS.SOFTLN_AR_CUSTOMERS_ALL_V CUST, APPS.HZ_PARTIES ZON
                    WHERE     CUST.PARTY_ID = ZON.PARTY_ID(+)
                          AND (   :P_DEALER IS NULL  OR CUST.SALES_CHANNEL_CODE = :P_DEALER)
                          --AND CUST.PARTY_NUMBER=101297
                                                              ),
                                                              
                                                              
                CUS_CREA_DATE AS (
SELECT  PARTY_ID,MIN(GL_DATE) GL_DATE,  
(TO_DATE(:P_DATE_TO)- MIN(GL_DATE)) DAY_COUNT
FROM  APPS.XX_AR_CUSTOMER_DTL_LEDGER DL
WHERE  ( :P_ORG_ID IS NULL OR DL.ORG_ID = :P_ORG_ID)
AND ( :P_LEDGER IS NULL OR DL.LEDGER_ID = :P_LEDGER)
GROUP BY PARTY_ID),

               TRANSACTIONS
               AS (SELECT PARTY_ID,
                          GL_DATE,
                          TRX_TYPE,
                          NVL (DR_AMOUNT, 0) DR_AMOUNT,
                          NVL (CR_AMOUNT, 0) CR_AMOUNT,
                          (NVL (DR_AMOUNT, 0) - NVL (CR_AMOUNT, 0)) AMOUNT
                     FROM APPS.XX_AR_CUSTOMER_DTL_LEDGER DL
                    WHERE     GL_DATE <= TO_DATE(:P_DATE_TO)
                          AND ( :P_ORG_ID IS NULL OR ORG_ID = :P_ORG_ID)
                         ---AND ORG_ID=101---------------------------------------------------------------------------
                         --AND DL.LEDGER_ID = 2021
                           AND ( :P_LEDGER IS NULL OR DL.LEDGER_ID = :P_LEDGER)
                          
                          --AND (   :P_CUSTOMER_ID IS NULL  OR CUSTOMER_ID = :P_CUSTOMER_ID)
                          ),
               OPENING_BALANCE
               AS (  SELECT PARTY_ID, NVL (SUM (AMOUNT), 0) OPENING_AMOUNT
                       FROM TRANSACTIONS
                      WHERE GL_DATE < TO_DATE(:P_DATE_FROM)
                   GROUP BY PARTY_ID),
               SALES
               AS (  SELECT PARTY_ID, NVL (SUM (DR_AMOUNT), 0) SALES_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) IN ('GO-LIVE OPENING BALANCE',
                                                     'SALES')
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
               RETURNS
               AS (  SELECT PARTY_ID, NVL (SUM (CR_AMOUNT), 0) RETURN_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'RETURN'
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
               DEBIT
               AS (  SELECT PARTY_ID, NVL (SUM (DR_AMOUNT), 0) DEBIT_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'DEBIT ADJUSTMENT'
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
               CREDIT
               AS (  SELECT PARTY_ID, NVL (SUM (CR_AMOUNT), 0) CREDIT_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'CREDIT ADJUSTMENT'
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
               REFUNDS
               AS (  SELECT PARTY_ID, NVL (SUM (DR_AMOUNT), 0) REFUND_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'CUSTOMER REFUND'
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
               RECEIPTS
               AS (  SELECT PARTY_ID, NVL (SUM (CR_AMOUNT), 0) RECEIPT_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'RECEIPTS'
                            AND GL_DATE BETWEEN TO_DATE(:P_DATE_FROM) AND TO_DATE(:P_DATE_TO)
                   GROUP BY PARTY_ID),
                RECEIPTS_TLV
               AS (  SELECT PARTY_ID,NVL (SUM (CR_AMOUNT), 0) T_RECEIPT_AMOUNT
                       FROM TRANSACTIONS
                      WHERE     UPPER (TRX_TYPE) = 'RECEIPTS'
                            AND GL_DATE  BETWEEN TO_DATE ((TO_DATE(:P_DATE_TO)+1)-365)  AND TO_DATE(:P_DATE_TO)                           

                   GROUP BY PARTY_ID)
          SELECT CUSTOMER_CATEGORY,
                 AREA_NAME,
                 CZ.PARTY_ID,
                 CZ.PARTY_NUMBER,
                 CZ.PARTY_NAME,
                 DAY_COUNT,                
                 NVL (OPENING_AMOUNT, 0) OPENING_BALANCE,
                 NVL (SALES_AMOUNT, 0) SALES_AMOUNT,
                 NVL (DEBIT_AMOUNT, 0) + NVL (REFUND_AMOUNT, 0) DEBIT_AMOUNT,
                 NVL (CREDIT_AMOUNT, 0) CREDIT_AMOUNT,
                 NVL (RECEIPT_AMOUNT, 0) CLEARED_RECEIPT,
                 NVL (RETURN_AMOUNT, 0) SALES_RETURN,                      
                 (  (  NVL (OPENING_AMOUNT, 0)
                     + NVL (SALES_AMOUNT, 0)
                     + NVL (DEBIT_AMOUNT, 0))
                  - (  NVL (CREDIT_AMOUNT, 0)
                     + NVL (RECEIPT_AMOUNT, 0)
                     + NVL (RETURN_AMOUNT, 0)))
                    CLOSING_BALANCE,
                    NVL (T_RECEIPT_AMOUNT, 0) CLEARED_T_RECEIPT_AMOUNT, 

                     (NVL (SALES_AMOUNT, 0)-NVL (RETURN_AMOUNT, 0)) SAL_OP
            FROM CUSTOMER_ZONE CZ,
                 TRANSACTIONS TR,
                 OPENING_BALANCE OB,
                 SALES S,
                 RETURNS R,
                 DEBIT D,
                 CREDIT C,
                 REFUNDS FN,
                 RECEIPTS RCT,
                 RECEIPTS_TLV TLV,
                 CUS_CREA_DATE CCD
           WHERE     CZ.PARTY_ID = TR.PARTY_ID(+)
                 AND CZ.PARTY_ID = OB.PARTY_ID(+)
                 AND CZ.PARTY_ID = S.PARTY_ID(+)
                 AND CZ.PARTY_ID = R.PARTY_ID(+)
                 AND CZ.PARTY_ID = D.PARTY_ID(+)
                 AND CZ.PARTY_ID = C.PARTY_ID(+)
                 AND CZ.PARTY_ID = FN.PARTY_ID(+)
                 AND CZ.PARTY_ID = RCT.PARTY_ID(+)
                  AND CZ.PARTY_ID = TLV.PARTY_ID(+)
                  AND CZ.PARTY_ID = CCD.PARTY_ID(+)
                 AND (   OPENING_AMOUNT <> 0
                      OR NVL (SALES_AMOUNT, 0) <> 0
                      OR NVL (DEBIT_AMOUNT, 0) <> 0
                      OR NVL (CREDIT_AMOUNT, 0) <> 0
                      OR NVL (RECEIPT_AMOUNT, 0) <> 0
                      OR NVL (RETURN_AMOUNT, 0) <> 0
                      OR NVL (REFUND_AMOUNT, 0) <> 0)
                      GROUP BY CUSTOMER_CATEGORY,
                 AREA_NAME,
                 CZ.PARTY_ID,
                 CZ.PARTY_NUMBER,
                 CZ.PARTY_NAME,
                 DAY_COUNT,
                 CATEGORY,                 
                 NVL (OPENING_AMOUNT, 0),
                 NVL (SALES_AMOUNT, 0) ,
                 NVL (DEBIT_AMOUNT, 0) ,
                 NVL (REFUND_AMOUNT, 0),
                 NVL (CREDIT_AMOUNT, 0) ,
                 NVL (RECEIPT_AMOUNT, 0) ,
                 NVL (RETURN_AMOUNT, 0) ,                      
                 NVL (T_RECEIPT_AMOUNT, 0)
                      ) 
                                                    
GROUP BY CUSTOMER_CATEGORY,
AREA_NAME,
PARTY_NUMBER,
PARTY_ID,
PARTY_NAME
ORDER BY 3,4,1