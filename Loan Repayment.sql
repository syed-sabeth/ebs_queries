  /* Loan Repayment Schedule */
  SELECT P.SET_OF_BOOKS_ID,
         (SELECT MAX (LEGAL_ENTITY)
            FROM APPS.ORG_ORGANIZATION_DEFINITIONS
            WHERE SET_OF_BOOKS_ID = P.SET_OF_BOOKS_ID)
            LE,
         P.ORGANIZATION_ID,
         Q.ORGANIZATION_NAME OPERATING_UNIT,
         Q.BANK_ID,
         Q.BANK_NAME,
         Q.BANK_ACCOUNT_NAME,
         Q.MAJOR_LOAN_TYPE,
         Q.LOAN_TYPE_CODE,
         Q.LOAN_NUMBER,
         ROUND(Q.LOAN_AMOUNT) LOAN_AMOUNT,
         Q.CURRENCY_CODE,
         ROUND(NVL (Q.FOREIGN_CURRENCY_RATE, 1),2) FOREIGN_CURRENCY_RATE,
         TO_CHAR (Q.START_DATE, 'DD-MON-YYYY') START_DATE,
         TO_CHAR (Q.END_DATE, 'DD-MON-YYYY') END_DATE,
         Q.LC_NUMBER,
         --Q.LC_SHIPMENT_AMT,
         Q.PRODUCT_TYPE,
         ( (Q.END_DATE - Q.START_DATE) + 1) DAYS,  
         NVL(LIBOR_RATE,0) LIBOR,
         NVL(INTEREST_RATE,0) INTEREST_RATE,
         ROUND((NVL(((((((NVL(LIBOR_RATE,0)+NVL(INTEREST_RATE,0))*ROUND(REMAYMENT_AMT))/100))/360)*( (Q.END_DATE - Q.START_DATE) + 1)),0)),2) INTEREST_AMOUNT,      
         ROUND(LOAN_AMT) LOAN_AMT,
         ROUND(PAY_AMT) PAY_AMT,
         (ROUND(REMAYMENT_AMT)+ROUND((NVL(((((((NVL(LIBOR_RATE,0)+NVL(INTEREST_RATE,0))*ROUND(REMAYMENT_AMT))/100))/360)*( (Q.END_DATE - Q.START_DATE) + 1)),0)),2)) NET_PAYABLE
    FROM (SELECT A.ORG_ID,
                 NVL (A.LOAN_ID, B.LOAN_ID) LOAN_ID,
                 A.ORGANIZATION_NAME,
                 A.BANK_ID,
                 A.BANK_NAME,
                 A.BANK_BRANCH_NAME,
                 A.LOAN_TYPE_CODE,
                 A.LOAN_NUMBER,
                 --A.LOAN_ID,
                 A.LOAN_AMOUNT,
                 A.CURRENCY_CODE,
                 A.OPENING_DATE,
                 A.LC_NUMBER,
                 A.LC_SHIPMENT_AMT,
                 A.START_DATE,
                 A.END_DATE,
                 A.MAJOR_LOAN_TYPE,
                 A.BANK_ACCOUNT_NAME,
                 A.FOREIGN_CURRENCY_RATE,
                 A.LIBOR_RATE,
                 A.INTEREST_RATE, 
                 NVL (A.LOAN_AMT, 0) LOAN_AMT,
                 A.PRODUCT_TYPE,
                 NVL (B.PAY_AMT, 0) PAY_AMT,
                 NVL ( (NVL (A.LOAN_AMT, 0) - NVL (B.PAY_AMT, 0)), 0)*NVL( A.FOREIGN_CURRENCY_RATE,1)
                    REMAYMENT_AMT
            FROM (SELECT ORG_ID,
                         ORGANIZATION_NAME,
                         BANK_ID,
                         BANK_NAME,
                         BANK_BRANCH_NAME,
                         LOAN_TYPE_CODE,
                         LOAN_NUMBER,
                         LOAN_ID,
                         LIBOR_RATE,
                         INTEREST_RATE,
                         LOAN_AMOUNT,
                         CURRENCY_CODE,
                         TRUNC (OPENING_DATE) OPENING_DATE,
                         (LC_NUMBER || LC_NUMBER2) LC_NUMBER,
                         LC_SHIPMENT_AMT,
                         TRUNC (EFFECTIVE_START_DATE) START_DATE,
                         TRUNC (EFFECTIVE_END_DATE) END_DATE,
                         MAJOR_LOAN_TYPE,
                         BANK_ACCOUNT_NAME,
                         FOREIGN_CURRENCY_RATE,
                         NVL(LOAN_AMOUNT ,0)
                            LOAN_AMT,
                         PRODUCT_TYPE
                    FROM APPS.XX_LOAN_DETAILS
                   WHERE 1 = 1 -- AND TRUNC(EFFECTIVE_END_DATE) BETWEEN  '$from'  AND  '$to'
                         AND MAJOR_LOAN_TYPE = 'Short Term'--AND ORG_ID=223
                        
                 ) A
                 LEFT JOIN
                 (  SELECT TO_NUMBER (ADI.ATTRIBUTE2) LOAN_ID,
                           SUM (ADI.AMOUNT) PAY_AMT
                      FROM APPS.AP_INVOICES_ALL API,
                           APPS.AP_INVOICE_DISTRIBUTIONS_ALL ADI,
                           APPS.GL_CODE_COMBINATIONS_KFV GCK
                     WHERE     API.INVOICE_ID = ADI.INVOICE_ID
                           AND ADI.DIST_CODE_COMBINATION_ID =
                                  GCK.CODE_COMBINATION_ID
                           --and api.org_id=223
                           AND ADI.ATTRIBUTE3 = '1000'
                           AND ADI.ATTRIBUTE2 IS NOT NULL
                  GROUP BY TO_NUMBER (ADI.ATTRIBUTE2)) B
                    ON A.LOAN_ID = B.LOAN_ID
           WHERE     A.ORGANIZATION_NAME IS NOT NULL
                 AND NVL ( (NVL (A.LOAN_AMT, 0) - NVL (B.PAY_AMT, 0)), 0) > 0)
         Q,
         APPS.HR_OPERATING_UNITS P
   WHERE     P.ORGANIZATION_ID = Q.ORG_ID
   		 AND P.SET_OF_BOOKS_ID = 2021
         --AND ( :P_LEGAL_ENTITY IS NULL OR P.SET_OF_BOOKS_ID = :P_LEGAL_ENTITY)
         --AND ( :P_ORG_ID IS NULL OR Q.ORG_ID = :P_ORG_ID)
         --AND ( :P_BANK_ID IS NULL OR Q.BANK_ID = :P_BANK_ID)
         --AND ( :P_BANK_ACCOUNT IS NULL OR Q.BANK_ACCOUNT_NAME = :P_BANK_ACCOUNT)
         AND END_DATE > '28-FEB-2020'
         AND TRUNC (Q.END_DATE) BETWEEN '01-JUL-2020' AND '31-DEC-2022'--:P_FROM_DATE AND :P_TO_DATE ---------- PARAMETER-----
         AND (ROUND(LOAN_AMT) - ROUND(PAY_AMT)) > 0
ORDER BY 1,
         3,
         14,
         5,
         6