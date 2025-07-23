--  Create Database
CREATE DATABASE Hospital;
USE Hospital;

--  Create Tables

-- Patients Table
CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100),
    Gender ENUM('Male', 'Female', 'Other'),
    DOB DATE,
    Contact VARCHAR(15),
    Status VARCHAR(20) DEFAULT 'Admitted'
);

-- Doctors Table
CREATE TABLE Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100),
    Specialty VARCHAR(100),
    Contact VARCHAR(15)
);

-- Visits Table (Appointments/Consultations)
CREATE TABLE Visits (
    VisitID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    VisitDate DATE,
    Diagnosis TEXT,
    Discharged BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Bills Table
CREATE TABLE Bills (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT,
    TotalAmount DECIMAL(10,2),
    PaidAmount DECIMAL(10,2),
    PaymentDate DATE,
    FOREIGN KEY (VisitID) REFERENCES Visits(VisitID)
);

-- Insert Sample data

INSERT INTO Patients (FullName, Gender, DOB, Contact) VALUES 
('Swathi', 'Female', '1995-04-12', '9876543210'),
('Kapoor', 'Male', '1990-09-10', '9898989898'),
('Rekha', 'Female', '2000-01-22', '9123456789');

INSERT INTO Doctors (FullName, Specialty, Contact) VALUES
('Dr. Ram', 'Cardiology', '5000000001'),
('Dr.Vishnu ', 'General Medicine', '6000000001');

INSERT INTO Visits (PatientID, DoctorID, VisitDate, Diagnosis) VALUES
(1, 1, '2025-07-20', 'High BP'),
(2, 2, '2025-07-21', 'Fever & Cold'),
(3, 1, '2025-07-22', 'Chest Pain');

INSERT INTO Bills (VisitID, TotalAmount, PaidAmount, PaymentDate) VALUES
(1, 2000.00, 2000.00, '2025-07-20'),
(2, 1500.00, 1500.00, '2025-07-21');
-- Third visit not paid yet

--  Query Appointments & Payments

-- View upcoming or all visits
SELECT V.VisitID, P.FullName AS Patient, D.FullName AS Doctor, V.VisitDate, V.Diagnosis
FROM Visits V
JOIN Patients P ON V.PatientID = P.PatientID
JOIN Doctors D ON V.DoctorID = D.DoctorID;

-- Unpaid Bills
SELECT B.BillID, P.FullName AS Patient, V.VisitDate, B.TotalAmount, B.PaidAmount
FROM Bills B
JOIN Visits V ON B.VisitID = V.VisitID
JOIN Patients P ON V.PatientID = P.PatientID
WHERE B.TotalAmount > B.PaidAmount;

-- Stored Procedure: Calculate and Insert Bill
DELIMITER //
CREATE PROCEDURE GenerateBill(IN v_id INT, IN amount DECIMAL(10,2))
BEGIN
    INSERT INTO Bills (VisitID, TotalAmount, PaidAmount, PaymentDate)
    VALUES (v_id, amount, 0.00, NULL);
END //
DELIMITER ;

-- Usage: CALL GenerateBill(3, 2500.00);

-- Trigger: Update Patient Status on Discharge
DELIMITER //
CREATE TRIGGER AfterDischarge
AFTER UPDATE ON Visits
FOR EACH ROW
BEGIN
    IF NEW.Discharged = TRUE THEN
        UPDATE Patients SET Status = 'Discharged' WHERE PatientID = NEW.PatientID;
    END IF;
END;
//
DELIMITER ;

-- Visit and Billing Report
-- Summary per patient
SELECT 
    P.FullName AS Patient,
    COUNT(V.VisitID) AS TotalVisits,
    SUM(B.TotalAmount) AS TotalBilled,
    SUM(B.PaidAmount) AS TotalPaid,
    (SUM(B.TotalAmount) - SUM(B.PaidAmount)) AS BalanceDue
FROM Patients P
LEFT JOIN Visits V ON P.PatientID = V.PatientID
LEFT JOIN Bills B ON V.VisitID = B.VisitID
GROUP BY P.PatientID;
