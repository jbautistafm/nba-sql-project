-- Consultas del proyecto (MySQL 8)
-- Pregunta: ¿qué jugador ha metido más triples en proporción al tiempo jugado?
USE nba_triples;

-- 1. Ranking de triples por cada 36 minutos (mínimo 5.000 minutos en la carrera)
SELECT j.nombre,
       SUM(e.minutos) AS minutos,
       SUM(e.triples) AS triples,
       ROUND(SUM(e.triples) * 36 / SUM(e.minutos), 2) AS triples_por_36
FROM estadisticas e
JOIN jugadores j ON j.player_id = e.player_id
GROUP BY j.player_id, j.nombre
HAVING SUM(e.minutos) >= 5000
ORDER BY triples_por_36 DESC
LIMIT 10;

-- 2. El mismo ranking con un mínimo de 20.000 minutos (CTE + RANK)
--    Cambia el 20000 por 5000 o 10000 para comparar
WITH carrera AS (
    SELECT player_id,
           SUM(minutos) AS minutos,
           SUM(triples) * 36 / SUM(minutos) AS triples_por_36
    FROM estadisticas
    GROUP BY player_id
    HAVING SUM(minutos) >= 20000
)
SELECT RANK() OVER (ORDER BY c.triples_por_36 DESC) AS puesto,
       j.nombre, c.minutos, ROUND(c.triples_por_36, 2) AS triples_por_36
FROM carrera c
JOIN jugadores j ON j.player_id = c.player_id
ORDER BY puesto
LIMIT 5;

-- 3. Los que más triples han metido en total, con su ritmo por 36 minutos
SELECT j.nombre,
       SUM(e.triples) AS triples_totales,
       ROUND(SUM(e.triples) * 36 / SUM(e.minutos), 2) AS triples_por_36
FROM estadisticas e
JOIN jugadores j ON j.player_id = e.player_id
GROUP BY j.player_id, j.nombre
ORDER BY triples_totales DESC
LIMIT 10;

-- 4. Evolución del triple por décadas en toda la liga
SELECT (temporada DIV 10) * 10 AS decada,
       ROUND(SUM(triples) * 36 / SUM(minutos), 2) AS triples_por_36,
       ROUND(SUM(triples) / SUM(triples_intentados), 3) AS acierto
FROM estadisticas
GROUP BY decada
ORDER BY decada;

-- 5. Posiciones de los 50 mejores tiradores por minuto
WITH top50 AS (
    SELECT player_id,
           SUM(triples) * 36 / SUM(minutos) AS triples_por_36
    FROM estadisticas
    GROUP BY player_id
    HAVING SUM(minutos) >= 5000
    ORDER BY triples_por_36 DESC
    LIMIT 50
)
SELECT j.posicion, COUNT(*) AS jugadores
FROM top50 t
JOIN jugadores j ON j.player_id = t.player_id
GROUP BY j.posicion
ORDER BY jugadores DESC;

-- 6. Hipótesis 2: ¿al aumentar la altura se cogen más rebotes?
--    Rebotes por 36 minutos por franjas de altura de 2 pulgadas (unos 5 cm)
WITH carrera AS (
    -- rebotes por 36 minutos de toda la carrera de cada jugador
    SELECT e.player_id,
           j.altura_pulgadas,
           SUM(e.rebotes) * 36 / SUM(e.minutos) AS rebotes_por_36
    FROM estadisticas e
    JOIN jugadores j ON j.player_id = e.player_id
    GROUP BY e.player_id, j.altura_pulgadas
    HAVING SUM(e.minutos) >= 5000
),
franjas AS (
    -- agrupo las alturas de 2 en 2 pulgadas (unos 5 cm)
    SELECT FLOOR(altura_pulgadas / 2) * 2 AS franja_pulgadas,
           COUNT(*) AS jugadores,
           AVG(rebotes_por_36) AS media,
           STDDEV(rebotes_por_36) AS desviacion,
           MIN(rebotes_por_36) AS minimo,
           MAX(rebotes_por_36) AS maximo
    FROM carrera
    GROUP BY franja_pulgadas
    HAVING COUNT(*) >= 10   -- quito las franjas con menos de 10 jugadores, salen medias poco fiables
)
SELECT franja_pulgadas,
       ROUND(franja_pulgadas * 2.54) AS desde_cm,
       jugadores,
       ROUND(media, 2) AS rebotes_por_36,
       ROUND(desviacion, 2) AS desviacion,
       ROUND(minimo, 2) AS minimo,
       ROUND(maximo, 2) AS maximo,
       -- LAG mira la franja anterior: si sale positivo, esta franja coge más rebotes
       ROUND(media - LAG(media) OVER (ORDER BY franja_pulgadas), 2) AS cambio_vs_anterior
FROM franjas
ORDER BY franja_pulgadas;
