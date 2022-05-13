CREATE DATABASE store;

CREATE TABLE pet (
name    VARCHAR(20),
owner   VARCHAR(20),
species VARCHAR(20),
sex     CHAR(1)
);

INSERT INTO pet VALUES('FirstAdmin', 'password01', 'false', 'M');
INSERT INTO pet VALUES('SecondAdmin', 'password', 'true', 'F');
INSERT INTO pet VALUES('ThirdAdmin', 'password03', 'false', 'M');
INSERT INTO pet VALUES('FourthdAdmin', 'password04', 'true', 'F');
INSERT INTO pet VALUES('FifthAdmin', 'password05', 'false', 'M');
INSERT INTO pet VALUES('SixthdAdmin', 'password06', 'true', 'F');
