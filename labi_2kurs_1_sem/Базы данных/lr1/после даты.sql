SELECT        Заказы.*, Дата_поставки AS Expr1
FROM            Заказы
WHERE        (Дата_поставки > CONVERT(DATETIME, '2023-09-27 00:00:00', 102))