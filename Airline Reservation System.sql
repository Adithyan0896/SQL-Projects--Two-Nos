-- Create Database
CREATE DATABASE AirlineReservation;
USE AirlineReservation;

-- Create Tables
-- Flights Table
CREATE TABLE Flights (
    FlightID INT AUTO_INCREMENT PRIMARY KEY,
    FlightNumber VARCHAR(10),
	Sources VARCHAR(50),
    Destination VARCHAR(50),
    DepartureTime DATETIME,
    ArrivalTime DATETIME
);

-- Passengers Table
CREATE TABLE Passengers (
    PassengerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100),
    Gender ENUM('Male', 'Female', 'Other'),
    Contact VARCHAR(15)
);

-- Seats Table
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    FlightID INT,
    SeatNumber VARCHAR(5),
    SeatClass ENUM('Economy', 'Business'),
    IsBooked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    PassengerID INT,
    SeatID INT,
    BookingDate DATETIME,
    Status ENUM('Confirmed', 'Cancelled') DEFAULT 'Confirmed',
    FOREIGN KEY (PassengerID) REFERENCES Passengers(PassengerID),
    FOREIGN KEY (SeatID) REFERENCES Seats(SeatID)
);

-- Insert Sample Records

-- Flights
INSERT INTO Flights (FlightNumber, Sources, Destination, DepartureTime, ArrivalTime) VALUES
('SJ101', 'Chennai', 'Mumbai', '2025-07-25 08:00:00', '2025-07-25 10:00:00'),
('SJ202', 'Mumbai', 'Bangalore', '2025-07-26 09:00:00', '2025-07-26 11:30:00');

-- Passengers
INSERT INTO Passengers (FullName, Gender, Contact) VALUES
('Ravi', 'Male', '9876543210'),
('sheela', 'Female', '9123456789');

-- Seats
INSERT INTO Seats (FlightID, SeatNumber, SeatClass) VALUES
(1, '1A', 'Business'),
(1, '2B', 'Economy'),
(2, '3A', 'Business'),
(2, '4C', 'Economy');

-- Bookings
INSERT INTO Bookings (PassengerID, SeatID, BookingDate) VALUES
(1, 1, NOW());

-- Update seat as booked manually (or via trigger)
UPDATE Seats SET IsBooked = TRUE WHERE SeatID = 1;

--  Queries

-- a. Available Seats for a Flight
SELECT F.FlightNumber, S.SeatNumber, S.SeatClass
FROM Seats S
JOIN Flights F ON S.FlightID = F.FlightID
WHERE S.IsBooked = FALSE;

-- b. Search Flights from Source to Destination
SELECT * FROM Flights
WHERE Sources= 'Delhi' AND Destination = 'Mumbai';

-- 5. Triggers

-- a. Trigger to mark seat as booked when booking is made
DELIMITER //
CREATE TRIGGER AfterBooking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats SET IsBooked = TRUE WHERE SeatID = NEW.SeatID;
END;
//
DELIMITER ;

-- b. Trigger to mark seat as available on cancellation
DELIMITER //
CREATE TRIGGER AfterCancellation
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Seats SET IsBooked = FALSE WHERE SeatID = NEW.SeatID;
    END IF;
END;
//
DELIMITER ;

-- 6. Booking Summary Report

SELECT 
    P.FullName AS Passenger,
    F.FlightNumber,
    F.Sources,
    F.Destination,
    F.DepartureTime,
    S.SeatNumber,
    S.SeatClass,
    B.BookingDate,
    B.Status
FROM Bookings B
JOIN Passengers P ON B.PassengerID = P.PassengerID
JOIN Seats S ON B.SeatID = S.SeatID
JOIN Flights F ON S.FlightID = F.FlightID;

