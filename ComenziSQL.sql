-- Stergerea tabelelor preexistente
DROP TRIGGER IF EXISTS VechimeMinimaT;
DROP TABLE IF EXISTS Alocare;
DROP TABLE IF EXISTS Repertoriu;
DROP TABLE IF EXISTS Inventar;
DROP TABLE IF EXISTS Instrumente;
DROP TABLE IF EXISTS Clase_calitate;
DROP TABLE IF EXISTS Sali;
ALTER TABLE Membri DROP CONSTRAINT IF EXISTS MembriFKdep;
DROP TABLE IF EXISTS Departamente;
DROP TABLE IF EXISTS Membri;
DROP TABLE IF EXISTS Roluri;

-- Crearea tabelelor si a constrangerilor
-- Tabelul Roluri
CREATE TABLE Roluri (
	Cod_rol varchar(8),
	Denumire_rol varchar(22) NOT NULL
);

ALTER TABLE Roluri 
	ADD CONSTRAINT RoluriPK PRIMARY KEY (Cod_rol);
    
ALTER TABLE Roluri 
	ADD CONSTRAINT DenumireRolU UNIQUE (Denumire_rol);  
    
-- Tabelul Membri
CREATE TABLE Membri (
	Serie_legitimatie char(7),
	Nume varchar(40) NOT NULL,
	Prenume varchar(40) NOT NULL,
	Data_inrolarii date NOT NULL,
	Cod_rol varchar(8) NOT NULL,
	Cod_departament varchar(14)
);

ALTER TABLE Membri
	ADD CONSTRAINT MembriPK PRIMARY KEY (Serie_legitimatie);
    
ALTER TABLE Membri
	ADD CONSTRAINT MembriFKrol FOREIGN KEY (Cod_rol) REFERENCES Roluri(Cod_rol) ON DELETE CASCADE;
    
-- Tabelul Departamente
CREATE TABLE Departamente (
	Cod_departament varchar(14),
	Nume_departament varchar(35) NOT NULL,
	Serie_sef char(7) NOT NULL
);

ALTER TABLE Departamente
	ADD CONSTRAINT DepartamentePK PRIMARY KEY (Cod_departament);
    
ALTER TABLE Departamente
	ADD CONSTRAINT DepartamenteFK FOREIGN KEY (Serie_sef) REFERENCES Membri(Serie_legitimatie) ON DELETE CASCADE;
    
ALTER TABLE Departamente
	ADD CONSTRAINT NumeDepartamentU UNIQUE (Nume_departament);  

-- Adaugare constrangere FK pentru Membri
ALTER TABLE Membri
	ADD CONSTRAINT MembriFKdep FOREIGN KEY (Cod_departament) REFERENCES Departamente(Cod_departament) ON DELETE SET NULL;
    
-- Tabelul Sali
CREATE TABLE Sali (
	Numar_sala varchar(2),
	Etaj  int NOT NULL,
	Scop enum('depozit', 'repetiţie', 'birou', 'spectacol') NOT NULL,
	Cod_departament varchar(14)
);

ALTER TABLE Sali
	ADD CONSTRAINT SaliPK PRIMARY KEY (Numar_sala);
    
ALTER TABLE Sali
	ADD CONSTRAINT SaliFK FOREIGN KEY (Cod_departament) REFERENCES Departamente(Cod_departament) ON DELETE SET NULL;
    
ALTER TABLE Sali
    	ADD CONSTRAINT EtajC CHECK (Etaj BETWEEN -1 AND  3);

-- Tabelul Instrumente
CREATE TABLE Instrumente (
	Cod_instrument varchar(2),
	Denumire_instrument varchar(20) NOT NULL,
	Sunet enum('idiofon', 'membranofon', 'aerofon', 'cordofon') NOT NULL,
	Cheie enum('sol', 'fa', 'do', 'sol-fa', 'linie') NOT NULL,
	Ambitus_grav varchar(20),
	Ambitus_acut varchar(20)
);

ALTER TABLE Instrumente
	ADD CONSTRAINT InstrumentePK PRIMARY KEY (Cod_instrument);


ALTER TABLE Instrumente
    	ADD CONSTRAINT Denumire_instrumentU UNIQUE (Denumire_instrument);
   
-- Tabelul Clase_calitate
CREATE TABLE Clase_calitate (
	Categorie varchar(6),
	Denumire_clasa enum('standard', 'premium', 'elite') NOT NULL,
	Vechime_minima int UNSIGNED NOT NULL,
	Vechime_maxima int UNSIGNED NOT NULL
);

ALTER TABLE Clase_calitate
	ADD CONSTRAINT ClaseCalitatePK PRIMARY KEY (Categorie);


ALTER TABLE Clase_calitate
    	ADD CONSTRAINT VechimeMaximaC CHECK (Vechime_maxima > 1566);
   
-- Creare trigger
DELIMITER //
CREATE TRIGGER VechimeMinimaT
BEFORE INSERT ON Clase_calitate
FOR EACH ROW
BEGIN
IF NEW.Vechime_minima > YEAR(CURRENT_DATE) THEN
SIGNAL SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'An invalid!';
END IF;
END; //
DELIMITER ;

-- Tabelul Inventar
CREATE TABLE Inventar (
	Serie_instrument varchar(10),
	Status_folosinta enum('liber', 'folosit', 'defect') NOT NULL,
	Cod_instrument varchar(2) NOT NULL,
	Serie_legitimatie char(7),
	Categorie varchar(6) NOT NULL
);

ALTER TABLE Inventar
	ADD CONSTRAINT InventarPK PRIMARY KEY (Serie_instrument);
    
ALTER TABLE Inventar
	ADD CONSTRAINT InventarFKtip FOREIGN KEY (Cod_instrument) REFERENCES Instrumente(Cod_instrument) ON DELETE CASCADE;

ALTER TABLE Inventar
	ADD CONSTRAINT InventarFKleg FOREIGN KEY (Serie_legitimatie) REFERENCES Membri(Serie_legitimatie) ON DELETE SET NULL;
    
ALTER TABLE Inventar
	ADD CONSTRAINT InventarFKcat FOREIGN KEY (Categorie) REFERENCES Clase_calitate(Categorie) ON DELETE CASCADE;
    
-- Tabelul Repertoriu
CREATE TABLE Repertoriu (
	Cod_piesa varchar(10),
	Titlu varchar(60) NOT NULL,
	Compozitor varchar(60) NOT NULL,
	Gama varchar(20) NOT NULL
);

ALTER TABLE Repertoriu
	ADD CONSTRAINT RepertoriuPK PRIMARY KEY (Cod_piesa);
    
-- Tabelul Alocare
CREATE TABLE Alocare (
	Cod_alocare int AUTO_INCREMENT PRIMARY KEY,
	Serie_legitimatie char(7) NOT NULL,
	Cod_piesa varchar(10) NOT NULL
);
     
ALTER TABLE Alocare
	ADD CONSTRAINT AlocareFKleg FOREIGN KEY (Serie_legitimatie) REFERENCES Membri(Serie_legitimatie) ON DELETE CASCADE;
    
ALTER TABLE Alocare
	ADD CONSTRAINT AlocareFKps FOREIGN KEY (Cod_piesa) REFERENCES Repertoriu(Cod_piesa) ON DELETE CASCADE;
    
-- Inserare date in tabelul Roluri

INSERT INTO Roluri VALUES ('DIR', 'Director');
INSERT INTO Roluri VALUES ('DIRJ', 'Dirijor');
INSERT INTO Roluri VALUES ('PNST', 'Pianist');
INSERT INTO Roluri VALUES ('HST', 'Harpist');
INSERT INTO Roluri VALUES ('C_MSTR', 'Concertmaistru');
INSERT INTO Roluri VALUES ('SFP_VR', 'Sef_partida_vioara');
INSERT INTO Roluri VALUES ('VRST', 'Violonist');
INSERT INTO Roluri VALUES ('SFP_VL', 'Sef_partida_viola');
INSERT INTO Roluri VALUES ('VLST', 'Violist');
INSERT INTO Roluri VALUES ('SFP_VC', 'Sef_partida_violoncel');
INSERT INTO Roluri VALUES ('VCST', 'Violoncelist');
INSERT INTO Roluri VALUES ('SFP_CB', 'Sef_partida_contrabas');
INSERT INTO Roluri VALUES ('CBST', 'Contrabasist');
INSERT INTO Roluri VALUES ('SOL_FL', 'Solist_flaut');
INSERT INTO Roluri VALUES ('FLST', 'Flautist');
INSERT INTO Roluri VALUES ('SOL_CL', 'Solist_clarinet');
INSERT INTO Roluri VALUES ('CLST', 'Clarinetist');
INSERT INTO Roluri VALUES ('SOL_FG', 'Solist_fagot');
INSERT INTO Roluri VALUES ('FGST', 'Fagotist');
INSERT INTO Roluri VALUES ('C_FGST', 'Contrafagotist');
INSERT INTO Roluri VALUES ('SOL_O', 'Solist_oboi');
INSERT INTO Roluri VALUES ('OST', 'Oboist');
INSERT INTO Roluri VALUES ('SOL_CR', 'Solist_corn');
INSERT INTO Roluri VALUES ('CRST', 'Cornist');
INSERT INTO Roluri VALUES ('SOL_TP', 'Solist_trompeta');
INSERT INTO Roluri VALUES ('TPST', 'Trompetist');
INSERT INTO Roluri VALUES ('SOL_TB', 'Solist_trombon');
INSERT INTO Roluri VALUES ('TBST', 'Trombonist');
INSERT INTO Roluri VALUES ('TUST', 'Tubist');
INSERT INTO Roluri VALUES ('TMST', 'Timpanist');
INSERT INTO Roluri VALUES ('PERCST', 'Percutionist');
INSERT INTO Roluri VALUES ('REG_SC', 'Regizor_scena');
INSERT INTO Roluri VALUES ('ACRD', 'Acordor');
INSERT INTO Roluri VALUES ('SNST', 'Sunetist');
INSERT INTO Roluri VALUES ('LUTR', 'Lutier');
INSERT INTO Roluri VALUES ('CONS_ART', 'Consultant_artistic');
INSERT INTO Roluri VALUES ('SECR', 'Secretar');
INSERT INTO Roluri VALUES ('BIBLTR', 'Bibliotecar');
INSERT INTO Roluri VALUES ('TEHN_RED', 'Tehnoredactor');
INSERT INTO Roluri VALUES ('REF_ORG', 'Referent_organizare');
INSERT INTO Roluri VALUES ('CNTB', 'Contabil');
INSERT INTO Roluri VALUES ('ECONST', 'Economist');
INSERT INTO Roluri VALUES ('CONSL', 'Consilier');
INSERT INTO Roluri VALUES ('CASR', 'Casier');
INSERT INTO Roluri VALUES ('DACT_GF', 'Dactilograf');
INSERT INTO Roluri VALUES ('SF_ACZ', 'Sef_achizitii');

-- Inserare date in tabelul Membri

INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2006/01', 'Badea', 'Christian', STR_TO_DATE('02/10/2006', '%d/%m/%Y'), 'DIRJ');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1997/01', 'Prunner', 'Iosif-Ion', STR_TO_DATE('18/02/1997', '%d/%m/%Y'), 'DIRJ');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2014/01', 'Butaru', 'Rafael', STR_TO_DATE('04/12/2014', '%d/%m/%Y'), 'C_MSTR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2018/01', 'Pancec', 'Natalia', STR_TO_DATE('21/10/2018', '%d/%m/%Y'), 'SFP_VR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2006/05', 'Antal', 'Matei', STR_TO_DATE('25/11/2006', '%d/%m/%Y'), 'SFP_VR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2002/01', 'Gheorghe', 'Gabriel', STR_TO_DATE('09/03/2002', '%d/%m/%Y'), 'SFP_VR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1990/01', 'Ailincai', 'Liviu', STR_TO_DATE('16/03/1990', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/01', 'Biclea', 'Marius', STR_TO_DATE('13/08/2011', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2006/02', 'Bustean', 'Vasile', STR_TO_DATE('23/02/2006', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1998/01', 'Chisu', 'Radu', STR_TO_DATE('09/10/1998', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2012/01', 'Frandes', 'Iunia', STR_TO_DATE('15/12/2012', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/01', 'Mitroi', 'Corina', STR_TO_DATE('18/06/1999', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1997/02', 'Moroianu', 'Mioara', STR_TO_DATE('29/07/1997', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2015/01', 'Nemteanu', 'Petru', STR_TO_DATE('04/07/2015', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1995/01', 'Preotu', 'George', STR_TO_DATE('27/09/1995', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/06', 'Simionescu', 'Bogdan', STR_TO_DATE('23/02/2011', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2006/03', 'Zambreanu', 'Tania', STR_TO_DATE('02/03/2006', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/01', 'Andrei', 'Andra-Lucia', STR_TO_DATE('22/01/2004', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2002/02', 'Fara', 'Lucian', STR_TO_DATE('02/02/2002', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/09', 'Gogoncea', 'Bogdan', STR_TO_DATE('29/09/1999', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/05', 'Iftimie', 'Ionela', STR_TO_DATE('05/03/2010', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/01', 'Paraschiv', 'Radu', STR_TO_DATE('28/11/2005', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1994/01', 'Simonescu', 'Livia', STR_TO_DATE('10/09/1994', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2009/03', 'Stegar', 'Emil', STR_TO_DATE('28/01/2009', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1990/02', 'Tanase', 'Ana-Maria', STR_TO_DATE('28/01/1990', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2008/05', 'Toma', 'Alina', STR_TO_DATE('15/12/2008', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1993/01', 'Spanu-Visenescu', 'Oana', STR_TO_DATE('23/04/1993', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/06', 'Iftimie', 'Gabriela', STR_TO_DATE('09/12/1996', '%d/%m/%Y'), 'VRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2018/02', 'Matei', 'Florin', STR_TO_DATE('30/11/2018', '%d/%m/%Y'), 'SFP_VL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2014/02', 'Movileanu', 'Marian', STR_TO_DATE('31/10/2014', '%d/%m/%Y'), 'SFP_VL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2008/04', 'Goiana', 'Iulia', STR_TO_DATE('10/12/2008', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/04', 'Deaconu', 'Eugenia', STR_TO_DATE('30/08/2013', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/02', 'Gavrila', 'Rodica', STR_TO_DATE('29/09/2011', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2003/01', 'Iancu', 'Viorel', STR_TO_DATE('20/05/2003', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2009/04', 'Juvina', 'Andrei', STR_TO_DATE('21/07/2009', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/02', 'Petroiu', 'Cornelia', STR_TO_DATE('26/06/2005', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/02', 'Rotarescu', 'Gicu', STR_TO_DATE('28/03/2010', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/05', 'Simionescu', 'Mirela', STR_TO_DATE('12/01/1996', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/02', 'Suceava', 'Florela', STR_TO_DATE('28/02/2004', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2014/04', 'Iorga', 'Luiza', STR_TO_DATE('22/04/2014', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/02', 'Marin', 'Alexandra', STR_TO_DATE('27/04/1999', '%d/%m/%Y'), 'VLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2012/02', 'Fara', 'Madalina', STR_TO_DATE('12/12/2012', '%d/%m/%Y'), 'SFP_VC');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2015/02', 'Joitoiu', 'Dan', STR_TO_DATE('04/10/2015', '%d/%m/%Y'), 'SFP_VC');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/03', 'Popa-Bogdan', 'Eugen', STR_TO_DATE('04/08/2013', '%d/%m/%Y'), 'VCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1995/02', 'Dutulescu', 'Alexandru', STR_TO_DATE('09/09/1995', '%d/%m/%Y'), 'VCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2017/01', 'Ludusan', 'Horatiu', STR_TO_DATE('16/06/2017', '%d/%m/%Y'), 'VCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/03', 'Heroiu', 'Manuela', STR_TO_DATE('27/10/2005', '%d/%m/%Y'), 'VCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1997/03', 'Iancu', 'Theodor', STR_TO_DATE('28/06/1997', '%d/%m/%Y'), 'VCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2016/01', 'Prodan', 'Silviu', STR_TO_DATE('17/03/2016', '%d/%m/%Y'), 'SFP_CB');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1993/02', 'Andronache', 'Gabriel', STR_TO_DATE('14/02/1993', '%d/%m/%Y'), 'CBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/04', 'Barbu', 'Dan', STR_TO_DATE('24/01/1996', '%d/%m/%Y'), 'CBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/03', 'Nedelcu', 'Dominic', STR_TO_DATE('05/12/2011', '%d/%m/%Y'), 'CBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2003/02', 'Petrache', 'Dinu-Eugen', STR_TO_DATE('15/03/2003', '%d/%m/%Y'), 'CBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/03', 'Silaev', 'Vlad', STR_TO_DATE('13/07/2010', '%d/%m/%Y'), 'CBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1983/01', 'Stefanescu', 'Ion-Bogdan', STR_TO_DATE('23/11/1983', '%d/%m/%Y'), 'SOL_FL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2014/03', 'Balasa', 'Ioana', STR_TO_DATE('24/10/2014', '%d/%m/%Y'), 'FLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2009/02', 'Didu', 'Miruna', STR_TO_DATE('22/10/2009', '%d/%m/%Y'), 'FLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/03', 'Petrescu', 'Adrian', STR_TO_DATE('01/08/1996', '%d/%m/%Y'), 'SOL_O');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2008/02', 'Iorga', 'Doris', STR_TO_DATE('02/03/2008', '%d/%m/%Y'), 'SOL_O');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/03', 'Sperneac', 'Florin-Cosmin', STR_TO_DATE('08/03/1999', '%d/%m/%Y'), 'OST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2000/03', 'Zamfir', 'Mihai', STR_TO_DATE('28/06/2000', '%d/%m/%Y'), 'OST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2016/02', 'Avramovici', 'Dan', STR_TO_DATE('15/12/2016', '%d/%m/%Y'), 'SOL_CL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/04', 'Mancas', 'Nicusor-Cristian', STR_TO_DATE('17/09/2005', '%d/%m/%Y'), 'SOL_CL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2015/03', 'Visenescu', 'Emil', STR_TO_DATE('27/09/2015', '%d/%m/%Y'), 'SOL_CL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/02', 'Avramovici', 'Alexandru-Sorin', STR_TO_DATE('28/05/2013', '%d/%m/%Y'), 'CLST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/03', 'Darie', 'Laurentiu-Marius', STR_TO_DATE('15/03/2004', '%d/%m/%Y'), 'SOL_FG');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/02', 'Buciumas', 'Cristian', STR_TO_DATE('17/02/1996', '%d/%m/%Y'), 'FGST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2014/05', 'Neaga', 'Alexandra-Maria', STR_TO_DATE('02/05/2014', '%d/%m/%Y'), 'C_FGST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2002/03', 'Luca', 'Ioan-Gabriel', STR_TO_DATE('30/05/2002', '%d/%m/%Y'), 'SOL_CR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1993/04', 'Cinca', 'Dan', STR_TO_DATE('31/08/1993', '%d/%m/%Y'), 'CRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/06', 'Lupascu', 'Sorin', STR_TO_DATE('31/07/2013', '%d/%m/%Y'), 'CRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/04', 'Popa', 'Ciprian', STR_TO_DATE('29/07/1999', '%d/%m/%Y'), 'CRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/04', 'Raileanu', 'Gabriel', STR_TO_DATE('30/08/2010', '%d/%m/%Y'), 'CRST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/04', 'Suciu', 'Cristian', STR_TO_DATE('29/01/2004', '%d/%m/%Y'), 'SOL_TP');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2015/04', 'Toth', 'Mihai', STR_TO_DATE('28/02/2015', '%d/%m/%Y'), 'SOL_TP');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/05', 'Daniel', 'Ivan', STR_TO_DATE('30/04/2005', '%d/%m/%Y'), 'TPST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2017/02', 'Simionescu', 'Stefan', STR_TO_DATE('24/01/2017', '%d/%m/%Y'), 'TPST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2008/03', 'Pane', 'Florin', STR_TO_DATE('29/02/2008', '%d/%m/%Y'), 'SOL_TB');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2000/02', 'Labus', 'Dumitru-Cristian', STR_TO_DATE('29/02/2000', '%d/%m/%Y'), 'TBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2006/04', 'Parciu', 'Ciprian', STR_TO_DATE('23/08/2006', '%d/%m/%Y'), 'TBST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/01', 'Sima', 'Laurentiu', STR_TO_DATE('28/06/2013', '%d/%m/%Y'), 'TUST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/04', 'Nicolescu', 'Ioana', STR_TO_DATE('09/11/2011', '%d/%m/%Y'), 'HST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1983/02', 'Pop', 'Bogdan', STR_TO_DATE('06/05/1983', '%d/%m/%Y'), 'TMST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1996/01', 'Constantin', 'Bogdan', STR_TO_DATE('13/10/1996', '%d/%m/%Y'), 'PERCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2013/05', 'Ihnatiuc', 'Gabriela-Luminita', STR_TO_DATE('12/04/2013', '%d/%m/%Y'), 'PERCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/05', 'Lorentz', 'Maria-Ilinca', STR_TO_DATE('18/02/1999', '%d/%m/%Y'), 'PERCST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2000/01', 'Marin', 'Doru', STR_TO_DATE('15/08/2000', '%d/%m/%Y'), 'REG_SC');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1987/01', 'Pscheidt', 'Alexandru', STR_TO_DATE('20/12/1987', '%d/%m/%Y'), 'ACRD');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2008/01', 'Duminica', 'Catalin', STR_TO_DATE('02/11/2008', '%d/%m/%Y'), 'SNST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1997/04', 'Dumitrascu', 'Viorel', STR_TO_DATE('09/03/1997', '%d/%m/%Y'), 'LUTR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/01', 'Dumitriu', 'Andrei-Radu', STR_TO_DATE('27/10/2010', '%d/%m/%Y'), 'DIR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/06', 'Cojocaru', 'Mihai', STR_TO_DATE('28/11/1999', '%d/%m/%Y'), 'CONS_ART');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2016/03', 'Popescu-Deveselu', 'Vladimir', STR_TO_DATE('01/11/2016', '%d/%m/%Y'), 'CONS_ART');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2009/01', 'Dinulescu', 'Octavia-Anahid', STR_TO_DATE('12/04/2009', '%d/%m/%Y'), 'CONS_ART');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2005/06', 'Enasescu', 'Daniel', STR_TO_DATE('11/08/2005', '%d/%m/%Y'), 'CONS_ART');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2017/03', 'David', 'Cleopatra-Maria', STR_TO_DATE('12/05/2017', '%d/%m/%Y'), 'SECR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1995/03', 'Crasnopolschi', 'Victor-Eliade', STR_TO_DATE('18/06/1995', '%d/%m/%Y'), 'BIBLTR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/07', 'Lungu', 'Florica', STR_TO_DATE('08/04/1999', '%d/%m/%Y'), 'TEHN_RED');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/05', 'Nedelcu', 'Silviu', STR_TO_DATE('22/04/2004', '%d/%m/%Y'), 'REF_ORG');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2010/06', 'Sivec', 'Florica', STR_TO_DATE('28/04/2010', '%d/%m/%Y'), 'CNTB');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2018/03', 'Anton', 'Anca', STR_TO_DATE('30/01/2018', '%d/%m/%Y'), 'ECONST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2011/05', 'Zainea', 'Liliana', STR_TO_DATE('09/06/2011', '%d/%m/%Y'), 'ECONST');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2016/04', 'Gogan', 'Florentina', STR_TO_DATE('06/09/2016', '%d/%m/%Y'), 'CONSL');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('2004/06', 'Nedelcu', 'Lucica', STR_TO_DATE('17/05/2004', '%d/%m/%Y'), 'CASR');
INSERT INTO Membri (Serie_legitimatie, Nume, Prenume, Data_inrolarii, Cod_rol) VALUES ('1999/08', 'Matei', 'Elisabeta', STR_TO_DATE('19/09/1999', '%d/%m/%Y'), 'DACT_GF');

-- Inserare date in tabelul Departamente

INSERT INTO Departamente VALUES ('DEP_ADM', 'Departament_administrativ', '2010/01');
INSERT INTO Departamente VALUES ('DEP_TEH', 'Departament_tehnic', '2000/01');
INSERT INTO Departamente VALUES ('DEP_INSTR_CRD', 'Departament_instrumente_cu_coarde', '2014/01');
INSERT INTO Departamente VALUES ('DEP_INSTR_SFL', 'Departament_instrumente_de_suflat', '1983/01');
INSERT INTO Departamente VALUES ('DEP_INSTR_PERC', 'Departament_instrumente_de_percutie', '1983/02');

-- Inserare coduri de departament pentru membri

UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2014/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2018/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2006/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2002/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1990/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2011/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2006/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1998/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2012/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1999/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1997/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2015/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1995/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2011/06';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2006/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2004/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2002/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1999/09';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2010/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2005/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1994/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2009/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1990/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2008/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1993/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1996/06';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2018/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2014/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2008/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2013/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2011/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2003/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2009/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2005/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2010/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1996/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2004/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2014/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1999/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2012/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2015/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2013/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1995/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2017/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2005/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1997/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2016/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1993/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '1996/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2011/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2003/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2010/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1983/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2014/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2009/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1996/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2008/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1999/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2000/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2016/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2005/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2015/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2013/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2004/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1996/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2014/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2002/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1993/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2013/06';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '1999/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2010/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2004/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2015/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2005/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2017/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2008/03';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2000/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2006/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_SFL' WHERE Serie_legitimatie = '2013/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_CRD' WHERE Serie_legitimatie = '2011/04';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_PERC' WHERE Serie_legitimatie = '1983/02';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_PERC' WHERE Serie_legitimatie = '1996/01';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_PERC' WHERE Serie_legitimatie = '2013/05';
UPDATE Membri SET Cod_departament = 'DEP_INSTR_PERC' WHERE Serie_legitimatie = '1999/05';
UPDATE Membri SET Cod_departament = 'DEP_TEH' WHERE Serie_legitimatie = '2000/01';
UPDATE Membri SET Cod_departament = 'DEP_TEH' WHERE Serie_legitimatie = '1987/01';
UPDATE Membri SET Cod_departament = 'DEP_TEH' WHERE Serie_legitimatie = '2008/01';
UPDATE Membri SET Cod_departament = 'DEP_TEH' WHERE Serie_legitimatie = '1997/04';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2010/01';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '1999/06';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2016/03';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2009/01';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2005/06';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2017/03';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '1995/03';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '1999/07';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2004/05';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2010/06';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2018/03';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2011/05';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2016/04';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '2004/06';
UPDATE Membri SET Cod_departament = 'DEP_ADM' WHERE Serie_legitimatie = '1999/08';

-- Inserare date in tabelul Sali

INSERT INTO Sali VALUES('D5', -1, 'repetitie', 'DEP_INSTR_PERC');
INSERT INTO Sali VALUES('13', 1, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('14', 1, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('15', 1, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('16', 1, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('23', 2, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('24', 2, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('25', 2, 'repetitie', 'DEP_INSTR_CRD');
INSERT INTO Sali VALUES('32', 3, 'repetitie', 'DEP_INSTR_SFL');
INSERT INTO Sali VALUES('33', 3, 'repetitie', 'DEP_INSTR_SFL');
INSERT INTO Sali VALUES('34', 3, 'repetitie', 'DEP_INSTR_SFL');
INSERT INTO Sali VALUES('35', 3, 'repetitie', 'DEP_INSTR_SFL');
INSERT INTO Sali VALUES('12', 1, 'birou', 'DEP_ADM');
INSERT INTO Sali VALUES('D2', -1, 'birou', 'DEP_ADM');
INSERT INTO Sali VALUES('D3', -1, 'birou', 'DEP_ADM');
INSERT INTO Sali VALUES('D4', -1, 'birou', 'DEP_ADM');
INSERT INTO Sali VALUES('P3', 0, 'birou', 'DEP_TEH');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('21', 2, 'depozit');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('D1', -1, 'depozit');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('22', 2, 'depozit');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('31', 3, 'depozit');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('11', 1, 'spectacol');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('P1', 0, 'spectacol');
INSERT INTO Sali (Numar_sala, Etaj, Scop) VALUES('P2', 0, 'spectacol');

-- Inserare date in tabelul Instrumente

INSERT INTO Instrumente VALUES ('VR', 'vioara', 'cordofon', 'sol', 'sol', 'mi4');
INSERT INTO Instrumente VALUES ('VL', 'viola', 'cordofon', 'do', 'do', 'do3');
INSERT INTO Instrumente VALUES ('VC', 'violoncel', 'cordofon', 'fa', 'do', 'la2');
INSERT INTO Instrumente VALUES ('CB', 'contrabas', 'cordofon', 'fa', 'mi', 'sol2');
INSERT INTO Instrumente VALUES ('H', 'harpa', 'cordofon', 'sol-fa', 'doBemol', 'solDiez4');
INSERT INTO Instrumente VALUES ('FL', 'flaut', 'aerofon', 'sol', 'do1', 'do4');
INSERT INTO Instrumente VALUES ('CL', 'clarinet', 'aerofon', 'sol', 'mi', 'sol3');
INSERT INTO Instrumente VALUES ('FG', 'fagot', 'aerofon', 'fa', 'si', 'mi3');
INSERT INTO Instrumente VALUES ('CF', 'contrafagot', 'aerofon', 'fa', 'siBemol-1', 'sol');
INSERT INTO Instrumente VALUES ('O', 'oboi', 'aerofon', 'sol', 'si', 'la3');
INSERT INTO Instrumente VALUES ('CR', 'corn', 'aerofon', 'sol-fa', 'si-1', 'fa2');
INSERT INTO Instrumente VALUES ('TP', 'trompeta', 'aerofon', 'sol', 'fa', 'mi3');
INSERT INTO Instrumente VALUES ('TB', 'trombon', 'aerofon', 'fa', 'mi', 'reBemol2');
INSERT INTO Instrumente VALUES ('TU', 'tuba', 'aerofon', 'fa', 'mi-1', 'siBemol');
INSERT INTO Instrumente VALUES ('P ', 'pian', 'cordofon', 'sol-fa', 'la-2', 'do5');
INSERT INTO Instrumente VALUES ('CP', 'clopote', 'idiofon', 'sol', 'si-1', 'do3');
INSERT INTO Instrumente VALUES ('V ', 'vibrafon', 'idiofon', 'sol', 'fa', 'fa3');
INSERT INTO Instrumente (Cod_instrument, Denumire_instrument, Sunet, Cheie) VALUES ('TL', 'talgere', 'idiofon', 'linie');
INSERT INTO Instrumente (Cod_instrument, Denumire_instrument, Sunet, Cheie) VALUES ('TG', 'trianglu', 'idiofon', 'linie');
INSERT INTO Instrumente (Cod_instrument, Denumire_instrument, Sunet, Cheie) VALUES ('TO', 'tobe', 'membranofon', 'linie');
INSERT INTO Instrumente (Cod_instrument, Denumire_instrument, Sunet, Cheie) VALUES ('TM', 'timpani', 'membranofon', 'fa');

-- Inserare date in tabelul Clase_calitate

INSERT INTO Clase_calitate VALUES ('A_CRD', 'elite', 1891, 1787);
INSERT INTO Clase_calitate VALUES ('B_CRD', 'premium', 1962, 1892);
INSERT INTO Clase_calitate VALUES ('C_CRD', 'standard', YEAR(CURRENT_DATE), 1963);
INSERT INTO Clase_calitate VALUES ('A_SFL', 'elite', 1936, 1874);
INSERT INTO Clase_calitate VALUES ('B_SFL', 'premium', 1995, 1937);
INSERT INTO Clase_calitate VALUES ('C_SFL', 'standard', YEAR(CURRENT_DATE), 1996);
INSERT INTO Clase_calitate VALUES ('A_PERC', 'elite', 1969, 1900);
INSERT INTO Clase_calitate VALUES ('B_PERC', 'premium', 2001, 1970);
INSERT INTO Clase_calitate VALUES ('C_PERC', 'standard', YEAR(CURRENT_DATE), 2002);

-- Inserare date in tabelul Inventar

INSERT INTO Inventar VALUES ('VR/1799/01', 'folosit', 'VR', '2018/01', 'A_CRD');
INSERT INTO Inventar VALUES ('VR/1803/02', 'folosit', 'VR', '2006/05', 'A_CRD');
INSERT INTO Inventar VALUES ('VR/1876/03', 'folosit', 'VR', '2002/01', 'A_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1888/04', 'liber', 'VR', 'A_CRD');
INSERT INTO Inventar VALUES ('VR/1895/05', 'folosit', 'VR', '1990/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1899/06', 'folosit', 'VR', '2006/02', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1899/07', 'folosit', 'VR', '1998/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1891/08', 'folosit', 'VR', '1999/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1916/09', 'folosit', 'VR', '2015/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1920/10', 'folosit', 'VR', '1995/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1924/11', 'folosit', 'VR', '2011/06', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1927/12', 'folosit', 'VR', '2011/01', 'B_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1855/13', 'liber', 'VR', 'A_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1842/14', 'liber', 'VR', 'A_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1933/15', 'liber', 'VR', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1998/16', 'folosit', 'VR', '2012/01', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1936/17', 'folosit', 'VR', '1997/02', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1941/18', 'folosit', 'VR', '2006/05', 'B_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1945/19', 'liber', 'VR', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1949/20', 'folosit', 'VR', '1996/06', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1972/21', 'folosit', 'VR', '2008/05', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1980/22', 'folosit', 'VR', '1990/02', 'C_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1956/23', 'defect', 'VR', 'B_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1971/24', 'defect', 'VR', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1974/25', 'folosit', 'VR', '2004/01', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1978/26', 'folosit', 'VR', '2005/01', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1982/27', 'folosit', 'VR', '1994/01', 'C_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VR/1986/28', 'liber', 'VR', 'C_CRD');
INSERT INTO Inventar VALUES ('VR/1957/29', 'folosit', 'VR', '2006/03', 'B_CRD');
INSERT INTO Inventar VALUES ('VR/1993/30', 'folosit', 'VR', '2002/02', 'C_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VL/1790/01', 'liber', 'VL', 'A_CRD');
INSERT INTO Inventar VALUES ('VL/1822/02', 'folosit', 'VL', '2014/02', 'A_CRD');
INSERT INTO Inventar VALUES ('VL/1958/03', 'folosit', 'VL', '2011/02', 'B_CRD');
INSERT INTO Inventar VALUES ('VL/1969/04', 'folosit', 'VL', '2005/02', 'C_CRD');
INSERT INTO Inventar VALUES ('VL/1985/05', 'folosit', 'VL', '2010/02', 'C_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('VL/2000/06', 'defect', 'VL', 'C_CRD');
INSERT INTO Inventar VALUES ('VC/1960/01', 'folosit', 'VC', '2012/02', 'B_CRD');
INSERT INTO Inventar VALUES ('VC/1962/02', 'folosit', 'VC', '2017/01', 'B_CRD');
INSERT INTO Inventar VALUES ('VC/2001/03', 'folosit', 'VC', '2005/03', 'C_CRD');
INSERT INTO Inventar VALUES ('CB/1994/01', 'folosit', 'CB', '2011/03', 'C_CRD');
INSERT INTO Inventar VALUES ('CB/1969/02', 'folosit', 'CB', '2016/01', 'C_CRD');
INSERT INTO Inventar VALUES ('H/1962/01', 'folosit', 'H', '2011/04', 'B_CRD');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('FL/1996/01', 'defect', 'FL', 'C_SFL');
INSERT INTO Inventar VALUES ('FL/1938/02', 'folosit', 'FL', '2014/03', 'B_SFL');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('CL/1889/01', 'liber', 'CL', 'A_SFL');
INSERT INTO Inventar VALUES ('CL/1944/02', 'folosit', 'CL', '2005/04', 'B_SFL');
INSERT INTO Inventar VALUES ('FG/1998/01', 'folosit', 'FG', '2004/03', 'C_SFL');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('CF/1956/01', 'defect', 'CF', 'B_SFL');
INSERT INTO Inventar VALUES ('O/1999/01', 'folosit', 'O', '2008/02', 'C_SFL');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('O/1901/02', 'liber', 'O', 'A_SFL');
INSERT INTO Inventar VALUES ('CR/1966/01', 'folosit', 'CR', '1999/04', 'B_SFL');
INSERT INTO Inventar VALUES ('CR/1972/02', 'folosit', 'CR', '1993/04', 'B_SFL');
INSERT INTO Inventar VALUES ('CR/2002/03', 'folosit', 'CR', '2002/03', 'C_SFL');
INSERT INTO Inventar VALUES ('TP/1980/01', 'folosit', 'TP', '2004/04', 'B_SFL');
INSERT INTO Inventar VALUES ('TP/2004/02', 'folosit', 'TP', '2015/04', 'C_SFL');
INSERT INTO Inventar VALUES ('TB/1994/01', 'folosit', 'TB', '2008/03', 'B_SFL');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('P/1810/01', 'defect', 'P', 'A_CRD');
INSERT INTO Inventar VALUES ('CP/2000/01', 'folosit', 'CP', '1996/01', 'B_PERC');
INSERT INTO Inventar VALUES ('V/1998/01', 'folosit', 'V', '2013/05', 'B_PERC');
INSERT INTO Inventar VALUES ('TL/1985/01', 'folosit', 'TL', '1996/01', 'B_PERC');
INSERT INTO Inventar VALUES ('TL/2002/02', 'folosit', 'TL', '1999/05', 'C_PERC');
INSERT INTO Inventar VALUES ('TG/2003/01', 'folosit', 'TG', '1996/01', 'C_PERC');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('TG/2003/02', 'liber', 'TG', 'C_PERC');
INSERT INTO Inventar VALUES ('TG/2007/03', 'folosit', 'TG', '2013/05', 'C_PERC');
INSERT INTO Inventar VALUES ('TO/1977/01', 'folosit', 'TO', '1996/01', 'B_PERC');
INSERT INTO Inventar VALUES ('TO/2016/02', 'folosit', 'TO', '2013/05', 'C_PERC');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('TO/2016/03', 'liber', 'TO', 'C_PERC');
INSERT INTO Inventar VALUES ('TO/2008/04', 'folosit', 'TO', '1999/05', 'C_PERC');
INSERT INTO Inventar VALUES ('TM/1973/01', 'folosit', 'TM', '1983/02', 'B_PERC');
INSERT INTO Inventar (Serie_instrument, Status_folosinta, Cod_instrument, Categorie) VALUES ('TM/1981/02', 'liber', 'TM', 'B_PERC');

-- Inserare date in tabelul Repertoriu

INSERT INTO Repertoriu VALUES ('C_BB/2', 'Concert-pentru-vioara-nr-2', 'Bela-Bartok', 'SiMajor');
INSERT INTO Repertoriu VALUES ('A_WAM/0', 'Adelaide-Concert', 'Wolfgang-Amadeus-Mozart', 'ReMajor');
INSERT INTO Repertoriu VALUES ('R_LVB/40', 'Romanta-op-40', 'Ludwig-van-Beethoven', 'FaMajor');
INSERT INTO Repertoriu VALUES ('C_MB/58', 'Concert-pentru-vioara-nr-3-op-58', 'Max-Bruch', 'ReMinor');
INSERT INTO Repertoriu VALUES ('E_LVB/3', 'Eroica-Simfonie-nr-3-op-55', 'Ludwig-van-Beethoven', 'MiBemolMajor');
INSERT INTO Repertoriu VALUES ('U_NRK/36', 'Uvertura-Marele-Paste-rusesc-op-36', 'Nikolai-Rimsky-Korsakov', 'DoMajor');
INSERT INTO Repertoriu VALUES ('C_WAM/313', 'Concert-pentru-flaut-nr-1-k-313', 'Wolfgang-Amadeus-Mozart', 'SolMajor');
INSERT INTO Repertoriu VALUES ('C_NP/5', 'Concert-pentru-vioara-nr-5', 'Niccolo-Paganini', 'LaMinor');
INSERT INTO Repertoriu VALUES ('C_JSB/1043', 'Concert-pentru-doua-viori-BWV-1043', 'Johann-Sebastian-Bach', 'ReMinor');
INSERT INTO Repertoriu VALUES ('S_WAM/250', 'Serenada-Haffner-pentru-orchestra-k-250', 'Wolfgang-Amadeus-Mozart', 'ReMajor');
INSERT INTO Repertoriu VALUES ('DQ_RS/35', 'Don-Quixote-op-35', 'Richard-Strauss', 'FaDiezMajor');
INSERT INTO Repertoriu VALUES ('S_NRK/35', 'Scheherazade-op-35', 'Nikolai-Rimsky-Korsakov', 'SiMinor');
INSERT INTO Repertoriu VALUES ('S_WAM/364', 'Simfonie-concertanta-pentru-vioara-viola-si-orchestra-k-364', 'Wolfgang-Amadeus-Mozart', 'MiBemolMajor');

-- Inserare date in tabelul Alocare

-- Concert-pentru-vioara-nr-2 de Bela-Bartok
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'C_BB/2');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'C_BB/2');

-- Adelaide-Concert de Wolfgang-Amadeus-Mozart
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'A_WAM/0');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'A_WAM/0');

-- Romanta-op-40 de Ludwig-van-Beethoven
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'R_LVB/40');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'R_LVB/40');

-- Concert-pentru-vioara-nr-3-op-58 de Max-Bruch
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/02', 'C_MB/58');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/03', 'C_MB/58');

-- Eroica-Simfonie-nr-3-op-55 de Ludwig-van-Beethoven
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/02', 'E_LVB/3');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/03', 'E_LVB/3');

-- Uvertura-Marele-Paste-rusesc-op-36 de Nikolai-Rimsky-Korsakov
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'U_NRK/36');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'U_NRK/36');

-- Concert-pentru-flaut-nr-1-k-313 de Wolfgang-Amadeus-Mozart
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'C_WAM/313');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'C_WAM/313');

-- Concert-pentru-vioara-nr-5 de Niccolo-Paganini
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/02', 'C_NP/5');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/03', 'C_NP/5');

-- Concert-pentru-doua-viori-BWV-1043 de Johann-Sebastian-Bach
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'C_JSB/1043');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'C_JSB/1043');

-- Serenada-Haffner-pentru-orchestra-k-250 de Wolfgang-Amadeus-Mozart
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/02', 'S_WAM/250');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/03', 'S_WAM/250');

-- Don-Quixote-op-35 de Richard-Strauss
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'DQ_RS/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'DQ_RS/35');

-- Scheherazade-op-35 de Nikolai-Rimsky-Korsakov
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1998/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2012/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1994/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/02', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/04', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/03', 'S_NRK/35');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/02', 'S_NRK/35');

-- Simfonie-concertanta-pentru-vioara-viola-si-orchestra-k-364 de Wolfgang-Amadeus-Mozart
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1983/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/06', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2000/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2011/06', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2006/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2002/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1999/09', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1990/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1993/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/06', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2018/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2008/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2003/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2009/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2010/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1996/05', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2004/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2014/04', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2015/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2013/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1995/02', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2017/01', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2005/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('1997/03', 'S_WAM/364');
INSERT INTO Alocare (Serie_legitimatie, Cod_piesa) VALUES ('2016/01', 'S_WAM/364');
