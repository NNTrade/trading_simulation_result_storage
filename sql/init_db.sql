-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA public IS 'standard public schema';

-- DROP SEQUENCE public.parameter_type_id_seq;

CREATE SEQUENCE public.parameter_type_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 32767
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.simulation_metric_id_seq;

CREATE SEQUENCE public.simulation_metric_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.simulation_parameter_id_seq;

CREATE SEQUENCE public.simulation_parameter_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.strategy_id_seq;

CREATE SEQUENCE public.strategy_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.strategy_parameter_id_seq;

CREATE SEQUENCE public.strategy_parameter_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public.strategy_v_id_seq;

CREATE SEQUENCE public.strategy_v_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;-- public.parameter_type definition

-- Drop table

-- DROP TABLE public.parameter_type;

CREATE TABLE public.parameter_type (
	id int2 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 32767 START 1 CACHE 1 NO CYCLE),
	"type" varchar(6) NULL, -- int|float|string
	CONSTRAINT parameter_type_pk PRIMARY KEY (id)
);
COMMENT ON TABLE public.parameter_type IS 'доступные типы параметров';

-- Column comments

COMMENT ON COLUMN public.parameter_type."type" IS 'int|float|string';


-- public.simulation definition

-- Drop table

-- DROP TABLE public.simulation;

CREATE TABLE public.simulation (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	"from" date NOT NULL,
	untill date NOT NULL,
	start_cap float4 NOT NULL,
	end_cap float4 NOT NULL,
	max_fall float4 NULL, -- local_min_extremum/local_max_extremum
	create_timestamp timestamptz NOT NULL,
	CONSTRAINT simulation_pk PRIMARY KEY (id)
);

-- Column comments

COMMENT ON COLUMN public.simulation.max_fall IS 'local_min_extremum/local_max_extremum';


-- public.strategy definition

-- Drop table

-- DROP TABLE public.strategy;

CREATE TABLE public.strategy (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	"name" varchar(50) NOT NULL, -- Название стратегии
	description varchar(255) NULL, -- Описание
	CONSTRAINT strategy_pk PRIMARY KEY (id),
	CONSTRAINT strategy_un UNIQUE (name)
);
COMMENT ON TABLE public.strategy IS 'список стратегий';

-- Column comments

COMMENT ON COLUMN public.strategy."name" IS 'Название стратегии';
COMMENT ON COLUMN public.strategy.description IS 'Описание';


-- public.strategy_v definition

-- Drop table

-- DROP TABLE public.strategy_v;

CREATE TABLE public.strategy_v (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	strategy_id int4 NOT NULL,
	"version" int4 NOT NULL, -- версия стратегии
	note text NULL, -- заметка к версии
	CONSTRAINT strategy_v_pk PRIMARY KEY (id),
	CONSTRAINT strategy_v_un UNIQUE (version, strategy_id),
	CONSTRAINT strategy_v_fk FOREIGN KEY (strategy_id) REFERENCES public.strategy(id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE public.strategy_v IS 'список версий одной и той же стратегии';

-- Column comments

COMMENT ON COLUMN public.strategy_v."version" IS 'версия стратегии';
COMMENT ON COLUMN public.strategy_v.note IS 'заметка к версии';


-- public.strategy_parameter definition

-- Drop table

-- DROP TABLE public.strategy_parameter;

CREATE TABLE public.strategy_parameter (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	strategy_ver_id int4 NOT NULL,
	"name" varchar(50) NULL, -- название парметра
	"type" int4 NOT NULL, -- тип значения
	desription varchar(255) NULL, -- описание
	def_value varchar(50) NULL, -- дефолтное значение
	CONSTRAINT strategy_parameter_pk PRIMARY KEY (id),
	CONSTRAINT strategy_parameter_un UNIQUE (strategy_ver_id, name),
	CONSTRAINT strategy_parameter_fk FOREIGN KEY ("type") REFERENCES public.parameter_type(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT strategy_parameter_fk_1 FOREIGN KEY (strategy_ver_id) REFERENCES public.strategy_v(id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE public.strategy_parameter IS 'список параметров в версии стратегии';

-- Column comments

COMMENT ON COLUMN public.strategy_parameter."name" IS 'название парметра';
COMMENT ON COLUMN public.strategy_parameter."type" IS 'тип значения';
COMMENT ON COLUMN public.strategy_parameter.desription IS 'описание';
COMMENT ON COLUMN public.strategy_parameter.def_value IS 'дефолтное значение';


-- public.simulation_parameter definition

-- Drop table

-- DROP TABLE public.simulation_parameter;

CREATE TABLE public.simulation_parameter (
	id int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	parameter_id int4 NOT NULL,
	simulation_id int4 NOT NULL,
	value varchar(50) NULL,
	CONSTRAINT simulation_parameter_pk PRIMARY KEY (id),
	CONSTRAINT simulation_parameter_un UNIQUE (simulation_id, parameter_id),
	CONSTRAINT simulation_parameter_fk FOREIGN KEY (parameter_id) REFERENCES public.strategy_parameter(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT simulation_parameter_fk_1 FOREIGN KEY (simulation_id) REFERENCES public.simulation(id) ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE public.simulation_parameter IS 'значение параметров при симуляции';