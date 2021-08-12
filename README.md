# Baza-danych-dla-biblioteki

Skrypt napisany w ramach projektu z przedmiotu Bazy Danych. Jest on przystosowany do uruchamiania w SQL Developer.<br>

Tabele zawarte w bazie danych: <br>
![obraz](https://user-images.githubusercontent.com/65178593/129171930-7c4ef11d-b4e5-4875-9260-a69228bb2ab2.png)
![obraz](https://user-images.githubusercontent.com/65178593/129171960-730722fc-5111-4bc7-aa80-6ee7a31e1631.png)
![obraz](https://user-images.githubusercontent.com/65178593/129171980-7d3304ce-fa75-4c62-b4c1-9cd3e0342593.png)

Widoki zawarte w bazie danych:<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172019-0f858ea8-004a-480b-b27a-18ae3cab6c28.png)

Triggery:<br>
* sprawdza, czy nowy termin oddania jest późniejszy niż stary<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172769-3f0d7a8b-63b9-4901-ad49-02f3b41dcb01.png)

* zmienia status książki na wypożyczoną przy wypożyczeniu jej czytelnikowi<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172814-80ba6bbc-86a3-44a7-bbb5-ea5ec308f6e5.png)

* zmienia status książki na niewypożyczoną przy jej zwrocie przez czytelnika<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172846-86159362-7e20-4259-9e15-b39f2dd8922d.png)

* sprawdza, czy książka, która ma być usunięta z systemu, jest aktualnie w wypożyczeniu<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172876-4bc343e5-8292-4d0c-821e-6daa4125e343.png)

* uzupełnianie tabeli logów<br>
![obraz](https://user-images.githubusercontent.com/65178593/129172934-8abf0eeb-80c9-471a-a365-b6fdf86fc712.png)
![obraz](https://user-images.githubusercontent.com/65178593/129172963-2968a27b-1a49-495e-a4f2-e14f67c28440.png)
![obraz](https://user-images.githubusercontent.com/65178593/129172991-c9a70c2a-a3ae-4eca-b84e-b8afba9896b0.png)
