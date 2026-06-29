CREATE DATABASE xyz;

\c xyz;

CREATE TABLE faculty (
    faculty VARCHAR(50) PRIMARY KEY,
    faculty_name VARCHAR(100)
);

CREATE TABLE pulpit (
    pulpit VARCHAR(50) PRIMARY KEY,
    pulpit_name VARCHAR(100),
    faculty VARCHAR(50) REFERENCES faculty(faculty)
);

CREATE TABLE subject (
    subject VARCHAR(50) PRIMARY KEY,
    subject_name VARCHAR(100),
    pulpit VARCHAR(50) REFERENCES pulpit(pulpit)
);

CREATE TABLE auditorium_type (
    auditorium_type VARCHAR(50) PRIMARY KEY,
    auditorium_yypername VARCHAR(100)
);

CREATE TABLE auditorium (
    auditorium VARCHAR(50) PRIMARY KEY,
    auditorium_name VARCHAR(100),
    auditorium_capacity INT,
    auditorium_type VARCHAR(50) REFERENCES auditorium_type(auditorium_type)
);