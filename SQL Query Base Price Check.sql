SELECT * FROM
(SELECT
	CONVERT(int, T0.ItemNo2) as ItemNo,
	ItemDescription1 as Description,
	T0.ItemGroup,
	T4.Planner,
	T4.Buyer,
	PrincipalIdDescription as Nick,
	T0.StockingType as ST,
	CONVERT(varchar, T3.LatestPODate, 102) as LastPODate,
	T3.LatestPO as LastPO,
	T3.SumQty as LastQty,
	T3.LastPrice as LastPurchaseCIP,
	T3.PITMDQTY as LastDeclaredDsc,
	T3.LastNetPrice as LastNetPrice,
	T0.BasePrice as CurrentBasePrice,
	T3.CalcBasePrice as CalcBasePrice,
	T4.StockQty as AQTY,
	T4.StockQtyK as KQTY
FROM
	WH_RAW_LT.dbo.Items T0
JOIN
	(SELECT
		T1.ItemNo2,
		LatestPODate,
		LatestPO,
		SUM(TransactionQuantity) as SumQty,
		AVG(AgreementPrice) as LastPrice,
		AVG(PurchCompens) as PITMDQTY,
		AVG(AgreeMentPrice) + AVG(PurchCompens) as LastNetPrice,
		CASE
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 0 AND 1.86) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.18,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 1.87 AND 2.89) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.16,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 2.9 AND 5.63) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.09,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 5.64 AND 7.24) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.08,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 7.25 AND 15.51) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.07,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 15.52 AND 19.74) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.06,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) BETWEEN 19.75 AND 263.29) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens))*1.05,2)
			WHEN (AVG(AgreeMentPrice) + AVG(PurchCompens) >= 263.3) THEN ROUND((AVG(AgreeMentPrice) + AVG(PurchCompens)) + 14.48,2)
			ELSE 0
		END as CalcBasePrice
	 FROM WH_OLAP.dbo.Transactions T2
	 INNER JOIN
		(SELECT ItemNo2,
			MAX(TransactionDate) as LatestPODate,
			MAX(OrderNumber) as LatestPO
		FROM
			WH_OLAP.dbo.Transactions
		WHERE
			Company = '00701'
			AND
			OrderType  = 'OP'
			AND
			GlClassCode = 'T001'
			AND
			DocumentType = 'OV'
			AND
			OrderNumber >= 6000000
			AND 
			TransactionDate > DATEADD(year,-1,GETDATE())
		GROUP BY ItemNo2) T1
	 ON T1.ItemNo2 = T2.ItemNo2 AND T1.LatestPO = OrderNumber AND T1.LatestPoDate = TransactionDate
	 GROUP BY T1.ItemNo2, LatestPODate, LatestPO) T3
ON T0.ItemNo2 = T3.ItemNo2
JOIN
	(SELECT
		*
	 FROM 
	 	STAT.dbo.LT_Replenishment) T4 
ON T0.ItemNo2 = T4.ItemNo2
WHERE 
	(T4.ProductClass = 'RPV' OR T4.ProductClass = 'OTC')
	AND
	(T4.Supplier_Type = 'P' OR T4.Supplier_Type = 'T' OR T4.Supplier_Type = 'S')
	AND 
	T4.ProductSubgroup = 'NE'
	AND
	T0.BasePrice != T3.CalcBasePrice) T5
WHERE
	T5.KQTY IS NULL 
	AND
    T5.CurrentBasePrice != T5.CalcBasePrice
    AND
    ABS(T5.CurrentBasePrice - T5.CalcBasePrice) >= 0.015
   ;

