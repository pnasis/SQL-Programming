-- 01. Τα album που περιέχουν στον τίτλο τους τη λέξη Best.
--     [όλα τα στοιχεία των album]
select *
from album
where title like '%Best%';


-- 02. Ποια album των Led Zeppelin καταχωρεί η βάση;
--     [κωδικός_album, τίτλος]
select AlbumId, Title 
from album
where ArtistId = (select ArtistId from artist where name='Led Zeppelin');


-- 03. Το πλήθος των κομματιών (track) για κάθε είδος (genre) σε φθίνουσα κατάταξη
--     ως προς το πλήθος. [όνομα_είδους, πλήθος]
select g.Name, count(TrackId) as cti
from genre g join track t using (GenreId)
group by g.Name
order by cti desc;


-- 04. Για κάθε υπάλληλο, το πλήθος των πελατών που εξυπηρετεί.
--     Να εμφανίζονται και οι υπάλληλοι που δεν εξυπηρετούν κανέναν πελάτη. 
--     [όνομα_υπαλλήλου, επώνυμο_υπαλλήλου, πλήθος]
select distinct e.FirstName, e.LastName, count(SupportRepId)
from employee e left join customer c on e.EmployeeId = c.SupportRepId
group by e.EmployeeId;


-- 05. Συνδυασμοί φορμά ( media_type) και είδους μουσικής που έχουν πάνω από 50 κομμάτια
--     σε φθίνουσα κατάταξη ως προς το πλήθος. [όνομα_φορμά, όνομα_είδους, πλήθος]
select mt.Name, g.Name, count(t.TrackId) as cti
from (mediatype mt join track t using (MediaTypeId)) join genre g using (GenreId)
group by mt.Name, g.Name
having cti>50
order by cti desc;


-- 06. Όλες οι παραγγελίες (invoice) που στάλθηκαν στη 'New York' και περιέχουν κομμάτια που ανήκουν σε
--    παραπάνω από ένα είδος μουσικής [κωδικός_παραγγελίας, πλήθος προϊόντων, συνολικό ποσό1,
--    συνολικό ποσό2]. Για επαλήθευση της ορθότητας των δεδομένων, υπολογίστε το συνολικό ποσό της
--    κάθε παραγγελίας μέσω του unitprice*quantity και μέσω του total.
select res.InvoiceId, sum(sum_of_quantity), res.Total as Total_Amount1, sum(totalam) as Total_Amount2 
from (select t.GenreId, i.InvoiceId, i.Total, sum(il.Quantity) as sum_of_quantity, sum(il.Unitprice*il.Quantity) as totalam 
	  from (invoice i join invoiceline il using (InvoiceId)) join track t using (TrackId)
	  where i.BillingCity = 'New York'
	  group by i.InvoiceId, t.GenreId) res
group by res.InvoiceId
having count(distinct res.GenreID)>1;


-- 07. Οι πελάτες που έχουν αγοράσει track από όλα τα είδη μουσικής που αρχίζουν από S.
--     [όλα τα στοιχεία των πελατών]
select distinct *
from Customer
where CustomerId in (select Invoice.CustomerId
					 from Invoice join InvoiceLine using(InvoiceId)
                     where customer.CustomerId=Invoice.CustomerId and InvoiceLine.TrackId in (select TrackId 
                                                                                              from InvoiceLine
												                                              where TrackId=InvoiceLine.TrackId in (select TrackId
                                                                                                                                    from Track
																																	where GenreId in (select GenreId
                                                                                                                                                      from Genre))));

																																					
-- 08. Εργαζόμενοι που έχουν μεγαλύτερη ηλικία από τον προϊστάμενό τους.
--     [επώνυμο_υπαλλήλου, ημερομηνία_γέννησης_υπαλλήλου, επώνυμο_προϊσταμένου, 
--     ημερομηνία_γέννησης_προϊσταμένου]
select e1.LastName lastname_of_employee, e1.BirthDate birth_date_of_employee, (select e3.LastName from Employee e3 where e3.EmployeeId=e1.ReportsTo) as lastname_of_chief, (select e4.BirthDate from Employee e4 where e4.EmployeeId=e1.ReportsTo) as birth_date_of_chief
from employee e1
where exists (select * from Employee e2 where e2.EmployeeId=e1.ReportsTo and e2.BirthDate>e1.BirthDate);


-- 09. Ο πελάτης από τον Καναδά, με την πιο πρόσφατη παραγγελία
--     [επώνυμο_πελάτη, ημερομηνία_παραγγελίας]
select c.LastName, i.InvoiceDate
from customer c join invoice i using (CustomerId)
where c.Country='Canada' and i.InvoiceDate >= all(select i.InvoiceDate
                                                  from customer c join invoice i using (CustomerId)
                                                  where c.Country='Canada');

       
-- 10. Η playlist με τα περισσότερα κομμάτια
--     [κωδικός_playlist, όνομα_playlist, πλήθος]
select r1.PlaylistId, r1.Name, r1.max
from(select p1.PlaylistId, p1.Name, count(Name) as max
     from playlist p1 join playlisttrack pt1 using (PlaylistId)
     group by p1.PlaylistId) r1
     having max = (select max(count)
                   from(select count(Name) as count from playlist p2 join playlisttrack pt2 using (PlaylistId)
                   group by pt2.PlaylistId) r2);


-- 11. Ποιες playlists έχουν tracks και είδους 'Rock' και 'Metal' [όλα τα στοιχεία της playlist]
select *
from (select distinct PlaylistId
	  from (select distinct TrackId
			from ((select GenreId
				   from Genre
				   where Name = 'Rock') r1 join Track using (GenreId))) r2 join PlaylistTrack using (Trackid)) r3
			join Playlist using (PlaylistId)
			where PlaylistId in (select PlaylistId
								 from (select distinct PlaylistId
									   from (select distinct TrackId
											 from ((select Genreid
												    from Genre
													where Name = 'Metal') r1 join Track using (GenreId))) r2 join PlaylistTrack using (TrackId)) r3
													join Playlist using (PlaylistId));

-- 12. Τα κομμάτια είδους 'Jazz' που δεν έχουν πουληθεί [όνομα, συνθέτης, milliseconds, bytes, τιμή]
select distinct t.Name, t.Composer, t.Milliseconds, t.Bytes, t.UnitPrice
from track t join genre g using(GenreId)
where g.name='Jazz' and t.TrackId not in (select TrackId
								          from InvoiceLine);


-- 13. Οι πελάτες (σε ζεύγη) που έχουν αγοράσει πάνω από δύο κοινά track
--     [ονοματεπώνυμο_πρώτου_πελάτη, ονοματεπώνυμο_δεύτερου_πελάτη]


-- 14. Για τα κομμάτια που το όνομα τους αρχίζει από 'C', τις playlists με όνομα που αρχίζει από 'С' 
--     στις οποίες ανήκουν. 
--     Να εμφανίζονται και τα κομμάτια που δεν ανήκουν σε καμία playlist. [όνομα_κομματιού, όνομα_playlist]
select distinct t.Name , playlists.Name  
from track t left join (select p.Name , pt.TrackId 
                              from playlist p join playlisttrack pt using (PlaylistId)
                              where p.name like 'C%') playlists on playlists.TrackId = t.TrackId 
where t.Name like 'C%';


-- 15. Τα τιμολόγια που έχουν μόνο κομμάτια που ανήκουν σε album που περιέχουν τη λέξη 'Greatest'
--     στον τίτλο. [όλα τα στοιχεία των τιμολογίων]

