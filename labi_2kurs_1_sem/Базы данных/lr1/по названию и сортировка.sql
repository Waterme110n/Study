SELECT        Заказы.*, Заказчик AS Expr1, Дата_поставки AS Expr2
FROM            Заказы
WHERE        (Заказчик = 'ferari')
ORDER BY Expr2