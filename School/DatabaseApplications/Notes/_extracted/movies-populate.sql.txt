/*  Populating Data for the Movies Database  */


/* Populate tables*/

/*      2.  Data Population           */
/*      2.1. director                 */

INSERT INTO director VALUES
(1, 'Allen, Woody', 1935, NULL);
INSERT INTO director VALUES
(2, 'Hitchcock, Alfred', 1899, 1980);
INSERT INTO director VALUES
(3, 'De Mille, Cecil B', 1881, 1959);
INSERT INTO director VALUES
(4, 'Kramer, Stanley', 1913, NULL);
INSERT INTO director VALUES
(5, 'Kubrick, Stanley', 1928, NULL);
INSERT INTO director VALUES
(6, 'Preminger, Otto', 1906, NULL);
INSERT INTO director VALUES
(7, 'Ford, John', 1895, 1973);
INSERT INTO director VALUES
(8, 'Fellini, Federico', 1920, 1994);


/*      2.2. STAR               */



INSERT INTO star VALUES
(1, 'Allen, Woody', 'New York', 1935, NULL);
INSERT INTO star VALUES
(2, 'Keaton, Diane', 'Los Angeles', 1946, NULL);
INSERT INTO star VALUES
(3, 'Sellers, Peter', 'Southsea, Eng.', 1925, 1980);
INSERT INTO star VALUES
(4, 'Scott, George C.', 'Wise, Va.', 1927, NULL);
INSERT INTO star VALUES
(5, 'McDowell, Malcolm', 'Leeds, Eng.', 1943, NULL);
INSERT INTO star VALUES
(6, 'Grant, Cary', 'Bristol, Eng.', 1904, 1986);
INSERT INTO star VALUES
(7, 'Saint, Eva Marie', 'Newark, N.J.', 1929, NULL);
INSERT INTO star VALUES
(8, 'Stewart, James', 'Indiana, Pa.', 1908, NULL);
INSERT INTO star VALUES
(9, 'Perkins, Anthony', 'New York', 1932, NULL);
INSERT INTO star VALUES
(10, 'Leigh, Janet', 'Merced, Cal.', 1927, NULL);
INSERT INTO star VALUES
(11, 'Taylor, Rod', 'Sydney, Australia', 1930, NULL);
INSERT INTO star VALUES
(12, 'Hedren, Tippi', 'Lafayette, Minn.', 1935, NULL);
INSERT INTO star VALUES
(13, 'Mature, Victor', 'Louisville, Ky.', 1916, NULL);
INSERT INTO star VALUES
(14, 'Tracy, Spencer', 'Milwaukee', 1900, 1967);
INSERT INTO star VALUES
(15, 'Hepburn, Katharine', 'Hartford', 1909, NULL);
INSERT INTO star VALUES
(16, 'Dullea, Keir', 'Cleveland', 1939, NULL);
INSERT INTO star VALUES
(17, 'Novak, Kim', 'Chacago', 1933, NULL);
INSERT INTO star VALUES
(18, 'Sinatra, Frank', 'Hoboken, N.J.', 1915, NULL);
INSERT INTO star VALUES
(19, 'March, Frederick', 'Racine, Wis', 1897, 1975);
INSERT INTO star VALUES
(20, 'Andrews, Dana', 'Collins, Miss.', 1912, NULL);
INSERT INTO star VALUES
(21, 'Heston, Charlton', 'Evanston, Ill.', 1923, NULL);
INSERT INTO star VALUES
(22, 'McNamara, Maggie', 'New York', 1928, 1978);
INSERT INTO star VALUES
(23, 'Niven, David', 'Kirriemuir, Scot.', 1910, 1983);
INSERT INTO star VALUES
(24, 'Wayne, John', 'Winterset, Iowa', 1907, 1979);
INSERT INTO star VALUES
(25, 'Gable, Clark', 'Cadiz, O.', 1901, 1960);
INSERT INTO star VALUES
(26, 'Kelly, Grace', 'Philadelphia', 1929, 1982);
INSERT INTO star VALUES
(27, 'Fonda, Henry', 'Grand Island, Neb.', 1905, 1982);
INSERT INTO star VALUES
(28, 'Chaplin, Charlie', 'Unknown, USA.', 1905, 1982);
INSERT INTO star VALUES
(29, 'Keaton, Buster', 'Unknown, USA.', NULL, 1960);
INSERT INTO star VALUES
(30, 'Cannet, Geoffrey', 'Unknown, Aus.', NULL, NULL);


/*      2.3. movie             */

INSERT INTO movie VALUES
   (1, 'Annie Hall', 1977, 'COMEDY', 4, 'PG', 5, 4, 1);

INSERT INTO movie VALUES
   (2, 'Dr. Strangelove', 1964, 'COMEDY', 4, 'PG', 4, 0, 5);

INSERT INTO movie VALUES
   (3, 'Clockwork Orange', 1971, 'SCI FI', 4, 'R', 3, 0, 5);

INSERT INTO movie VALUES
   (4, 'North by Northwest', 1959, 'SUSPEN', 4, 'PG', 1, 0, 2);

INSERT INTO movie VALUES
   (5, 'Rope', 1948, 'SUSPEN', 3, 'NR', 0, 0, 2);

INSERT INTO movie VALUES
   (6, 'Psycho', 1960, 'HORROR', 4, 'PG', 3, 0, 2);

INSERT INTO movie VALUES
   (7, 'Interiors', 1978, 'DRAMA', 3, 'PG', 3, 0, 1);

INSERT INTO movie VALUES
   (8, 'The Birds', 1963, 'HORROR', 3, 'NR', 0, 0, 2);

INSERT INTO movie VALUES
   (9, 'Samson and Delilah', 1949, 'RELIGI', 2, 'NR', 1, 0, 3);

INSERT INTO movie VALUES
   (10, 'Guess Who''s Coming to Dinner', 1967, 'COMEDY', 3, 'NR', 6, 2, 4);

INSERT INTO movie VALUES
   (11, 'Manhattan', 1979, 'COMEDY', 4, 'R', 2, 0, 1);

INSERT INTO movie VALUES
   (12, 'Vertigo', 1958, 'SUSPEN', 4, 'NR', 0, 0, 2);

INSERT INTO movie VALUES
   (13, 'Judgment at Nuremberg', 1961, 'DRAMA', 3, 'NR', 6, 2, 4);

INSERT INTO movie VALUES
   (14, '2001', 1968, 'SCI FI', 4, 'G', 2, 0, 5);

INSERT INTO movie VALUES
   (15, 'The Man with the Golden Arm', 1955, 'DRAMA', 3, 'NR', 1, 0, 6);

INSERT INTO movie VALUES
   (16, 'Anatomy of Murder', 1959, 'SUSPEN', 4, 'NR', 4, 0, 6);

INSERT INTO movie VALUES
   (17, 'Inherit the Wind', 1960, 'DRAMA', 4, 'NR', 2, 0, 4);

INSERT INTO movie VALUES
   (18, 'Laura', 1944, 'SUSPEN', 4, 'NR', 3, 1, 6);

INSERT INTO movie VALUES
   (19, 'The Ten Commandments', 1956, 'RELIGI', 3, 'NR', 1, 0, 3);

INSERT INTO movie VALUES
   (20, 'The Moon is Blue', 1953, 'COMEDY', 2, 'NR', 1, 0, 6);

INSERT INTO movie VALUES
   (21, 'Stagecoach', 1939, 'WESTER', 4, 'NR', 3, 1, 7);

INSERT INTO movie VALUES
   (22, 'Rear Window', 1954, 'SUSPEN', 4, 'NR', 1, 0, 2);

INSERT INTO movie VALUES
   (23, 'Mogambo', 1953, 'WESTER', 3, 'NR', 2, 0, 7);

INSERT INTO movie VALUES
   (24, 'Grapes of Wrath', 1940, 'DRAMA', 4, 'NR', 4, 2, 7);






/*      2.4. movstar             */


INSERT INTO movstar VALUES
   (1, 1);

INSERT INTO movstar VALUES
   (1, 2);

INSERT INTO movstar VALUES
   (2, 3);

INSERT INTO movstar VALUES
   (2, 4);

INSERT INTO movstar VALUES
   (3, 5);

INSERT INTO movstar VALUES
   (4, 6);

INSERT INTO movstar VALUES
   (4, 7);

INSERT INTO movstar VALUES
   (5, 8);

INSERT INTO movstar VALUES
   (6, 9);

INSERT INTO movstar VALUES
   (6, 10);

INSERT INTO movstar VALUES
   (7, 2);

INSERT INTO movstar VALUES
   (8, 11);

INSERT INTO movstar VALUES
   (8, 12);

INSERT INTO movstar VALUES
   (9, 13);

INSERT INTO movstar VALUES
   (10, 14);

INSERT INTO movstar VALUES
   (10, 15);

INSERT INTO movstar VALUES
   (11, 1);

INSERT INTO movstar VALUES
   (11, 2);

INSERT INTO movstar VALUES
   (12, 8);

INSERT INTO movstar VALUES
   (12, 17);

INSERT INTO movstar VALUES
   (13, 14);

INSERT INTO movstar VALUES
   (14, 16);

INSERT INTO movstar VALUES
   (15, 17);

INSERT INTO movstar VALUES
   (15, 18);

INSERT INTO movstar VALUES
   (16, 8);

INSERT INTO movstar VALUES
   (17, 14);

INSERT INTO movstar VALUES
   (17, 19);

INSERT INTO movstar VALUES
   (18, 20);

INSERT INTO movstar VALUES
   (19, 21);

INSERT INTO movstar VALUES
   (20, 22);

INSERT INTO movstar VALUES
   (20, 23);

INSERT INTO movstar VALUES
   (21, 24);

INSERT INTO movstar VALUES
   (22, 8);

INSERT INTO movstar VALUES
   (22, 26);

INSERT INTO movstar VALUES
   (23, 25);

INSERT INTO movstar VALUES
   (23, 26);

INSERT INTO movstar VALUES
   (24, 27);





/*      2.5. member          */


INSERT INTO member VALUES
   (1, 'Allen, Donna', '21 Wilson', 'Carson', 'In', 2, 0, '25-MAY-91');

INSERT INTO member VALUES
   (2, 'Peterson, Mark', '215 Raymond', 'Cedar', 'In', 14, 1, '20-FEB-90');

INSERT INTO member VALUES
   (3, 'Sanchez, Miguel', '47 Chipwood', 'Hudson', 'Mi', 22, 0, '21-JUN-91');

INSERT INTO member VALUES
   (4, 'Tran, Thanh', '108 College', 'Carson', 'In', 3, 0, '03-JUL-91');

INSERT INTO member VALUES
   (5, 'Roberts, Terry', '602 Bridge', 'Hudson', 'Mi', 1, 0, '16-NOV-90');

INSERT INTO member VALUES
   (6, 'MacDonald, Greg', '19 Oak', 'Carson', 'In', 11, 1, '29-JAN-91');

INSERT INTO member VALUES
   (7, 'VanderJagt, Neal', '12 Bishop', 'Mantin', 'Il', 19, 2, '11-AUG-90');

INSERT INTO member VALUES
   (8, 'Shippers, John', '208 Grayton', 'Cedar', 'In', 6, 1, '02-SEP-91');

INSERT INTO member VALUES
   (9, 'Franklin, Trudy', '103 Bedford', 'Brook', 'Mi', 27, 3, '13-DEC-90');

INSERT INTO member VALUES
   (10, 'Stein, Shelly', '82 Harcourt', 'Hudson', 'Mi', 4, 0, '21-JUN-91');

INSERT INTO member VALUES
   (11, 'Stein, Billy', '60 Oakland', 'Cedar', 'In', 2, 0, '27-FEB-92');

INSERT INTO member VALUES
   (12, 'Stein, Angie', '82 North', 'Hudson', 'Mi', 14, 0, '21-JUN-91');

INSERT INTO member VALUES
   (13, 'Stein, Willy', '80 Harcourt', 'Hudson', 'Mi', 44, 1, '21-JUN-91');



/*      2.6. borrow          */


INSERT INTO borrow VALUES
   (1, 1, '26-APR-90', 1);

INSERT INTO borrow VALUES
   (2, 2, '26-APR-90', 2);

INSERT INTO borrow VALUES
   (3, 3, '26-APR-90', 6);

INSERT INTO borrow VALUES
   (4, 14, '11-OCT-90', 10);

INSERT INTO borrow VALUES
   (5, 5, '05-DEC-90', 4);

INSERT INTO borrow VALUES
   (6, 6, '05-DEC-90', 8);

INSERT INTO borrow VALUES
   (7, 7, '05-DEC-90', 2);

INSERT INTO borrow VALUES
   (8, 8, '05-DEC-90', 8);

INSERT INTO borrow VALUES
   (9, 6, '26-JUN-90', 1);

INSERT INTO borrow VALUES
   (10, 9, '26-JUN-90', 3);

INSERT INTO borrow VALUES
   (11, 10, '26-JUN-90', 10);

INSERT INTO borrow VALUES
   (12, 11, '11-JUL-90', 6);

INSERT INTO borrow VALUES
   (13, 12, '02-AUG-90', 4);

INSERT INTO borrow VALUES
   (14, 6, '02-AUG-90', 5);

INSERT INTO borrow VALUES
   (15, 13, '25-AUG-90', 2);

INSERT INTO borrow VALUES
   (16, 14, '25-AUG-90', 7);

INSERT INTO borrow VALUES
   (17, 15, '07-SEP-90', 11);

INSERT INTO borrow VALUES
   (18, 16, '07-SEP-90', 8);

INSERT INTO borrow VALUES
   (19, 17, '23-SEP-90', 3);

INSERT INTO borrow VALUES
   (20, 14, '12-OCT-90', 3);

INSERT INTO borrow VALUES
   (21, 18, '15-NOV-90', 8);

INSERT INTO borrow VALUES
   (22, 19, '15-NOV-90', 3);

INSERT INTO borrow VALUES
   (23, 20, '21-DEC-90', 4);

INSERT INTO borrow VALUES
   (24, 21, '11-JAN-91', 7);

INSERT INTO borrow VALUES
   (25, 22, '14-FEB-91', 2);

INSERT INTO borrow VALUES
   (26, 23, '14-FEB-91', 1);

INSERT INTO borrow VALUES
   (27, 24, '06-MAR-91', 3);

INSERT INTO borrow VALUES
   (28, 24, '05-MAR-91', 10);

INSERT INTO borrow VALUES
   (29, 9, '25-JUN-90', 10);

INSERT INTO borrow VALUES
   (30, 24, '01-JAN-90', 11);

INSERT INTO borrow VALUES
   (31, 9, '01-JUN-90', 11);

INSERT INTO borrow VALUES
   (32, 14, '06-SEP-90', 11);

INSERT INTO borrow VALUES
   (33, 6, '01-JAN-89', 11);

INSERT INTO borrow VALUES
   (34, 2, '08-FEB-90', 11);
