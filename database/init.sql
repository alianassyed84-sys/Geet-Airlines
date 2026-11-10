CREATE DATABASE IF NOT EXISTS airline CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airline;

CREATE TABLE IF NOT EXISTS usermaster (
  userid INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  gender CHAR(1) NOT NULL,
  phone VARCHAR(30) NOT NULL,
  address VARCHAR(500),
  usertype TINYINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS locations (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  location VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS provider (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  provider VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS flightmaster (
  flightid INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  flightnumber VARCHAR(20) NOT NULL UNIQUE,
  provider VARCHAR(120) NOT NULL,
  source VARCHAR(120) NOT NULL,
  destination VARCHAR(120) NOT NULL,
  duration VARCHAR(40) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  createddate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_flight_route CHECK (source <> destination),
  CONSTRAINT chk_flight_price CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS bookingmaster (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  flightid INT NOT NULL,
  userid INT NOT NULL,
  flightdate DATE NOT NULL,
  flighttime TIME NOT NULL,
  passenger_name VARCHAR(120),
  passport_no VARCHAR(40),
  nationality VARCHAR(60),
  dob VARCHAR(30),
  gender VARCHAR(10),
  seat VARCHAR(10),
  cabin_class VARCHAR(30),
  meal VARCHAR(50),
  contact_phone VARCHAR(30),
  contact_email VARCHAR(254),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_booking_flight FOREIGN KEY (flightid) REFERENCES flightmaster(flightid),
  CONSTRAINT fk_booking_user FOREIGN KEY (userid) REFERENCES usermaster(userid)
);

CREATE TABLE IF NOT EXISTS contactus (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL,
  message TEXT NOT NULL,
  userid INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contact_user FOREIGN KEY (userid) REFERENCES usermaster(userid)
);

INSERT IGNORE INTO locations(location) VALUES
 ('Delhi'), ('Mumbai'), ('Bengaluru'), ('Chennai'), ('Kolkata'), ('Hyderabad'), ('Pune'), ('Jaipur');
INSERT IGNORE INTO provider(provider) VALUES
 ('Air India'), ('IndiGo'), ('SpiceJet'), ('Vistara');
INSERT IGNORE INTO flightmaster(flightnumber, provider, source, destination, duration, price) VALUES
 ('AI101', 'Air India', 'Delhi', 'Mumbai', '2h 10m', 5499.00),
 ('6E205', 'IndiGo', 'Mumbai', 'Bengaluru', '1h 45m', 4299.00),
 ('SG312', 'SpiceJet', 'Delhi', 'Jaipur', '1h 00m', 2499.00);

-- After registering your own account, grant administrator access if needed:
-- UPDATE usermaster SET usertype = 1 WHERE email = 'your-email@example.com';
