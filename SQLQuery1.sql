CREATE DATABASE ControleAcademico;

CREATE TABLE Aluno (
	RA int NOT NULL,  
	Nome varchar(50) NOT NULL
	CONSTRAINT PK_Aluno PRIMARY KEY (RA)
);

CREATE TABLE Disciplina (
	Sigla char(3) NOT NULL,
	Nome varchar(20) NOT NULL,
	Carga_Horaria int NOT NULL
	CONSTRAINT PK_Disciplina PRIMARY KEY (Sigla)
);

CREATE TABLE Matricula (
	RA int NOT NULL,
	Sigla char(3) NOT NULL,
	Data_Ano int NOT NULL,
	Data_Semestre int NOT NULL,
	Falta int,
	N1 float,
	N2 float,
	Sub float,
	Media float,
	Situacao varchar(30)

	CONSTRAINT FK_Matricula_Aluno FOREIGN KEY (RA) REFERENCES Aluno (RA),
	CONSTRAINT FK_Matricula_Disciplina FOREIGN KEY (Sigla) REFERENCES Disciplina (Sigla),
	PRIMARY KEY (RA, Sigla, Data_Ano, Data_Semestre)
); 
GO

CREATE TRIGGER tgr_UpdateMatricula
ON Matricula
AFTER UPDATE
AS 
BEGIN 
	DECLARE 
	@RA int,
	@N1 float,
	@N2 float,
	@SUB float,
	@MEDIA float,
	@FALTA int,
	@CARGA_HORARIA int,
	@SIGLA char(3),
	@DATA_ANO int,
	@DATA_SEMESTRE int


	-- Pega os dados que foram inseridos 
	SELECT @SIGLA = SIGLA, @RA = RA, @DATA_ANO = Data_Ano, @DATA_SEMESTRE = Data_Semestre FROM INSERTED; 
    
	SELECT @MEDIA= Media, @N1 = N1, @N2 = N2, @SUB = Sub, @Falta = Falta FROM Matricula 
		WHERE RA = @RA AND Sigla = @SIGLA AND Data_Ano = @DATA_ANO AND Data_Semestre = @DATA_SEMESTRE;

	SELECT @CARGA_HORARIA = Carga_Horaria FROM Disciplina WHERE SIGLA = @SIGLA;

	-- Faz o calculo de media
	IF(@SUB IS NOT NULL AND @N1 > @N2) -- verifica se a SUB nao e nulo e se N1 > N2
		SET @MEDIA = ((@SUB + @N1) / 2); -- Calcula media com SUB e N1
	ELSE IF (@SUB IS NOT NULL AND @N1 < @N2) -- verifica se a SUB nao e nulo e se N1 < N2
		SET @MEDIA = ((@SUB + @N2) / 2); -- Calcula media com SUB e N2
	ELSE
		SET @MEDIA = ((@N1 + @N2) / 2); -- Calcula a media normal, sem considerar a SUB

	
	IF (@FALTA >= ((@CARGA_HORARIA)*0.25))
	UPDATE Matricula SET Situacao = 'REPROVADO POR FALTA', Media = @MEDIA
		WHERE RA = @RA AND Sigla = @SIGLA AND Data_Ano = @DATA_ANO AND Data_Semestre = @DATA_SEMESTRE;
	ELSE IF (@MEDIA >= 5)
	UPDATE Matricula SET Situacao = 'APROVADO', Media = @MEDIA
		WHERE RA = @RA AND Sigla = @SIGLA AND Data_Ano = @DATA_ANO AND Data_Semestre = @DATA_SEMESTRE;
	ELSE
	UPDATE Matricula SET Situacao = 'REPROVADO POR NOTA', Media = @MEDIA
		WHERE RA = @RA AND Sigla = @SIGLA AND Data_Ano = @DATA_ANO AND Data_Semestre = @DATA_SEMESTRE;
END 
GO

CREATE TRIGGER tgr_Rematricula
ON Matricula
AFTER UPDATE
AS 
IF (UPDATE(Situacao))
BEGIN 
	DECLARE 
	@SITUACAO varchar(30),
	@RA int,
	@SIGLA char(3),
	@DATA_ANO int,
	@DATA_SEMESTRE int,
	@MEDIA int,
	@SUB int

	SELECT @SITUACAO = Situacao, @SIGLA = SIGLA, @RA = RA, @DATA_ANO = Data_Ano, @DATA_SEMESTRE = Data_Semestre, @MEDIA = Media, @SUB = Sub FROM INSERTED; 

	IF(((@SITUACAO = 'REPROVADO POR FALTA') OR (@SITUACAO = 'REPROVADO POR NOTA')) AND ((@MEDIA IS NOT NULL) AND (@SUB IS NOT NULL)))
		INSERT INTO Matricula (RA, Sigla, Data_Ano, Data_Semestre, Falta)
			VALUES  (@RA, @SIGLA, 2022, @DATA_SEMESTRE, 0);    
END 
GO

INSERT INTO Aluno(Ra, Nome)
Values	(1, 'Ana'),
		(2,'Beatriz'),
		(3, 'Bruno'),
		(4, 'Bernardo'),
		(5, 'Carol'), 
		(6, 'Caio'),
		(7, 'Daniela'),
		(8, 'Everton'),
		(9, 'Felipe'), 
		(10, 'Fernanda');

SELECT* FROM Aluno

INSERT INTO Disciplina (Sigla, Nome, Carga_Horaria)
VALUES ('ES', 'Eng. de Software', 80),
		('POO', 'Prog. Ori. Objetos', 80),
		('BDO', 'Banco de Dados', 80),
		('ADM', 'Administração', 40), 
		('LOG', 'Lógica', 40), 
		('ING', 'Inglês', 40), 
		('MAT', 'Matemática', 40), 
		('ECO', 'Economia', 40),
		('PRW', 'Programação Web', 80), 
		('CAL', 'Cálculo', 80); 

SELECT* FROM Disciplina

INSERT INTO Matricula (RA, Sigla, Data_Ano, Data_Semestre, Falta)
VALUES 
		(1, 'ES', 2021, 1, 0), 
		(1, 'POO',2021, 2, 0 ), 
		(2, 'BDO', 2021, 1, 0),
		(2, 'ADM', 2021, 2,0 ),
		(3, 'LOG',2021, 1, 0), 
		(3, 'ING', 2021, 2, 0), 
		(4, 'MAT', 2021, 1, 0), 
		(4, 'ECO', 2021, 2, 0), 
		(5, 'PRW', 2021, 1,0 ), 
		(5, 'CAL', 2021, 2,0); 

DELETE FROM Matricula
SELECT *FROM Matricula
GO 

UPDATE Matricula
SET N1 = 1
WHERE RA = 1 AND Sigla = 'ES'

UPDATE Matricula
SET N2 = 3
WHERE RA = 1 AND Sigla = 'ES'

UPDATE Matricula
SET N1 = 2
WHERE RA = 1 AND Sigla = 'POO'

UPDATE Matricula
SET N2 = 3
WHERE RA = 1 AND Sigla = 'POO'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =1 AND Sigla = 'ES'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =1 AND Sigla = 'POO'

SELECT *FROM Matricula

UPDATE Matricula
SET N1 = 8
WHERE RA = 2 AND Sigla = 'BDO'

UPDATE Matricula
SET N2 = 9
WHERE RA = 2 AND Sigla = 'BDO'

UPDATE Matricula
SET N1 = 5
WHERE RA = 2 AND Sigla = 'ADM'

UPDATE Matricula
SET N2 = 7
WHERE RA = 2 AND Sigla = 'ADM'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =2 AND Sigla = 'BDO'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =2 AND Sigla = 'ADM'

UPDATE Matricula
SET N1 = 1
WHERE RA = 3 AND Sigla = 'LOG'

UPDATE Matricula
SET N2 = 1
WHERE RA = 3 AND Sigla = 'LOG'

UPDATE Matricula
SET N1 = 3
WHERE RA = 3 AND Sigla = 'ING'

UPDATE Matricula
SET N2 = 3
WHERE RA = 3 AND Sigla = 'ING'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =3 AND Sigla = 'LOG'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =3 AND Sigla = 'ING'

UPDATE Matricula
SET N1 = 2
WHERE RA = 4 AND Sigla = 'MAT'

UPDATE Matricula
SET N2 = 2
WHERE RA = 4 AND Sigla = 'MAT'

UPDATE Matricula
SET N1 = 9
WHERE RA = 4 AND Sigla = 'ECO'

UPDATE Matricula
SET N2 = 7
WHERE RA = 4 AND Sigla = 'ECO'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =4 AND Sigla = 'MAT'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =4 AND Sigla = 'ECO'

UPDATE Matricula
SET N1 = 9
WHERE RA = 5 AND Sigla = 'PRW'

UPDATE Matricula
SET N2 = 1
WHERE RA = 5 AND Sigla = 'PRW'

UPDATE Matricula
SET N1 = 7
WHERE RA = 5 AND Sigla = 'CAL'

UPDATE Matricula
SET N2 = 2
WHERE RA = 5 AND Sigla = 'CAL'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =5 AND Sigla = 'PRW'

UPDATE Matricula 
SET FALTA = Falta+1
WHERE RA =5 AND Sigla = 'CAL'

SELECT *FROM Matricula
GO 

UPDATE Matricula
SET SUB = 5
WHERE RA = 5 AND Sigla = 'CAL'

SELECT * FROM Matricula

SELECT Disciplina.Sigla, Disciplina.Nome, Aluno.RA, Aluno.Nome,Matricula.Data_Ano,Matricula.N1,Matricula.N2,Matricula.Sub,Matricula.Media,Matricula.Falta,Matricula.Situacao
FROM Aluno,Matricula, Disciplina
WHERE  Matricula.RA = Aluno.RA AND Matricula.Sigla = Disciplina.Sigla AND Disciplina.Sigla= 'ES' AND  Data_Ano = 2021

SELECT Aluno.RA,Aluno.Nome,Matricula.Sigla,Matricula.Data_Ano,Matricula.Data_Semestre,Matricula.N1,Matricula.N2,Matricula.SUB,Matricula.Falta,Matricula.Situacao
FROM Aluno,Matricula
WHERE Matricula.RA = Aluno.RA and Aluno.Nome ='Ana' AND Data_Ano = 2021 and Data_Semestre = 1

SELECT Aluno.RA, Aluno.Nome, Matricula.Sigla,Matricula.Data_Ano,Matricula.N1,Matricula.SUB,Matricula.Media,Matricula.Situacao
FROM Aluno,Matricula
WHERE  Matricula.RA = Aluno.RA AND Data_Ano = 2021 AND Media < 5

