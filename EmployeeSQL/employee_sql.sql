-- DATA ENGINEERING - Check if primary keys are unique
----------------------------------------------------------------------------------------------------------
SELECT COUNT(*),COUNT(DISTINCT emp_no) FROM employees; -- equal
SELECT COUNT(*),COUNT(DISTINCT dept_no) FROM departments; -- equal
SELECT COUNT(*),COUNT(DISTINCT title_id) FROM titles; -- equal
SELECT COUNT(*),COUNT(DISTINCT (emp_no)) FROM dept_emp; -- not equal, candidate for composite key
SELECT COUNT(*),COUNT(DISTINCT (emp_no)) FROM dept_manager; -- equal

-- DATA ANALYSIS
----------------------------------------------------------------------------------------------------------
-- List the following details of each employee: employee number, last name, first name, sex, and salary.
 SELECT e.emp_no "Employee Number",
        e.last_name "Last Name",
        e.first_name "First Name",
        e.sex "Gender",
        s.salary
   FROM employees e
   LEFT JOIN salaries s
      ON e.emp_no = s.emp_no;

-- List first name, last name, and hire date for employees who were hired in 1986.
-- [RS] Uncomment top and bottom codes to check ;)
-- SELECT distinct(extract (YEAR from "Hire Date")) FROM (
 SELECT e.first_name "First Name",
		e.last_name "Last Name",
		e.hire_date "Hire Date"
   FROM employees e
  WHERE e.hire_date BETWEEN '1986-1-1' AND '1986-12-31';
-- ) al

-- List the manager of each department with the following information: 
-- department number, department name, the manager's employee number, last name, first name.
SELECT dp.dept_no "Department Number",
       dp.dept_name "Department Name",
	   emp.emp_no "Employee Number",
	   emp.last_name "Last Name",
	   emp.first_name "First Name"
  FROM dept_manager dm
  JOIN departments dp
    ON dp.dept_no = dm.dept_no
  JOIN employees emp
    ON dm.emp_no = emp.emp_no;

-- List the department of each employee with the following information: 
-- employee number, last name, first name, and department name.
SELECT emp.emp_no "Employee Number",
       emp.last_name || ', ' || emp.first_name "Employee Name", -- jsut to make it a bit different ;)
	   dp.dept_name "Department"
  FROM employees emp
  LEFT JOIN dept_emp de
    ON emp.emp_no = de.emp_no
  JOIN departments dp
    ON dp.dept_no = de.dept_no;

-- List first name, last name, and sex for employees whose first name is "Hercules" and last names begin with "B."
SELECT emp.first_name "First Name",
	   emp.last_name "Last Name",
	   emp.sex
  FROM employees emp
 WHERE UPPER(first_Name) = 'HERCULES' -- [RS] UPPER ensures that nothing is missed
   AND UPPER(last_name) LIKE 'B%';
-- [RS] 20 rows fetched ;)

-- List all employees in the Sales department, including their employee number, last name, first name, and department name.
SELECT emp.emp_no "Employee Number",
       emp.last_name || ', ' || emp.first_name "Employee Name", -- jsut to make it a bit different ;)
	   dp.dept_name "Department"
  FROM employees emp
  LEFT JOIN dept_emp de
    ON emp.emp_no = de.emp_no
  JOIN departments dp
    ON dp.dept_no = de.dept_no
 WHERE dp.dept_no = 'd007'; -- [RS] James Bond? :D
-- [RS] 52245 records
 
-- List all employees in the Sales and Development departments, 
-- including their employee number, last name, first name, and department name.
SELECT emp.emp_no "Employee Number",
       emp.last_name || ', ' || emp.first_name "Employee Name", -- jsut to make it a bit different ;)
	   dp.dept_name "Department"
  FROM employees emp
  LEFT JOIN dept_emp de
    ON emp.emp_no = de.emp_no
  JOIN departments dp
    ON dp.dept_no = de.dept_no
 WHERE dp.dept_no IN ('d007','d005');
-- [RS] 137952 records

-- In descending order, list the frequency count of employee last names, 
-- i.e., how many employees share each last name.
SELECT emp.last_name "Last Name",
       COUNT(emp.last_name) "Number of Occurences"
  FROM employees emp
 GROUP BY emp.last_name
 ORDER BY 2 DESC,1 ASC;
 
 
 
 
 