-- ============================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS
-- ============================================================================
USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'ChinookStage')
BEGIN
    DROP DATABASE ChinookStage;
END
GO

CREATE DATABASE ChinookStage;
GO

USE ChinookStage;
GO

-- ============================================================================
-- 2. CREACIÓN DE TABLAS
-- ============================================================================

-- Tabla: Artist (Requerimiento 1)
CREATE TABLE [Artist] (
    [ArtistId] INT NOT NULL,
    [Name] NVARCHAR(120) NULL
);
GO

-- Tabla: Genre (Requerimientos 1 y 2)
CREATE TABLE [Genre] (
    [GenreId] INT NOT NULL,
    [Name] NVARCHAR(120) NULL
);
GO

-- Tabla: Album (Requerimiento 1)
CREATE TABLE [Album] (
    [AlbumId] INT NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [ArtistId] INT NOT NULL
);
GO

-- Tabla: Track (Requerimientos 1 y 2)
CREATE TABLE [Track] (
    [TrackId] INT NOT NULL,
    [Name] NVARCHAR(200) NOT NULL,
    [AlbumId] INT NULL,
    [GenreId] INT NULL,
    [UnitPrice] NUMERIC(10,2) NOT NULL
);
GO

-- Tabla: Employee (Requerimiento 4)
CREATE TABLE [Employee] (
    [EmployeeId] INT NOT NULL,
    [LastName] NVARCHAR(20) NOT NULL,
    [FirstName] NVARCHAR(20) NOT NULL,
    [Title] NVARCHAR(30) NULL
);
GO

-- Tabla: Customer (Requerimientos 3 y 4)
CREATE TABLE [Customer] (
    [CustomerId] INT NOT NULL,
    [FirstName] NVARCHAR(40) NOT NULL,
    [LastName] NVARCHAR(20) NOT NULL,
    [City] NVARCHAR(40) NULL,
    [State] NVARCHAR(40) NULL,
    [Country] NVARCHAR(40) NULL,
    [SupportRepId] INT NULL
);
GO

-- Tabla: Invoice (Requerimientos 2, 3 y 4)
CREATE TABLE [Invoice] (
    [InvoiceId] INT NOT NULL,
    [CustomerId] INT NOT NULL,
    [InvoiceDate] DATETIME NOT NULL,
    [BillingCity] NVARCHAR(40) NULL,
    [BillingState] NVARCHAR(40) NULL,
    [BillingCountry] NVARCHAR(40) NULL,
    [Total] NUMERIC(10,2) NOT NULL
);
GO

-- Tabla: InvoiceLine (Requerimientos 1 y 2)
CREATE TABLE [InvoiceLine] (
    [InvoiceLineId] INT NOT NULL,
    [InvoiceId] INT NOT NULL,
    [TrackId] INT NOT NULL,
    [UnitPrice] NUMERIC(10,2) NOT NULL,
    [Quantity] INT NOT NULL
);
GO

-- ============================================================================
-- 3. CREACIÓN DE ÍNDICES OPTIMIZADOS PARA CONSULTAS ANALÍTICAS (OPCIONAL)
-- ============================================================================
CREATE NONCLUSTERED INDEX [IX_Invoice_InvoiceDate] ON [Invoice]([InvoiceDate] ASC);
CREATE NONCLUSTERED INDEX [IX_InvoiceLine_TrackId] ON [InvoiceLine]([TrackId] ASC);
GO
