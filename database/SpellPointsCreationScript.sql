SELECT * FROM caster;
SELECT * FROM caster_spell;
SELECT * FROM player;
SELECT * FROM spell;

create table player
(
	player_id serial primary key,
	username varchar(50) NOT NULL,
	passphrase varchar(25) NOT NULL,
	current_points integer,
	current_level integer,
	caster_id integer
);

create table caster
(
	caster_id serial primary key,
	caster_name varchar(20) NOT NULL,
	half_caster boolean NOT NULL
);

create table caster_spell
(
	caster_id integer NOT NULL,
	spell_id integer NOT NULL,
	primary key (caster_id, spell_id)
);

create table spell
(
	spell_id serial primary key,
	spell_name varchar(50) NOT NULL,
	spell_level integer NOT NULL
);

ALTER TABLE player ADD CONSTRAINT FK_player_to_caster
	FOREIGN KEY (caster_id) 
		REFERENCES caster (caster_id) ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE caster_spell ADD CONSTRAINT FK_caster_to_spell_list
	FOREIGN KEY (caster_id)
		REFERENCES caster (caster_id) ON DELETE CASCADE ON UPDATE CASCADE;
		
ALTER TABLE caster_spell ADD CONSTRAINT FK_spell_to_caster_list
	FOREIGN KEY (spell_id)
		REFERENCES spell (spell_id) ON DELETE CASCADE ON UPDATE CASCADE;


-- Procedure used by JDBC to insert into the caster_spell list
CREATE or REPLACE PROCEDURE insert_caster_spell_list(caster_id int4, spell_list int4[])
	LANGUAGE plpgsql 
	AS $$
	DECLARE
		spell_count int4;
		current_spell int4;
	BEGIN 
		--Counts number of spell references to be inserted
		spell_count := array_length(spell_list, 1);
	
		LOOP
			EXIT WHEN spell_count = 0; --Ends loop if no spells left
			--Sets current spell from list
			current_spell := spell_list[spell_count];
		
			INSERT INTO caster_spell VALUES
			(caster_id, current_spell);
	
			spell_count := spell_count - 1;
			
		END LOOP;
	
	END;$$

--Function used by trigger to check on caster delete, if a spell now has no casters. 
--If it doesn't have any casters, delete the spell.
CREATE or REPLACE FUNCTION check_spell_last_caster()
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS $$
	DECLARE 
		id_count int4;
		spell_ids int4[];
		current_spell int4;
	BEGIN 
		--Count number of spells affected by delete
		id_count := (SELECT COUNT(DISTINCT(cs.spell_id)) FROM caster_spell cs
						WHERE cs.caster_id = OLD.caster_id);
	
		--Read spell_id's into array
		spell_ids := ARRAY(
		SELECT DISTINCT(cs.spell_id) FROM caster_spell cs
		WHERE cs.caster_id = OLD.caster_id);
		
		LOOP
			EXIT WHEN id_count = 0; --Ends loop if no spells left
			current_spell := spell_ids[id_count];
			
			--Checks for if spell has any references left 
			IF (0 = (SELECT COUNT(*) FROM caster_spell cs WHERE cs.spell_id = current_spell AND cs.caster_id <> OLD.caster_id)) THEN
			
				--Deletes spell if no references found
				DELETE FROM spell s
				WHERE s.spell_id = current_spell;
			
			END IF;
		
			id_count := id_count-1;
		
		END LOOP;
		RETURN OLD;
	END;$$


CREATE TRIGGER caster_only_spell_check
	BEFORE DELETE ON caster
	FOR EACH ROW
	EXECUTE PROCEDURE check_spell_last_caster();
	


-- Useful select statements for certain verifications.
SELECT * FROM caster;
SELECT * FROM caster_spell;
SELECT * FROM player;
SELECT * FROM spell;

INSERT INTO spell VALUES (0, 'Placeholder', 0);

INSERT INTO caster VALUES (1, 'Bard', false);
INSERT INTO caster VALUES (2, 'Cleric', false);
INSERT INTO caster VALUES (3, 'Druid', false);
INSERT INTO caster VALUES (4, 'Paladin', true);
INSERT INTO caster VALUES (5, 'Ranger', true);
INSERT INTO caster VALUES (6, 'Sorcerer', false);
INSERT INTO caster VALUES (7, 'Warlock', true);
INSERT INTO caster VALUES (8, 'Wizard', false);
INSERT INTO caster VALUES (9, 'Artificer', false);

SELECT c.caster_id, c.caster_name, c.half_caster, cs.spell_id FROM caster c 
LEFT JOIN caster_spell cs 
ON c.caster_id = cs.caster_id;

SELECT * FROM caster c, caster_spell cs, spell s
WHERE c.caster_id = cs.caster_id
AND cs.spell_id = s.spell_id
AND c.caster_id = 2;
	
SELECT c.caster_id, c.caster_name, c.half_caster, cs.spell_id FROM caster c
INNER JOIN caster_spell cs
ON c.caster_id = cs.caster_id;
WHERE c.caster_id = 1;

SELECT c.caster_name, s.spell_name FROM caster c
LEFT JOIN caster_spell cs
ON c.caster_id = cs.caster_id
LEFT JOIN spell s
ON cs.spell_id = s.spell_id
WHERE c.caster_name = 'bard';