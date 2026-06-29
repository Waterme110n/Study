CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COPY users(id, name, email, created_at)
FROM 'C:/labi_3kurs_2_sem/Mshoad/labi/lab11/users.csv'
DELIMITER ','

select * from users;

CREATE OR REPLACE FUNCTION set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION set_timestamp();

CREATE OR REPLACE FUNCTION get_user_email(user_id INT)
RETURNS VARCHAR(100) AS $$
DECLARE
    emailn VARCHAR(100);
BEGIN
    SELECT email INTO emailn FROM users WHERE id = user_id;
    RETURN emailn;
END;
$$ LANGUAGE plpgsql;

SELECT get_user_email(1);