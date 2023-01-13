# sql-quer-price-check

SQL Query kainų tikrinimo ataskaitai paruošti.
- Duomenis ima iš 3-jų skirtingų duomenų bazių lentelių: Items, Transactions, Replenishment.
- Atfiltruoja reikiamus produktus pagal reikiamus požymius.
- Atfiltruoja naujausią pirkimo transakciją, jeigu ji nesenesnė kaip 1 metai.
- Paskaičiuoja pirkimo kainą po nuolaidos pagal naujausią pirkimo transakciją.
- Paskaičiuoja pardavimo kainą pagal nurodytas taisykles.
- Palygina esamą pardavimo kainą su paskaičiuota nauja pardavimo kaina.
- Pateikia duomenis, kai nėra likučio "K" (likutis užlaikytas dėl kainų pasikeitimo) ir einamosios bei paskaičiuotų kainų skirtumas yra didesnis nei 0,015ct.
