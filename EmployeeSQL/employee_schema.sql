-- EXECUTE ANONYMOUS BLOCK SO CSV PATH CAN BE PLACED IN VARIABLE
-- Create procedure for loading CSVs
CREATE OR REPLACE PROCEDURE proc_load_csv (var_table_name   VARCHAR,
                                           var_file_name    VARCHAR,
                                           var_csv_path     VARCHAR)
   LANGUAGE plpgsql AS $$
   BEGIN
      EXECUTE FORMAT('COPY %s FROM ''%s\%s.csv'' DELIMITER '','' CSV HEADER', 
                var_table_name,
                var_csv_path,
                var_file_name);
      RAISE INFO 'Successfully loaded %.csv to Table %',var_file_name,UPPER(var_table_name);
   EXCEPTION
      WHEN OTHERS THEN
         RAISE NOTICE 'Failed executing Copy function for %, please check your variables',var_table_name;
         RAISE NOTICE 'Copy command: COPY % FROM ''%\%.csv'' DELIMITER '','' CSV HEADER', 
                var_table_name,
                var_csv_path,
                var_file_name;
END$$;

DO $$
DECLARE
   -- please update with CSV directory paths on your machine, 
   -- do not place a backslash at the end :)
   var_csv_path     VARCHAR   := 'Z:\PREWORK_RS\sql-challenge\CSV_Data';
   var_full_path    VARCHAR;

BEGIN

   -- Drop Existing Tables
   DROP TABLE IF EXISTS salaries;
   DROP TABLE IF EXISTS dept_manager;
   DROP TABLE IF EXISTS dept_emp;
   DROP TABLE IF EXISTS stg_employees;
   DROP TABLE IF EXISTS employees;
   DROP TABLE IF EXISTS titles;
   DROP TABLE IF EXISTS departments;

   -- Create Departments Table
   CREATE TABLE departments(
      dept_no    VARCHAR(10),
      dept_name  VARCHAR(50) NOT NULL,
      PRIMARY KEY (dept_no)
      );
   -- Import Departments
   CALL proc_load_csv('departments','departments',var_csv_path);

   -- Create Titles Table
   CREATE TABLE titles(
      title_id VARCHAR(10),
      title    VARCHAR(50) NOT NULL,
       PRIMARY KEY(title_id)
      );
   --Import titles
   CALL proc_load_csv('titles','titles',var_csv_path);

   -- LOAD EMPLOYEES DATA - makes use of a staging table which
   -- loads the date column as text to be converted to date format
   -- on the actual employees table
   -- Create Employee Staging Table
   CREATE TABLE stg_employees(
      emp_no       INT,
      emp_title_id VARCHAR(10),
      birth_date   VARCHAR(12),
      first_name   VARCHAR(50),
      last_name    VARCHAR(50),
      sex          VARCHAR(1),
      hire_date    VARCHAR(12)
      );
   -- Import employees
   CALL proc_load_csv('stg_employees','employees',var_csv_path);
   -- Create actual Employees Table
   CREATE TABLE employees(
      emp_no       INT,
      emp_title_id VARCHAR(10),
      birth_date   DATE,
      first_name   VARCHAR(50),
      last_name    VARCHAR(50),
      sex          VARCHAR(1),
      hire_date    DATE,
      PRIMARY KEY(emp_no),
      CONSTRAINT fk_employees_emp_title_id
      FOREIGN KEY(emp_title_id)
         REFERENCES titles(title_id)
      );
   -- Load stating data into employees table with correct date format
   INSERT INTO employees (SELECT emp_no,
                                 emp_title_id,
                                 TO_DATE(birth_date,'MM/DD/YYYY'),
                                 first_name,
                                 last_name,
                                 sex,
                                 TO_DATE(hire_date,'MM/DD/YYYY')
                            FROM stg_employees);
   -- Drop staging table
   DROP TABLE IF EXISTS stg_employees;

   -- create dept_emp table
   CREATE TABLE dept_emp(
      emp_no  INT,
      dept_no VARCHAR(10),
	  PRIMARY KEY (emp_no,dept_no),
      CONSTRAINT fk_dept_emp_emp_no
      FOREIGN KEY(emp_no)
         REFERENCES employees(emp_no),
      CONSTRAINT fk_dept_emp_dept_no
      FOREIGN KEY(dept_no)
         REFERENCES departments(dept_no)
      );
   --Import dept_emp
   CALL proc_load_csv('dept_emp','dept_emp',var_csv_path);

   -- Create dept_manager table 
   CREATE TABLE dept_manager(
      dept_no VARCHAR(10),
      emp_no  INT,
      CONSTRAINT fk_dept_manager_dept_no
      FOREIGN KEY(dept_no)
         REFERENCES departments(dept_no),
      CONSTRAINT fk_dept_emp_no
      FOREIGN KEY(emp_no)
         REFERENCES employees(emp_no)
      );
   -- Import dept_manager
   CALL proc_load_csv('dept_manager','dept_manager',var_csv_path);

   -- Create Salaries Table
   CREATE TABLE salaries(
      emp_no INT,
      salary MONEY,
      CONSTRAINT fk_salaries_emp_no
      FOREIGN KEY (emp_no)
         REFERENCES employees(emp_no)
      );
   -- Import salaries
   CALL proc_load_csv('salaries','salaries',var_csv_path);

END$$;