-- ============================================================
--  Pokemon Management System — Class Exercise
-- ============================================================

DROP DATABASE IF EXISTS pokemon_mgmt;
CREATE DATABASE pokemon_mgmt;
USE pokemon_mgmt;



-- ============================================================
--  PART 1 — CREATE TABLES
-- ============================================================

CREATE TABLE trainer (
    trainer_id    INT          NOT NULL AUTO_INCREMENT,
    trainer_name  VARCHAR(50)  NOT NULL,
    region        VARCHAR(50)  NOT NULL,
    badge_count   INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (trainer_id)
);

CREATE TABLE type (
    type_id    INT         NOT NULL AUTO_INCREMENT,
    type_name  VARCHAR(30) NOT NULL UNIQUE,
    PRIMARY KEY (type_id)
);

CREATE TABLE pokemon (
    pokemon_id    INT         NOT NULL AUTO_INCREMENT,
    pokemon_name  VARCHAR(50) NOT NULL,
    level         INT         NOT NULL,
    hp            INT         NOT NULL,
    trainer_id    INT         NOT NULL,   -- every pokemon MUST have a trainer
    PRIMARY KEY (pokemon_id),
    FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id)
);

-- Bridge / joining table for the many-to-many Pokemon <-> Type relationship
CREATE TABLE pokemon_type (
    pokemon_id  INT NOT NULL,
    type_id     INT NOT NULL,
    PRIMARY KEY (pokemon_id, type_id),              -- composite PK
    FOREIGN KEY (pokemon_id) REFERENCES pokemon(pokemon_id),
    FOREIGN KEY (type_id)    REFERENCES type(type_id)
);

CREATE TABLE battle (
    battle_id    INT         NOT NULL AUTO_INCREMENT,
    battle_date  DATE        NOT NULL,
    location     VARCHAR(100) NOT NULL,
    outcome      ENUM('Win','Loss','Draw') NOT NULL,
    trainer_id   INT         NOT NULL,   -- every battle MUST involve a trainer
    PRIMARY KEY (battle_id),
    FOREIGN KEY (trainer_id) REFERENCES trainer(trainer_id)
);



-- ============================================================
--  PART 2 — INSERT DUMMY DATA
-- ============================================================

-- 6 Trainers
INSERT INTO trainer (trainer_name, region, badge_count) VALUES
    ('Ash',      'Kanto',  8),
    ('Misty',    'Kanto',  6),
    ('Brock',    'Kanto',  7),
    ('May',      'Hoenn',  5),
    ('Gary',     'Kanto',  8),
    ('Dawn',     'Sinnoh', 4);

-- 6 Types
INSERT INTO type (type_name) VALUES
    ('Fire'),
    ('Water'),
    ('Grass'),
    ('Electric'),
    ('Flying'),
    ('Rock');

-- 12 Pokemon spread across trainers
-- Ash (trainer_id = 1)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Pikachu',    35, 80,  1),   -- pokemon_id 1
    ('Charizard',  50, 120, 1),   -- pokemon_id 2
    ('Bulbasaur',  20, 65,  1);   -- pokemon_id 3

-- Misty (trainer_id = 2)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Starmie',    40, 95,  2),   -- pokemon_id 4
    ('Psyduck',    18, 60,  2);   -- pokemon_id 5

-- Brock (trainer_id = 3)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Onix',       35, 90,  3),   -- pokemon_id 6
    ('Geodude',    22, 70,  3);   -- pokemon_id 7

-- May (trainer_id = 4)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Blaziken',   45, 110, 4),   -- pokemon_id 8
    ('Beautifly',  28, 60,  4);   -- pokemon_id 9

-- Gary (trainer_id = 5)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Blastoise',  55, 130, 5),   -- pokemon_id 10
    ('Eevee',      15, 55,  5);   -- pokemon_id 11

-- Dawn (trainer_id = 6)
INSERT INTO pokemon (pokemon_name, level, hp, trainer_id) VALUES
    ('Piplup',     12, 50,  6);   -- pokemon_id 12

-- NOTE: Dawn (trainer_id = 6) has only 1 pokemon — useful for varied results.
-- NOTE: No pokemon assigned to trainer? Not possible per spec (trainer_id NOT NULL).

-- 10+ Pokemon-Type assignments (some pokemon have two types)
INSERT INTO pokemon_type (pokemon_id, type_id) VALUES
    (1,  4),   -- Pikachu    → Electric
    (2,  1),   -- Charizard  → Fire
    (2,  5),   -- Charizard  → Flying   (two types)
    (3,  3),   -- Bulbasaur  → Grass
    (4,  2),   -- Starmie    → Water
    (5,  2),   -- Psyduck    → Water
    (6,  6),   -- Onix       → Rock
    (7,  6),   -- Geodude    → Rock
    (8,  1),   -- Blaziken   → Fire
    (9,  3),   -- Beautifly  → Grass
    (9,  5),   -- Beautifly  → Flying   (two types)
    (10, 2),   -- Blastoise  → Water
    (12, 2);   -- Piplup     → Water
-- NOTE: Eevee (pokemon_id 11) has NO type assigned — useful for Q3 (LEFT JOIN)

-- 8 Battles spread across trainers, varied outcomes
-- NOTE: Dawn (trainer_id = 6) has NO battles — useful for Q5/Q6
INSERT INTO battle (battle_date, location, outcome, trainer_id) VALUES
    ('2024-01-10', 'Pallet Town',    'Win',  1),   -- Ash
    ('2024-02-14', 'Cerulean City',  'Loss', 1),   -- Ash
    ('2024-03-05', 'Cerulean City',  'Win',  2),   -- Misty
    ('2024-04-20', 'Pewter City',    'Win',  3),   -- Brock
    ('2024-05-15', 'Pewter City',    'Draw', 3),   -- Brock
    ('2024-06-01', 'Petalburg City', 'Win',  4),   -- May
    ('2024-07-22', 'Viridian City',  'Win',  5),   -- Gary
    ('2024-08-30', 'Viridian City',  'Win',  5);   -- Gary



-- ============================================================
--  PART 3 — SELECT QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- Q1: List all trainers and the Pokemon Name of their Pokemon.
--     Include trainers who do NOT own any Pokemon.
-- ------------------------------------------------------------
SELECT
    trainer.trainer_name,
    pokemon.pokemon_name
FROM trainer
LEFT JOIN pokemon ON pokemon.trainer_id = trainer.trainer_id;







-- ------------------------------------------------------------
-- Q2: List all trainers and the total number of Pokemon they own.
-- ------------------------------------------------------------
SELECT
    trainer.trainer_name,
    COUNT(pokemon.pokemon_id) AS pokemon_count
FROM trainer
LEFT JOIN pokemon ON pokemon.trainer_id = trainer.trainer_id
GROUP BY trainer.trainer_id, trainer.trainer_name
ORDER BY pokemon_count DESC;





-- ------------------------------------------------------------
-- Q3: List all Pokemon and their Type Name(s).
--     Include Pokemon that have NOT been assigned any type.
-- ------------------------------------------------------------
SELECT
    pokemon.pokemon_name,
    type.type_name
FROM pokemon
LEFT JOIN pokemon_type ON pokemon_type.pokemon_id = pokemon.pokemon_id
LEFT JOIN type         ON type.type_id            = pokemon_type.type_id;





-- ------------------------------------------------------------
-- Q4: Find all Pokemon with Level > 30, along with the Trainer Name.
-- ------------------------------------------------------------
SELECT
    pokemon.pokemon_name,
    pokemon.level,
    trainer.trainer_name
FROM pokemon
LEFT JOIN trainer ON trainer.trainer_id = pokemon.trainer_id
WHERE pokemon.level > 30
ORDER BY pokemon.level DESC;

-- ------------------------------------------------------------
-- Q5: List each trainer and total battles participated in.
--     Include trainers with no battles, showing 0.
-- ------------------------------------------------------------

SELECT
    trainer.trainer_name,
    COUNT(battle.battle_id) AS battle_count

FROM trainer
LEFT JOIN battle ON battle.trainer_id = trainer.trainer_id
GROUP BY trainer.trainer_id, trainer.trainer_name
ORDER BY battle_count DESC;

SELECT
    battle.battle_id,
    battle.battle_date,
    battle.location,
    trainer.trainer_name

FROM battle
LEFT JOIN trainer ON trainer.trainer_id = battle.trainer_id
WHERE battle.outcome = 'Win'
ORDER BY battle.battle_date;

SELECT
    trainer.trainer_name,
    COUNT(pokemon.pokemon_id) AS pokemon_count
FROM trainer
LEFT JOIN pokemon ON pokemon.trainer_id = trainer.trainer_id
GROUP BY trainer.trainer_id, trainer.trainer_name
ORDER BY pokemon_count DESC
LIMIT 1;