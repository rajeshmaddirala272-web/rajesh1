--create a database (college DB)

CREATE DATABASE CollegeDB;

USE CollegeDB;

--create a table student (Roll_number as PK)

CREATE TABLE Student (
    Roll_Number INT PRIMARY KEY,
    Name VARCHAR(50),
    Date_of_Birth DATE,
    Address VARCHAR(100),
    Marks INT,
    Phone_Number VARCHAR(15)
);

--create a table paper (paper_code as PK)

CREATE TABLE Paper (
    Paper_Code VARCHAR(10) PRIMARY KEY,
    Name_of_Paper VARCHAR(50)
);

/* create a table attendence (college_roll_number ,paper_code as primary key*/

CREATE TABLE Attendance (
    College_Roll_Number INT,
    Paper_Code VARCHAR(10),
    Attendance DECIMAL(5,2),

    PRIMARY KEY (College_Roll_Number, Paper_Code),

    FOREIGN KEY (College_Roll_Number)
        REFERENCES Student(Roll_Number),

    FOREIGN KEY (Paper_Code)
        REFERENCES Paper(Paper_Code)
);
