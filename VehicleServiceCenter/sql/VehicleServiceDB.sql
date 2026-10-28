-- ============================================
-- VEHICLE SERVICE CENTER MANAGEMENT SYSTEM
-- Database Creation Script
-- ============================================

IF DB_ID(N'VehicleServiceDB') IS NULL
BEGIN
    CREATE DATABASE VehicleServiceDB;
END;
GO

USE VehicleServiceDB;
GO

-- ============================================
-- 1. CUSTOMERS TABLE
-- ============================================

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
BEGIN
    CREATE TABLE Customers
    (
        CustomerId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Phone NVARCHAR(20) NOT NULL UNIQUE,
        Email NVARCHAR(255) NULL UNIQUE,
        Address NVARCHAR(300) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        IsActive BIT NOT NULL DEFAULT 1
    );
END;
GO

-- ============================================
-- 2. VEHICLES TABLE
-- ============================================

IF OBJECT_ID(N'dbo.Vehicles', N'U') IS NULL
BEGIN
    CREATE TABLE Vehicles
    (
        VehicleId INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId INT NOT NULL,
        RegistrationNumber NVARCHAR(20) NOT NULL UNIQUE,
        Make NVARCHAR(60) NOT NULL,
        Model NVARCHAR(60) NOT NULL,
        ManufactureYear INT NULL
            CHECK (ManufactureYear BETWEEN 1980 AND 2100),
        FuelType NVARCHAR(20) NOT NULL DEFAULT N'Petrol',
        IsActive BIT NOT NULL DEFAULT 1,

        CONSTRAINT FK_Vehicles_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES Customers(CustomerId),

        CONSTRAINT CK_Vehicles_FuelType
            CHECK
            (
                FuelType IN
                (
                    N'Petrol',
                    N'Diesel',
                    N'Electric',
                    N'Hybrid',
                    N'CNG'
                )
            )
    );
END;
GO

-- ============================================
-- 3. SERVICE TYPES TABLE
-- ============================================

IF OBJECT_ID(N'dbo.ServiceTypes', N'U') IS NULL
BEGIN
    CREATE TABLE ServiceTypes
    (
        ServiceTypeId INT IDENTITY(1,1) PRIMARY KEY,
        ServiceName NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(300) NULL,
        StandardPrice DECIMAL(10,2) NOT NULL
            CHECK (StandardPrice >= 0),
        EstimatedMinutes INT NOT NULL
            CHECK (EstimatedMinutes > 0),
        IsActive BIT NOT NULL DEFAULT 1
    );
END;
GO

-- ============================================
-- 4. SERVICE BOOKINGS TABLE
-- ============================================

IF OBJECT_ID(N'dbo.ServiceBookings', N'U') IS NULL
BEGIN
    CREATE TABLE ServiceBookings
    (
        BookingId INT IDENTITY(1,1) PRIMARY KEY,
        VehicleId INT NOT NULL,
        BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        OdometerKm INT NULL CHECK (OdometerKm >= 0),
        Complaint NVARCHAR(500) NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT N'Booked',
        TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0
            CHECK (TotalAmount >= 0),

        CONSTRAINT FK_ServiceBookings_Vehicles
            FOREIGN KEY (VehicleId)
            REFERENCES Vehicles(VehicleId),

        CONSTRAINT CK_ServiceBookings_Status
            CHECK
            (
                Status IN
                (
                    N'Booked',
                    N'InProgress',
                    N'Completed',
                    N'Cancelled'
                )
            )
    );
END;
GO

-- ============================================
-- 5. BOOKING ITEMS TABLE
-- ============================================

IF OBJECT_ID(N'dbo.BookingItems', N'U') IS NULL
BEGIN
    CREATE TABLE BookingItems
    (
        BookingItemId INT IDENTITY(1,1) PRIMARY KEY,
        BookingId INT NOT NULL,
        ServiceTypeId INT NOT NULL,
        Quantity INT NOT NULL DEFAULT 1
            CHECK (Quantity > 0),
        UnitPrice DECIMAL(10,2) NOT NULL
            CHECK (UnitPrice >= 0),

        LineTotal AS
            (CONVERT(DECIMAL(12,2), Quantity * UnitPrice))
            PERSISTED,

        CONSTRAINT FK_BookingItems_Bookings
            FOREIGN KEY (BookingId)
            REFERENCES ServiceBookings(BookingId),

        CONSTRAINT FK_BookingItems_ServiceTypes
            FOREIGN KEY (ServiceTypeId)
            REFERENCES ServiceTypes(ServiceTypeId),

        CONSTRAINT UQ_BookingItems_Booking_Service
            UNIQUE (BookingId, ServiceTypeId)
    );
END;
GO

-- ============================================
-- 6. INVOICES TABLE
-- ============================================

IF OBJECT_ID(N'dbo.Invoices', N'U') IS NULL
BEGIN
    CREATE TABLE Invoices
    (
        InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
        BookingId INT NOT NULL UNIQUE,
        InvoiceDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        Amount DECIMAL(12,2) NOT NULL
            CHECK (Amount >= 0),
        PaymentStatus NVARCHAR(20) NOT NULL DEFAULT N'Pending',

        CONSTRAINT FK_Invoices_Bookings
            FOREIGN KEY (BookingId)
            REFERENCES ServiceBookings(BookingId),

        CONSTRAINT CK_Invoices_PaymentStatus
            CHECK
            (
                PaymentStatus IN
                (
                    N'Pending',
                    N'Paid',
                    N'Failed',
                    N'Refunded'
                )
            )
    );
END;
GO

-- ============================================
-- 7. AUDIT LOGS TABLE
-- ============================================

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NULL
BEGIN
    CREATE TABLE AuditLogs
    (
        AuditId BIGINT IDENTITY(1,1) PRIMARY KEY,
        EntityName NVARCHAR(50) NOT NULL,
        EntityId INT NOT NULL,
        Action NVARCHAR(30) NOT NULL,
        Details NVARCHAR(500) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Customers

IF NOT EXISTS
(
    SELECT 1 FROM Customers
    WHERE Phone = N'9876543210'
)
BEGIN
    INSERT INTO Customers
        (FullName, Phone, Email, Address)
    VALUES
        (N'Arun Kumar', N'9876543210',
         N'arun@example.com', N'Chennai');
END;

IF NOT EXISTS
(
    SELECT 1 FROM Customers
    WHERE Phone = N'9876543211'
)
BEGIN
    INSERT INTO Customers
        (FullName, Phone, Email, Address)
    VALUES
        (N'Priya Devi', N'9876543211',
         N'priya@example.com', N'Madurai');
END;

IF NOT EXISTS
(
    SELECT 1 FROM Customers
    WHERE Phone = N'9876543212'
)
BEGIN
    INSERT INTO Customers
        (FullName, Phone, Email, Address)
    VALUES
        (N'Kavin Raj', N'9876543212',
         N'kavin@example.com', N'Dindigul');
END;

-- Vehicles

IF NOT EXISTS
(
    SELECT 1 FROM Vehicles
    WHERE RegistrationNumber = N'TN01AB1234'
)
BEGIN
    INSERT INTO Vehicles
        (CustomerId, RegistrationNumber, Make, Model,
         ManufactureYear, FuelType)
    SELECT CustomerId, N'TN01AB1234', N'Maruti Suzuki',
           N'Swift', 2022, N'Petrol'
    FROM Customers
    WHERE Phone = N'9876543210';
END;

IF NOT EXISTS
(
    SELECT 1 FROM Vehicles
    WHERE RegistrationNumber = N'TN58CD5678'
)
BEGIN
    INSERT INTO Vehicles
        (CustomerId, RegistrationNumber, Make, Model,
         ManufactureYear, FuelType)
    SELECT CustomerId, N'TN58CD5678', N'Hyundai',
           N'i20', 2021, N'Diesel'
    FROM Customers
    WHERE Phone = N'9876543211';
END;

IF NOT EXISTS
(
    SELECT 1 FROM Vehicles
    WHERE RegistrationNumber = N'TN57EF9012'
)
BEGIN
    INSERT INTO Vehicles
        (CustomerId, RegistrationNumber, Make, Model,
         ManufactureYear, FuelType)
    SELECT CustomerId, N'TN57EF9012', N'Tata',
           N'Nexon EV', 2024, N'Electric'
    FROM Customers
    WHERE Phone = N'9876543212';
END;

-- Service Types

IF NOT EXISTS
(
    SELECT 1 FROM ServiceTypes
    WHERE ServiceName = N'General Service'
)
BEGIN
    INSERT INTO ServiceTypes
        (ServiceName, Description, StandardPrice, EstimatedMinutes)
    VALUES
        (N'General Service',
         N'Basic vehicle inspection and service',
         1800.00, 120);
END;

IF NOT EXISTS
(
    SELECT 1 FROM ServiceTypes
    WHERE ServiceName = N'Oil Change'
)
BEGIN
    INSERT INTO ServiceTypes
        (ServiceName, Description, StandardPrice, EstimatedMinutes)
    VALUES
        (N'Oil Change',
         N'Engine oil replacement',
         850.00, 45);
END;

IF NOT EXISTS
(
    SELECT 1 FROM ServiceTypes
    WHERE ServiceName = N'Brake Inspection'
)
BEGIN
    INSERT INTO ServiceTypes
        (ServiceName, Description, StandardPrice, EstimatedMinutes)
    VALUES
        (N'Brake Inspection',
         N'Brake system inspection',
         500.00, 30);
END;

IF NOT EXISTS
(
    SELECT 1 FROM ServiceTypes
    WHERE ServiceName = N'Wheel Alignment'
)
BEGIN
    INSERT INTO ServiceTypes
        (ServiceName, Description, StandardPrice, EstimatedMinutes)
    VALUES
        (N'Wheel Alignment',
         N'Wheel alignment and adjustment',
         700.00, 40);
END;
GO

-- ============================================
-- VERIFY TABLES AND SAMPLE DATA
-- ============================================

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT * FROM Customers;
SELECT * FROM Vehicles;
SELECT * FROM ServiceTypes;
GO