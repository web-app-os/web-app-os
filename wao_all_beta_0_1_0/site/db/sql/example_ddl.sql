-- Table: division

-- DROP TABLE division;
CREATE TABLE division
(
  id serial NOT NULL,
  name varchar(128),
  created_date timestamp with time zone default now(),
  updated_date timestamp with time zone default now(),
  del_flag boolean default false,
  CONSTRAINT division_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


-- Table: employee

-- DROP TABLE employee;
CREATE TABLE employee
(
  id serial NOT NULL,
  name varchar(128),
  entry_date date,
  division_id integer references division(id),
  created_date timestamp with time zone default now(),
  updated_date timestamp with time zone default now(),
  del_flag boolean default false,
  CONSTRAINT employee_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

