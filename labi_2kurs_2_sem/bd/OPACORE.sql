CREATE TABLE OPA_T (
  id INT,
  name VARCHAR(255),
  age INT,
  email VARCHAR(255)
);

INSERT INTO OPA_T (id, name, age, email)
VALUES (1, 'John Doe', 25, 'john.doe@example.com');

INSERT INTO OPA_T (id, name, age, email)
VALUES (2, 'Jane Smith', 30, 'jane.smith@example.com');

select * from OPA_T;