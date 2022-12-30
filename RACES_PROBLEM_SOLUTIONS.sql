CREATE TABLE RACE(
	race_id SERIAL PRIMARY KEY,
	race_competition VARCHAR(20),
	race_sportsman VARCHAR(20),
	race_time INTEGER
)
INSERT INTO RACE(race_competition,race_sportsman,race_time) VALUES
	('competition_1','John',14),
	('competition_1','Me',12),
	('competition_1','Alex',25),
	('competition_2','Sara',10),
	('competition_2','Mery',20),
	('competition_2','Kim',35),
	('competition_2','Kate',33),
	('competition_3','John',34),
	('competition_3','Me',12),
	('competition_3','James',85),
	('competition_4','Cris',40),
	('competition_4','Ken',30),
	('competition_4','Karen',37),
	('competition_4','Met',36);


--////////////////////////////////////SOLUTION WITHOUT WINDOW FUNCTIONS///////////////////////////////////////

--===========================================================================================
--VIEWS
--===========================================================================================

-- ordered data VIEW

CREATE VIEW data_table AS 
SELECT *
FROM race
ORDER BY race_competition,race_time

-- output without places

CREATE VIEW TOP_THREE AS 
SELECT *
FROM data_table
WHERE race_time IN (SELECT race_time
				    FROM data_table as sq_t
					WHERE data_table.race_competition = sq_t.race_competition
				    LIMIT 3)
ORDER BY race_competition,race_time

						 
-- ===========================================================================================
--COMPLETE CODE
-- ===========================================================================================

(SELECT TOP_THREE.*,'1' AS RACE_SPORTSMAN_PLACE
FROM TOP_THREE
WHERE TOP_THREE.race_time = (SELECT MIN(race_time)
						     FROM TOP_THREE as sq
						     WHERE TOP_THREE.race_competition = sq.race_competition))				   
UNION ALL
(SELECT TOP_THREE.*,'3'
FROM TOP_THREE
WHERE TOP_THREE.race_time = (SELECT MAX(race_time)
						     FROM TOP_THREE as sq
						     WHERE TOP_THREE.race_competition = sq.race_competition))		 			   
UNION ALL
(SELECT TOP_THREE.*,'2'
FROM TOP_THREE
WHERE TOP_THREE.race_time = (SELECT race_time
						   FROM TOP_THREE as sq
						   WHERE TOP_THREE.race_competition = sq.race_competition
						   AND race_time != (SELECT MAX(race_time)
						                     FROM TOP_THREE as sq
						                     WHERE TOP_THREE.race_competition = sq.race_competition)
						   AND race_time != (SELECT MIN(race_time)
						                     FROM TOP_THREE as sq
						                     WHERE TOP_THREE.race_competition = sq.race_competition)))
ORDER BY race_competition,race_time



--===========================================================================================
--CODE WITHOUT VIEWS
--===========================================================================================


--////////////////////////////////////SOLUTION WITHIN FUNCTION USING SUBQUERY///////////////////////////////////////

CREATE OR REPLACE FUNCTION RETURN_RANKING_TABLE()
RETURNS TABLE (
    race_id integer ,
    race_competition character varying(200),
    race_sportsman character varying(200),
    race_time integer,
    race_sportsmen_rank bigint
) AS
$$
DECLARE 
     ranks bigint[] := array[1,2,3];
BEGIN
     RETURN QUERY
	 SELECT *
     FROM (SELECT race.race_id,race.race_competition,race.race_sportsman,race.race_time,
           DENSE_RANK() OVER (PARTITION BY race.race_competition
           ORDER BY race.race_time ASC) as sportsmen_rank
     FROM race) AS total_ranking_table
     WHERE total_ranking_table.sportsmen_rank  = any(ranks);
END;
$$
LANGUAGE plpgsql

SELECT (RETURN_RANKING_TABLE()).*;


--////////////////////////////////////SOLUTION WITHIN FUNCTION USING VIEW///////////////////////////////////////


CREATE OR REPLACE FUNCTION RETURN_RANKING_TABLE_VIEW()
RETURNS TABLE (
    race_id integer ,
    race_competition character varying(200),
    race_sportsman character varying(200),
    race_time integer,
    sportsmen_rank bigint
)AS
$$
BEGIN
   RETURN QUERY WITH total_ranking_table AS (
    SELECT race.race_id,race.race_competition,race.race_sportsman,race.race_time,
    DENSE_RANK() OVER (PARTITION BY race.race_competition
                       ORDER BY race.race_time ASC) as sportsmen_rank
    FROM race
   )
   SELECT *
   FROM total_ranking_table
   WHERE total_ranking_table.sportsmen_rank IN (1,2,3);
END;
$$
LANGUAGE plpgsql




SELECT (RETURN_RANKING_TABLE_VIEW()).*;


--////////////////////////////////////SOLUTION VIEW///////////////////////////////////////


CREATE OR REPLACE VIEW ranking_table AS (
SELECT race_id,race_competition,race_sportsman,race_time, 
DENSE_RANK() OVER (PARTITION BY race_competition
				   ORDER BY race_time ASC) as sportsmen_rank
FROM race)

SELECT * 
FROM ranking_table
WHERE sportsmen_rank IN (1,2,3);


--////////////////////////////////////SOLUTION USING SUBQUERY///////////////////////////////////////


SELECT *
FROM (SELECT race.race_id,race.race_competition,race.race_sportsman,race.race_time,
      DENSE_RANK() OVER (PARTITION BY race.race_competition
                         ORDER BY race.race_time ASC) as sportsmen_rank
FROM race) AS total_ranking_table
WHERE total_ranking_table.sportsmen_rank IN (1,2,3);


 




