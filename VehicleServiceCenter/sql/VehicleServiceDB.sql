CREATE DATABASE VehicleServiceDB;
GO
USE VehicleServiceDB;
GO

CREATE TABLE Customers (
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(255) NULL UNIQUE,
    Address NVARCHAR(300) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE Vehicles (
    VehicleId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerId INT NOT NULL,
    RegistrationNumber NVARCHAR(20) NOT NULL UNIQUE,
    Make NVARCHAR(60) NOT NULL,
    Model NVARCHAR(60) NOT NULL,
    ManufactureYear INT NULL CHECK (ManufactureYear BETWEEN 1980 AND 2100),
    FuelType NVARCHAR(20) NOT NULL DEFAULT N'Petrol',
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Vehicles_Customers
        FOREIGN KEY (CustomerId) REFERENCES Customers(CustomerId),
    CONSTRAINT CK_Vehicles_FuelType
        CHECK (FuelType IN (N'Petrol', N'Diesel', N'Electric', N'Hybrid', N'CNG'))
);

CREATE TABLE ServiceTypes (
    ServiceTypeId INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(300) NULL,
    StandardPrice DECIMAL(10,2) NOT NULL CHECK (StandardPrice >= 0),
    EstimatedMinutes INT NOT NULL CHECK (EstimatedMinutes > 0),
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE ServiceBookings (
    BookingId INT IDENTITY(1,1) PRIMARY KEY,
    VehicleId INT NOT NULL,
    BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    OdometerKm INT NULL CHECK (OdometerKm >= 0),
    Complaint NVARCHAR(500) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT N'Booked',
    TotalAmount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (TotalAmount >= 0),
    CONSTRAINT FK_ServiceBookings_Vehicles
        FOREIGN KEY (VehicleId) REFERENCES Vehicles(VehicleId),
    CONSTRAINT CK_ServiceBookings_Status
        CHECK (Status IN (N'Booked', N'InProgress', N'Completed', N'Cancelled'))
);

CREATE TABLE BookingItems (
    BookingItemId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL,
    ServiceTypeId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1 CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    LineTotal AS (CONVERT(DECIMAL(12,2), Quantity * UnitPrice)) PERSISTED,
    CONSTRAINT FK_BookingItems_Bookings
        FOREIGN KEY (BookingId) REFERENCES ServiceBookings(BookingId),
    CONSTRAINT FK_BookingItems_ServiceTypes
        FOREIGN KEY (ServiceTypeId) REFERENCES ServiceTypes(ServiceTypeId),
    CONSTRAINT UQ_BookingItems_Booking_Service UNIQUE (BookingId, ServiceTypeId)
);

CREATE TABLE Invoices (
    InvoiceId INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL UNIQUE,
    InvoiceDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT N'Pending',
    CONSTRAINT FK_Invoices_Bookings
        FOREIGN KEY (BookingId) REFERENCES ServiceBookings(BookingId),
    CONSTRAINT CK_Invoices_PaymentStatus
        CHECK (PaymentStatus IN (N'Pending', N'Paid', N'Failed', N'Refunded'))
);

CREATE TABLE AuditLogs (
    AuditId BIGINT IDENTITY(1,1) PRIMARY KEY,
    EntityName NVARCHAR(50) NOT NULL,
    EntityId INT NOT NULL,
    Action NVARCHAR(30) NOT NULL,
    Details NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
