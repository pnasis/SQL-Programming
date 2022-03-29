-- 01. Albums that contain the word Best in their title.
--     [all album elements]
select *
from album
where title like '%Best%';


-- 02. Which Led Zeppelin album does the database list?
--     [Album_Id, title]
select AlbumId, Title 
from album
where ArtistId = (select ArtistId from artist where name='Led Zeppelin');


-- 03. The number of tracks for each genre in descending order
-- in terms of amount. [genre_name, amount]
select g.Name, count(TrackId) as cti
from genre g join track t using (GenreId)
group by g.Name
order by cti desc;


-- 04. For each employee, the number of customers it serves.
-- Employees who do not serve any customer should also appear. 
--     [employee_name, employee_lastname, amount]
select distinct e.FirstName, e.LastName, count(SupportRepId)
from employee e left join customer c on e.EmployeeId = c.SupportRepId
group by e.EmployeeId;


-- 05. Combinations of format (media_type) and type of music that have more than 50 tracks
-- in descending order in terms of amount. [mediatype_name, genre_name, amount]
select mt.Name, g.Name, count(t.TrackId) as cti
from (mediatype mt join track t using (MediaTypeId)) join genre g using (GenreId)
group by mt.Name, g.Name
having cti>50
order by cti desc;


-- 06. All orders (invoice) sent to 'New York' and containing pieces belonging to
-- more than one type of music [invoide_InvoiceId, amount of products, total amount1,
-- total amount2]. To verify the accuracy of the data, calculate its total amount
-- each order through the unitprice * quantity and through the total.
select res.InvoiceId, sum(sum_of_quantity), res.Total as Total_Amount1, sum(totalam) as Total_Amount2 
from (select t.GenreId, i.InvoiceId, i.Total, sum(il.Quantity) as sum_of_quantity, sum(il.Unitprice*il.Quantity) as totalam 
      from (invoice i join invoiceline il using (InvoiceId)) join track t using (TrackId)
      where i.BillingCity = 'New York'
      group by i.InvoiceId, t.GenreId) res
group by res.InvoiceId
having count(distinct res.GenreID)>1;


-- 07. Customers who have purchased track from all genres of music starting with S.
-- [all customer details]
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

																																					
-- 08. Employees who are older than their boss.
-- [employee_ lastname, employee_BirthDate, lastname_of_boss,
-- date_of_birth_of_boss]
select e1.LastName lastname_of_employee, e1.BirthDate birth_date_of_employee, (select e3.LastName from Employee e3 where e3.EmployeeId=e1.ReportsTo) as lastname_of_chief, (select e4.BirthDate from Employee e4 where e4.EmployeeId=e1.ReportsTo) as birth_date_of_chief
from employee e1
where exists (select * from Employee e2 where e2.EmployeeId=e1.ReportsTo and e2.BirthDate>e1.BirthDate);


-- 09. Customer from Canada, with the latest order
-- [customer_name, InvoiceDate]
select c.LastName, i.InvoiceDate
from customer c join invoice i using (CustomerId)
where c.Country='Canada' and i.InvoiceDate >= all(select i.InvoiceDate
                                                  from customer c join invoice i using (CustomerId)
                                                  where c.Country='Canada');

       
-- 10. The playlist with the most tracks
-- [PlaylistId, Playlist_Name, amount]
select r1.PlaylistId, r1.Name, r1.max
from(select p1.PlaylistId, p1.Name, count(Name) as max
     from playlist p1 join playlisttrack pt1 using (PlaylistId)
     group by p1.PlaylistId) r1
     having max = (select max(count)
                   from(select count(Name) as count from playlist p2 join playlisttrack pt2 using (PlaylistId)
                   group by pt2.PlaylistId) r2);


-- 11. Which playlists have 'Rock' and 'Metal' genre tracks [all playlist items]
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

-- 12. Unsold 'Jazz' tracks [Name, Composer, Milliseconds, Bytes, UnitPrice]
select distinct t.Name, t.Composer, t.Milliseconds, t.Bytes, t.UnitPrice
from track t join genre g using(GenreId)
where g.name='Jazz' and t.TrackId not in (select TrackId
				          from InvoiceLine);


-- 13. Customers (in pairs) who have purchased more than two common tracks
-- [name_of_first_customer, name_of_second_customer]


-- 14. For tracks whose name starts with 'C', playlists with a name starting with 'С'
-- to which they belong.
-- The tracks that do not belong to any playlist should also be displayed. [track_name, playlist_name]
select distinct t.Name , playlists.Name  
from track t left join (select p.Name , pt.TrackId 
                        from playlist p join playlisttrack pt using (PlaylistId)
                        where p.name like 'C%') playlists on playlists.TrackId = t.TrackId 
where t.Name like 'C%';


-- 15. Invoices that only have tracks that belong to an album that contains the word 'Greatest'
-- in the title. [all invoice details]
select *
from Invoice i 
where i.InvoiceId not in (select InvoiceId
			  from InvoiceLine il 
		          where il.TrackId in (select t.TrackId 
	                                       from Track t 
	                                       where t.AlbumId not in (select a.AlbumId
				                                       from Album a
								       where a.Title like '%Greatest%')));
