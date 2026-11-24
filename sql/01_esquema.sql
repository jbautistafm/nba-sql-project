-- Esquema de la base de datos nba_triples (MySQL)
-- Tres tablas: jugadores, equipos y estadisticas

DROP TABLE IF EXISTS estadisticas;
DROP TABLE IF EXISTS jugadores;
DROP TABLE IF EXISTS equipos;

-- Un jugador por fila
CREATE TABLE jugadores (
    player_id         VARCHAR(12)  PRIMARY KEY,
    nombre            VARCHAR(60)  NOT NULL,
    posicion          VARCHAR(5),
    altura_pulgadas   INT,
    peso_libras       INT,
    fecha_nacimiento  DATE,
    universidades     VARCHAR(150),
    primera_temporada INT,
    ultima_temporada  INT,
    hall_of_fame      BOOLEAN
);

-- Un equipo por temporada (algunos cambiaron de nombre o de ciudad)
CREATE TABLE equipos (
    temporada     INT,
    equipo        VARCHAR(5),
    nombre_equipo VARCHAR(60),
    playoffs      BOOLEAN,
    PRIMARY KEY (temporada, equipo)
);

-- Una fila por jugador, temporada y equipo
CREATE TABLE estadisticas (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    player_id              VARCHAR(12) NOT NULL,
    temporada              INT NOT NULL,
    equipo                 VARCHAR(5) NOT NULL,
    edad                   INT,
    posicion               VARCHAR(5),
    partidos               INT,
    titular                INT,
    minutos                INT,
    triples                INT,
    triples_intentados     INT,
    tiros_campo            INT,
    tiros_campo_intentados INT,
    puntos                 INT,
    rebotes_ofensivos      INT,
    rebotes_defensivos     INT,
    rebotes                INT,
    FOREIGN KEY (player_id) REFERENCES jugadores(player_id),
    FOREIGN KEY (temporada, equipo) REFERENCES equipos(temporada, equipo)
);
