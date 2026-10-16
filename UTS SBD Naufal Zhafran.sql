DROP TABLE IF EXISTS Booking, Room, Guest, Hotel CASCADE;

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE Hotel (
    hotelNo    VARCHAR(8)   NOT NULL,
    hotelName  VARCHAR(50)  NOT NULL,
    city       VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_hotel PRIMARY KEY (hotelNo)
);

CREATE TABLE Guest (
    guestNo       VARCHAR(8)   NOT NULL,
    guestName     VARCHAR(50)  NOT NULL,
    guestAddress  VARCHAR(100),
    CONSTRAINT pk_guest PRIMARY KEY (guestNo)
);

CREATE TABLE Room (
    roomNo   INTEGER      NOT NULL,
    hotelNo  VARCHAR(8)   NOT NULL,
    type     VARCHAR(10)  NOT NULL DEFAULT 'Single',
    price    NUMERIC(6,2) NOT NULL,
    CONSTRAINT pk_room       PRIMARY KEY (roomNo, hotelNo),
    CONSTRAINT fk_room_hotel FOREIGN KEY (hotelNo) REFERENCES Hotel(hotelNo)
        ON UPDATE CASCADE ON DELETE CASCADE,
		
    -- (a) type harus Single, Double, atau Family
    CONSTRAINT ck_room_type  CHECK (type IN ('Single','Double','Family')),
	
    -- (b) price antara 10 dan 100
    CONSTRAINT ck_room_price CHECK (price BETWEEN 10 AND 100),
	
    -- (c) roomNo antara 1 dan 100
    CONSTRAINT ck_room_no    CHECK (roomNo BETWEEN 1 AND 100)
);

CREATE TABLE Booking (
    hotelNo   VARCHAR(8) NOT NULL,
    guestNo   VARCHAR(8) NOT NULL,
    dateFrom  DATE       NOT NULL,
    dateTo    DATE       NOT NULL,
    roomNo    INTEGER    NOT NULL,
    CONSTRAINT pk_booking PRIMARY KEY (hotelNo, guestNo, dateFrom),
    CONSTRAINT fk_booking_hotel FOREIGN KEY (hotelNo) REFERENCES Hotel(hotelNo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_booking_guest FOREIGN KEY (guestNo) REFERENCES Guest(guestNo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_booking_room  FOREIGN KEY (roomNo, hotelNo) REFERENCES Room(roomNo, hotelNo)
        ON UPDATE CASCADE ON DELETE CASCADE,

    -- (d) dateFrom dan dateTo harus lebih besar dari tanggal hari ini
    CONSTRAINT ck_booking_from CHECK (dateFrom > CURRENT_DATE),
    CONSTRAINT ck_booking_to   CHECK (dateTo   > CURRENT_DATE),
    CONSTRAINT ck_booking_order CHECK (dateTo > dateFrom),

    -- (e) Kamar yang sama tidak boleh double-booked
    CONSTRAINT ex_room_no_overlap EXCLUDE USING gist (
        hotelNo WITH =, roomNo WITH =,
        daterange(dateFrom, dateTo, '[)') WITH &&
    ),
    -- (f) Tamu yang sama tidak boleh booking tumpang tindih
    CONSTRAINT ex_guest_no_overlap EXCLUDE USING gist (
        guestNo WITH =,
        daterange(dateFrom, dateTo, '[)') WITH &&
    )
);

-- Data Uji
INSERT INTO Hotel VALUES ('H001','Grand Jakarta','Jakarta');
INSERT INTO Guest VALUES ('G001','Budi Santoso','Jl. Merdeka 1, Jakarta'),
                         ('G002','Siti Aminah','Jl. Sudirman 5, Bandung');
INSERT INTO Room  VALUES (1,'H001','Single',50.00),(2,'H001','Double',80.00);

INSERT INTO Booking VALUES ('H001','G001', CURRENT_DATE+10, CURRENT_DATE+15, 1);
