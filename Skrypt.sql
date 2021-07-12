DROP TABLE Wypozyczenia;
DROP TABLE Ksiazki;
DROP TABLE Czytelnicy;
DROP TABLE Pracownicy;
DROP TABLE Osoby;
DROP TABLE Dzialy;
DROP TABLE Filie;
DROP TABLE Adresy;
DROP TABLE Logi;

DROP VIEW Widok_Czytelnicy;
DROP VIEW Widok_Dzialy;
DROP VIEW Widok_Filie;
DROP VIEW Widok_Ksiazki;
DROP VIEW Widok_Wypozyczenia;
DROP VIEW Widok_Pracownicy;


CREATE TABLE Adresy (
                       id_adres number(6),
                       ulica varchar2(100) NOT NULL,
                       numer_domu number(3) NOT NULL,
		       numer_mieszkania number(3),
                       miejscowosc varchar2(100) NOT NULL,
		       kod_pocztowy varchar(6) NOT NULL, 
		       PRIMARY KEY (id_adres)
                       );


CREATE TABLE Osoby (
                       pesel number(11) CHECK (pesel BETWEEN 10000000000 AND 99999999999),
                       imie varchar2(30) NOT NULL,
                       nazwisko varchar2(50) NOT NULL,
                       numer_telefonu number(9) NOT NULL UNIQUE CHECK (numer_telefonu BETWEEN 100000000 AND 999999999),
		       id_adres number(6) NOT NULL,
                       PRIMARY KEY (pesel),
		       FOREIGN KEY (id_adres) REFERENCES Adresy (id_adres)
                       );

CREATE TABLE Czytelnicy (
                         id_czytelnika number(6),
                         pesel number(11) NOT NULL UNIQUE,  
               		 PRIMARY KEY (id_czytelnika),        
		         FOREIGN KEY (pesel) REFERENCES Osoby (pesel)
                         );

CREATE TABLE Filie (
		     id_filii number(3) NOT NULL,
		     nazwa_filii varchar2(255) NOT NULL,
		     id_adres number(6) NOT NULL,
		     PRIMARY KEY(id_filii),
		     FOREIGN KEY (id_adres) REFERENCES Adresy (id_adres)
		     );



CREATE TABLE Pracownicy (
                         id_pracownika number(5),
			 stanowisko varchar2(100) NOT NULL,
                         pesel number(11) NOT NULL UNIQUE,
			 id_filii number(3),     
			 PRIMARY KEY (id_pracownika),     
		         FOREIGN KEY (pesel) REFERENCES Osoby (pesel),
			 FOREIGN KEY (id_filii) REFERENCES Filie (id_filii)
                         );




CREATE TABLE Dzialy (
		      id_dzialu number(4) NOT NULL,
                      nazwa_dzialu varchar2(255) NOT NULL,
                      id_filii number(3) NOT NULL,
                      PRIMARY KEY(id_dzialu),
                      FOREIGN KEY (id_filii) REFERENCES Filie (id_filii)
                      );

CREATE TABLE Ksiazki (
                       id_ksiazki number(6) NOT NULL,
                       tytul varchar2(255) NOT NULL,
                       autor varchar2(255),
                       rok_wydania number(4) NOT NULL,
                       numer_seryjny number(20) NOT NULL,
                       czy_wypozyczona char(1) NOT NULL CHECK (czy_wypozyczona LIKE '%T' OR czy_wypozyczona LIKE '%N'),
                       id_dzialu number(4) NOT NULL,
                       PRIMARY KEY(id_ksiazki),
                       FOREIGN KEY (id_dzialu) REFERENCES Dzialy (id_dzialu)
                       );

CREATE TABLE Wypozyczenia (
			   id_wypozyczenia number(10) NOT NULL,
                           data_wypozyczenia date NOT NULL,
                           termin_oddania date NOT NULL,
                           id_ksiazki number(6) NOT NULL UNIQUE,
                           id_czytelnika number(6) NOT NULL,
                           PRIMARY KEY(id_wypozyczenia),
                           FOREIGN KEY (id_ksiazki) REFERENCES Ksiazki (id_ksiazki),
                           FOREIGN KEY (id_czytelnika) REFERENCES Czytelnicy (id_czytelnika)
                           );

CREATE TABLE Logi (
		    id_log number (30),
		    czas_operacji timestamp,
		    opis_operacji varchar2(255),
		    PRIMARY KEY (id_log)
		  );

CREATE VIEW Widok_Filie AS
SELECT f.nazwa_filii "Nazwa",CONCAT( CONCAT(a.ulica, ' '), a.numer_domu) "Adres", a.miejscowosc "Miejscowosc", 
(SELECT COUNT(id_dzialu)
FROM dzialy d
WHERE d.id_filii = f.id_filii
GROUP BY id_filii) "Liczba dzialow", 
(SELECT COUNT(id_pracownika)
FROM pracownicy p
WHERE p.id_filii = f.id_filii
GROUP BY id_filii) "Liczba pracownikow"
FROM filie f, adresy a
WHERE f.id_adres = a.id_adres;

CREATE VIEW Widok_Dzialy AS
SELECT d.nazwa_dzialu "Nazwa",(SELECT COUNT (id_ksiazki) FROM ksiazki k WHERE k.id_dzialu = d.id_dzialu GROUP BY id_dzialu) "Liczba ksiazek", f.nazwa_filii "Nazwa filii", CONCAT( CONCAT(a.ulica, ' '), a.numer_domu) "Adres", a.miejscowosc "Miejscowosc"
FROM dzialy d, filie f, adresy a
WHERE d.id_filii = f.id_filii AND f.id_adres = a.id_adres;

CREATE VIEW Widok_Ksiazki AS
SELECT k.tytul "Tytul", k.autor "Autor", k.numer_seryjny "Numer seryjny", k.rok_wydania "Rok wydania", k.czy_wypozyczona "Czy wypozyczona", d.nazwa_dzialu "Nazwa dzialu", f.nazwa_filii "Nazwa filii"
FROM ksiazki k, dzialy d, filie f
WHERE k.id_dzialu = d.id_dzialu AND d.id_filii = f.id_filii;

CREATE VIEW Widok_Wypozyczenia AS
SELECT k.tytul "Tytul ksiazki", k.autor "Autor", CONCAT( CONCAT(o.imie, ' '), o.nazwisko) "Czytelnik", w.data_wypozyczenia "Data wypozyczenia", w.termin_oddania "Termin oddania"
FROM ksiazki k, wypozyczenia w, osoby o, czytelnicy c
WHERE w.id_czytelnika = c.id_czytelnika AND c.pesel = o.pesel AND w.id_ksiazki = k.id_ksiazki;

CREATE VIEW Widok_Pracownicy AS
SELECT o.imie "Imie", o.nazwisko "Nazwisko", p.stanowisko "Stanowisko", p.pesel "Pesel"
FROM pracownicy p, osoby o
WHERE p.pesel = o.pesel;

CREATE VIEW Widok_Czytelnicy AS
SELECT o.imie "Imie", o.nazwisko "Nazwisko", c.pesel "Pesel", 
(SELECT COUNT (id_wypozyczenia) 
FROM wypozyczenia w
WHERE w.id_czytelnika = c.id_czytelnika
)"Wypozyczone ksiazki"
FROM czytelnicy c, osoby o
WHERE c.pesel = o.pesel;


INSERT INTO Logi (id_log, czas_operacji, opis_operacji)
VALUES (1, '29.05.2021', 'Start systemu.');





CREATE OR REPLACE TRIGGER skrocenie_terminu 
BEFORE UPDATE ON Wypozyczenia 
FOR EACH ROW
BEGIN
IF (:NEW.termin_oddania < :OLD.termin_oddania) THEN
RAISE_APPLICATION_ERROR (-20205,'Nie mozna skrocic terminu oddania.');
END IF;
END;

/

CREATE OR REPLACE TRIGGER wypozycz
BEFORE INSERT ON Wypozyczenia
FOR EACH ROW
BEGIN
UPDATE Ksiazki
SET czy_wypozyczona = 'T'
WHERE id_ksiazki = :NEW.id_ksiazki;
END;

/

CREATE OR REPLACE TRIGGER zwroc
BEFORE DELETE ON Wypozyczenia 
REFERENCING OLD AS u
FOR EACH ROW
BEGIN
UPDATE Ksiazki
SET czy_wypozyczona = 'N'
WHERE id_ksiazki = :u.id_ksiazki;
END;

/

CREATE OR REPLACE TRIGGER w_wypozyczeniu
BEFORE DELETE ON Ksiazki 
REFERENCING OLD AS u
FOR EACH ROW
BEGIN
IF (:u.czy_wypozyczona LIKE 'T') THEN
RAISE_APPLICATION_ERROR (-20205,'Ta ksiazka jest wypozyczona.');
END IF;
END;

/

CREATE OR REPLACE TRIGGER log_ksiazki 
AFTER INSERT OR UPDATE OR DELETE ON Ksiazki
FOR EACH ROW
DECLARE
lastK_id number;
BEGIN 
SELECT MAX(id_log) INTO lastK_id FROM logi ;

	IF DELETING 
	    THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastK_id+1, sysdate(),'Usunieto ksiazke z bazy danych.');
    END IF; 

	IF INSERTING 
        THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastK_id+1, sysdate(),'Dodano ksiazke do bazy danych.');
	END IF; 
	
	IF UPDATING 
        THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastK_id+1, sysdate(),'Edytowano ksiazke.');
	END IF; 
END;

/

CREATE OR REPLACE TRIGGER log_czytelnicy
AFTER INSERT OR UPDATE ON Czytelnicy
FOR EACH ROW
DECLARE
lastC_id number;
BEGIN 
SELECT MAX(id_log) INTO lastC_id FROM logi;

	IF DELETING 
	    THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastC_id+1, sysdate(),'Usunieto czytelnika z bazy danych.');
    END IF; 

	IF INSERTING 
        THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastC_id+1, sysdate(),'Dodano czytelnika do bazy danych.');
	END IF; 
	
END;

/

CREATE OR REPLACE TRIGGER log_wypozyczenia
AFTER INSERT OR UPDATE OR DELETE ON Wypozyczenia
FOR EACH ROW
DECLARE
lastW_id number;
BEGIN 
SELECT MAX(id_log) INTO lastW_id FROM logi;

	IF DELETING 
	    THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastW_id+1, sysdate(),'Zwrocono ksiazke.');
    END IF; 

	IF INSERTING 
        THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastW_id+1, sysdate(),'Wypozyczono ksiazke.');
	END IF; 
	
	IF UPDATING 
        THEN
			INSERT INTO Logi(id_log, czas_operacji, opis_operacji) 
			VALUES(lastW_id+1, sysdate(),'Przedluzono termin oddania ksiazki.');
	END IF; 
END;

/

INSERT INTO Adresy (id_adres, ulica, numer_domu, miejscowosc, kod_pocztowy)
VALUES (1,'Krakowska', 15, 'Wroclaw', '51-114');

INSERT INTO Adresy (id_adres, ulica, numer_domu, miejscowosc, kod_pocztowy)
VALUES (2,'Tanskiego', 79, 'Wroclaw', '50-324');

INSERT INTO Adresy (id_adres, ulica, numer_domu, miejscowosc, kod_pocztowy)
VALUES (3,'Prudnicka', 38, 'Wroclaw', '50-802');

INSERT INTO Adresy (id_adres, ulica, numer_domu, miejscowosc, kod_pocztowy)
VALUES (4,'Bociania', 124, 'Opole', '46-381');

INSERT INTO Adresy (id_adres, ulica, numer_domu, miejscowosc, kod_pocztowy)
VALUES (5,'Fiolkowa', 510, 'Legnica', '61-320');

INSERT INTO Adresy (id_adres, ulica, numer_domu, numer_mieszkania, miejscowosc, kod_pocztowy)
VALUES (6,'Zywiecka', 31, 14,'Wroclaw', '50-341');

INSERT INTO Adresy (id_adres, ulica, numer_domu, numer_mieszkania, miejscowosc, kod_pocztowy)
VALUES (7,'Debowa', 48, 10, 'Jelenia Gora', '63-754');

INSERT INTO Adresy (id_adres, ulica, numer_domu, numer_mieszkania, miejscowosc, kod_pocztowy)
VALUES (8,'Boh. Monte Cassino', 102, 5, 'Legnica', '61-327');


INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (45328713244, 'Marta', 'Zalewska',479652317, 6);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (45326413244, 'Jan', 'Kowalski', 654389412, 7);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (78953214695, 'Grazyna', 'Nowak', 845763215, 8);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (46751238421, 'Zbigniew', 'Zalewski', 786413589, 6);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (91236547852, 'Janusz', 'Kowalski', 796432554, 7);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (75486323365, 'Monika', 'Zalewska', 794785554, 6);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (89563547852, 'Igor', 'Kowalski', 796441144, 7);

INSERT INTO Osoby (pesel, imie, nazwisko,  numer_telefonu, id_adres)
VALUES (75412896566, 'Tomasz', 'Nowak', 791211754, 8);


INSERT INTO Czytelnicy (id_czytelnika, pesel)
VALUES (1, 75412896566);

INSERT INTO Czytelnicy (id_czytelnika, pesel)
VALUES (2, 89563547852);

INSERT INTO Czytelnicy (id_czytelnika, pesel)
VALUES (3, 75486323365);

INSERT INTO Czytelnicy (id_czytelnika, pesel)
VALUES (4, 91236547852);

INSERT INTO Czytelnicy (id_czytelnika, pesel)
VALUES (5, 46751238421);


INSERT INTO Filie (id_filii, nazwa_filii, id_adres)
VALUES (1, 'Skarbnica wiedzy', 1);

INSERT INTO Filie (id_filii, nazwa_filii, id_adres)
VALUES (2, 'Zasoby Wroclaw' , 2);

INSERT INTO Filie (id_filii, nazwa_filii, id_adres)
VALUES (3, 'Biblioteka krasnali', 3);

INSERT INTO Filie (id_filii, nazwa_filii, id_adres)
VALUES (4, 'Glowna biblioteka Opole', 4);

INSERT INTO Filie (id_filii, nazwa_filii, id_adres)
VALUES (5, 'Legnicka biblioteka miejska', 5);


INSERT INTO Pracownicy (id_pracownika, stanowisko, pesel, id_filii)
VALUES (1, 'Bibliotekarz', 45328713244, 1);

INSERT INTO Pracownicy (id_pracownika, stanowisko, pesel, id_filii) 
VALUES (2, 'Bibliotekarz', 45326413244, 2);

INSERT INTO Pracownicy (id_pracownika, stanowisko, pesel, id_filii)
VALUES (3, 'Bibliotekarz', 78953214695, 3);

INSERT INTO Pracownicy (id_pracownika, stanowisko, pesel, id_filii)
VALUES (4, 'Bibliotekarz', 46751238421, 4);

INSERT INTO Pracownicy (id_pracownika, stanowisko, pesel, id_filii)
VALUES (5, 'Bibliotekarz', 91236547852, 5);


INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (1, 'Kryminaly', 1);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (2, 'Kryminaly', 2);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (3, 'Science-fiction', 3);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (4, 'Science-fiction', 4);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (5, 'Beletrystyka', 5);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (6, 'Beletrystyka', 1);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (7, 'Poradniki', 2);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (8, 'Poradniki', 3);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (9, 'Literatura mlodziezowa', 4);

INSERT INTO Dzialy (id_dzialu, nazwa_dzialu, id_filii)
VALUES (10, 'Literatura mlodziezowa', 5);


INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (1, 'Ferdydurke', 'W.Gombrowicz', 1920, 4647787864, 'N', 1);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (2, 'Ferdydurke', 'W.Gombrowicz', 1920, 4647787864, 'N', 2);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (3, 'Igrzyska smierci', 'S.Collins', 2008, 046876832, 'N', 3);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (4, 'Kosoglos', 'S.Collins', 2008, 046877432, 'N', 4);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (5, 'Lalka', 'B.Prus', 1931, 746852, 'N', 5);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (6, 'Miasto z mgly', 'C.L.Zafon', 1946, 78423155, 'N', 6);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (7, 'Pyszne sniadania', 'M.Gessler', 2012, 5486454, 'N', 7);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (8, 'Plewienie roslin', 'O.Gordon', 2015, 77545554, 'N', 8);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (9, 'Gwiazd naszych wina', 'J.Green', 2006, 4564645, 'N', 9);

INSERT INTO Ksiazki (id_ksiazki, tytul, autor, rok_wydania, numer_seryjny, czy_wypozyczona, id_dzialu)
VALUES (10, 'Opowiesci z Narni Ksiaze Kaspian', 'C.S.Lewis', 1987, 77521504, 'N', 10);


INSERT INTO Wypozyczenia (id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika) 
VALUES (1, '28.05.2021', '15.06.2021', 1, 1);

INSERT INTO Wypozyczenia (id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika) 
VALUES (2, '30.05.2021', '25.06.2021', 2, 2);

INSERT INTO Wypozyczenia (id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika) 
VALUES (3, '31.05.2021', '13.06.2021', 3, 3);

INSERT INTO Wypozyczenia (id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika) 
VALUES (4, '29.05.2021', '06.06.2021', 4, 4);

INSERT INTO Wypozyczenia (id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika) 
VALUES (5, '28.05.2021', '15.06.2021', 5, 5);

INSERT INTO Wypozyczenia(id_wypozyczenia, data_wypozyczenia, termin_oddania, id_ksiazki, id_czytelnika)
VALUES (6, '31.05.2021', '03.07.2021', 10, 5);
