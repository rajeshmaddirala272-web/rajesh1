import streamlit as st
import mysql.connector
from mysql.connector import Error

# -----------------------------
# MySQL Connection
# -----------------------------
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="your_password"
    )


# -----------------------------
# Create Database and Tables
# -----------------------------
def initialize_database():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("CREATE DATABASE IF NOT EXISTS CollegeDB")
        cursor.execute("USE CollegeDB")

        # Student table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS Student (
                Roll_Number INT PRIMARY KEY,
                Name VARCHAR(50),
                Date_of_Birth DATE,
                Address VARCHAR(100),
                Marks INT,
                Phone_Number VARCHAR(15)
            )
        """)

        # Paper table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS Paper (
                Paper_Code VARCHAR(10) PRIMARY KEY,
                Name_of_Paper VARCHAR(50)
            )
        """)

        # Attendance table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS Attendance (
                College_Roll_Number INT,
                Paper_Code VARCHAR(10),
                Attendance DECIMAL(5,2),

                PRIMARY KEY (College_Roll_Number, Paper_Code),

                FOREIGN KEY (College_Roll_Number)
                    REFERENCES Student(Roll_Number),

                FOREIGN KEY (Paper_Code)
                    REFERENCES Paper(Paper_Code)
            )
        """)

        conn.commit()
        cursor.close()
        conn.close()

        return True

    except Error as e:
        st.error(f"Database Error: {e}")
        return False


# -----------------------------
# Get CollegeDB Connection
# -----------------------------
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="your_password",
        database="CollegeDB"
    )


# -----------------------------
# Initialize
# -----------------------------
st.set_page_config(
    page_title="College Database",
    page_icon="🎓",
    layout="wide"
)

st.title("🎓 College Database Management System")

if initialize_database():
    st.success("CollegeDB connected successfully!")


# -----------------------------
# Sidebar Menu
# -----------------------------
menu = st.sidebar.selectbox(
    "Select Operation",
    [
        "Home",
        "Add Student",
        "Add Paper",
        "Add Attendance",
        "View Students",
        "View Papers",
        "View Attendance"
    ]
)


# =====================================================
# HOME
# =====================================================
if menu == "Home":

    st.header("Welcome to College Database")

    st.write("""
    This application manages the following tables:

    - 👨‍🎓 Student
    - 📚 Paper
    - 📋 Attendance
    """)


# =====================================================
# ADD STUDENT
# =====================================================
elif menu == "Add Student":

    st.header("👨‍🎓 Add Student")

    with st.form("student_form"):

        roll_number = st.number_input(
            "Roll Number",
            min_value=1,
            step=1
        )

        name = st.text_input("Name")

        dob = st.date_input("Date of Birth")

        address = st.text_area("Address")

        marks = st.number_input(
            "Marks",
            min_value=0,
            max_value=100,
            step=1
        )

        phone = st.text_input("Phone Number")

        submit = st.form_submit_button("Add Student")

        if submit:

            try:
                conn = get_db_connection()
                cursor = conn.cursor()

                query = """
                    INSERT INTO Student
                    (Roll_Number, Name, Date_of_Birth,
                     Address, Marks, Phone_Number)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """

                values = (
                    roll_number,
                    name,
                    dob,
                    address,
                    marks,
                    phone
                )

                cursor.execute(query, values)

                conn.commit()

                st.success("Student added successfully!")

                cursor.close()
                conn.close()

            except Error as e:
                st.error(f"Error: {e}")


# =====================================================
# ADD PAPER
# =====================================================
elif menu == "Add Paper":

    st.header("📚 Add Paper")

    with st.form("paper_form"):

        paper_code = st.text_input("Paper Code")

        paper_name = st.text_input("Name of Paper")

        submit = st.form_submit_button("Add Paper")

        if submit:

            try:
                conn = get_db_connection()
                cursor = conn.cursor()

                query = """
                    INSERT INTO Paper
                    (Paper_Code, Name_of_Paper)
                    VALUES (%s, %s)
                """

                cursor.execute(
                    query,
                    (paper_code, paper_name)
                )

                conn.commit()

                st.success("Paper added successfully!")

                cursor.close()
                conn.close()

            except Error as e:
                st.error(f"Error: {e}")


# =====================================================
# ADD ATTENDANCE
# =====================================================
elif menu == "Add Attendance":

    st.header("📋 Add Attendance")

    with st.form("attendance_form"):

        roll_number = st.number_input(
            "College Roll Number",
            min_value=1,
            step=1
        )

        paper_code = st.text_input("Paper Code")

        attendance = st.number_input(
            "Attendance (%)",
            min_value=0.0,
            max_value=100.0,
            step=0.5
        )

        submit = st.form_submit_button("Add Attendance")

        if submit:

            try:
                conn = get_db_connection()
                cursor = conn.cursor()

                query = """
                    INSERT INTO Attendance
                    (College_Roll_Number, Paper_Code, Attendance)
                    VALUES (%s, %s, %s)
                """

                cursor.execute(
                    query,
                    (
                        roll_number,
                        paper_code,
                        attendance
                    )
                )

                conn.commit()

                st.success("Attendance added successfully!")

                cursor.close()
                conn.close()

            except Error as e:
                st.error(f"Error: {e}")


# =====================================================
# VIEW STUDENTS
# =====================================================
elif menu == "View Students":

    st.header("👨‍🎓 Student Records")

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM Student")

        records = cursor.fetchall()

        cursor.close()
        conn.close()

        if records:
            st.dataframe(
                records,
                use_container_width=True
            )
        else:
            st.info("No student records found.")

    except Error as e:
        st.error(f"Error: {e}")


# =====================================================
# VIEW PAPERS
# =====================================================
elif menu == "View Papers":

    st.header("📚 Paper Records")

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM Paper")

        records = cursor.fetchall()

        cursor.close()
        conn.close()

        if records:
            st.dataframe(
                records,
                use_container_width=True
            )
        else:
            st.info("No paper records found.")

    except Error as e:
        st.error(f"Error: {e}")


# =====================================================
# VIEW ATTENDANCE
# =====================================================
elif menu == "View Attendance":

    st.header("📋 Attendance Records")

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT
                a.College_Roll_Number,
                s.Name,
                a.Paper_Code,
                p.Name_of_Paper,
                a.Attendance
            FROM Attendance a
            JOIN Student s
                ON a.College_Roll_Number = s.Roll_Number
            JOIN Paper p
                ON a.Paper_Code = p.Paper_Code
        """

        cursor.execute(query)

        records = cursor.fetchall()

        cursor.close()
        conn.close()

        if records:
            st.dataframe(
                records,
                use_container_width=True
            )
        else:
            st.info("No attendance records found.")

    except Error as e:
        st.error(f"Error: {e}")

