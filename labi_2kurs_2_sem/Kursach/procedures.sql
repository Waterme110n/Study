/*                                                                              Роли                                                                              */
postgres
SET ROLE postgres;

CREATE ROLE customer_rl WITH LOGIN;
CREATE ROLE seller_rl WITH LOGIN;
CREATE ROLE author_rl WITH LOGIN;
CREATE ROLE user_rl WITH LOGIN;

CREATE USER customer_01 PASSWORD 'cust01' IN ROLE customer_rl;
CREATE USER seller_01 PASSWORD 'sell01' IN ROLE seller_rl;
CREATE USER author_01 PASSWORD 'auth01' IN ROLE author_rl;
CREATE USER user_reg PASSWORD 'user_reg' IN ROLE user_rl;


user_rl
SET ROLE user_rl;

GRANT EXECUTE ON PROCEDURE registration_procedure(character varying, character varying, character varying) TO user_rl;
GRANT EXECUTE ON PROCEDURE add_information_procedure(character varying, character varying,character varying, character varying) TO user_rl;
GRANT EXECUTE ON PROCEDURE login_procedure(character varying,character varying) TO user_rl;
GRANT SELECT, INSERT ON TABLE users TO user_rl;
GRANT SELECT, INSERT, UPDATE ON TABLE sellers TO user_rl;
GRANT SELECT, INSERT, UPDATE ON TABLE Authors TO user_rl;
GRANT SELECT, INSERT, UPDATE ON TABLE Customers TO user_rl;
GRANT USAGE, SELECT ON SEQUENCE users_user_id_seq TO user_rl;
GRANT EXECUTE ON FUNCTION login_function(character varying(255),character varying(255)) TO user_rl;
GRANT EXECUTE ON FUNCTION ID_FROM_USERNAME(character varying) TO user_rl;

GRANT user_rl TO customer_rl;
GRANT user_rl TO seller_rl;
GRANT user_rl TO author_rl;


customer_rl
SET ROLE customer_rl;

GRANT EXECUTE ON PROCEDURE get_images() TO customer_rl;
GRANT EXECUTE ON PROCEDURE add_to_favorites (integer,integer) TO customer_rl;
GRANT EXECUTE ON PROCEDURE delete_from_favorites (integer,integer) TO customer_rl;
GRANT EXECUTE ON PROCEDURE make_purchase (integer,integer) TO customer_rl;
GRANT EXECUTE ON FUNCTION sort_images_for_wpf(integer[],integer[],integer[],integer[]) TO customer_rl;
GRANT EXECUTE ON FUNCTION get_favorites(integer) TO customer_rl;
GRANT EXECUTE ON FUNCTION IsFavorite(integer,integer) TO customer_rl;
GRANT EXECUTE ON FUNCTION ID_FROM_IMAGE_NAME(character varying(255)) TO customer_rl;
GRANT SELECT ON TABLE Images TO customer_rl;
GRANT SELECT ON TABLE Styles TO customer_rl;
GRANT SELECT ON TABLE Sizes TO customer_rl;
GRANT SELECT ON TABLE Frames TO customer_rl;
GRANT SELECT ON TABLE Materials TO customer_rl;
GRANT SELECT ON TABLE Image_Gallery TO customer_rl;
GRANT SELECT, INSERT ON TABLE purchases TO customer_rl;
GRANT SELECT, INSERT, DELETE ON TABLE Favorites TO customer_rl;
GRANT USAGE, SELECT ON SEQUENCE favorites_favorite_id_seq TO customer_rl;
GRANT USAGE, SELECT ON SEQUENCE purchases_purchase_id_seq TO customer_rl;



author_rl
SET ROLE author_rl;

GRANT EXECUTE ON PROCEDURE accept_invitation_procedure(integer, integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE decline_invitation_procedure(integer, integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE decline_cooperations_procedure(integer,integer) TO author_rl; 
GRANT EXECUTE ON PROCEDURE get_images() TO author_rl;
GRANT EXECUTE ON PROCEDURE add_image(character varying,integer[],integer,text,integer,integer,integer,integer,integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE update_image(integer,character varying,integer[],integer,text,integer,integer,integer,integer,integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE delete_image(integer,integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE delete_image_path_procedure(integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE add_image_path_procedure(character varying) TO author_rl;
GRANT EXECUTE ON PROCEDURE update_availability_false(integer) TO author_rl;
GRANT EXECUTE ON PROCEDURE update_availability_true (integer) TO author_rl;
GRANT EXECUTE ON FUNCTION Author_images_wpf(integer) TO author_rl;
GRANT EXECUTE ON FUNCTION PATH_FROM_IMAGE_ID(integer) TO author_rl;
GRANT EXECUTE ON FUNCTION ID_FROM_IMAGE_PATH(character varying) TO author_rl;
GRANT EXECUTE ON FUNCTION ALL_STYLES() TO author_rl;
GRANT EXECUTE ON FUNCTION ALL_SIZES() TO author_rl;
GRANT EXECUTE ON FUNCTION ALL_FRAMES() TO author_rl;
GRANT EXECUTE ON FUNCTION ALL_MATERIALS() TO author_rl;
GRANT EXECUTE ON FUNCTION ALL_IMAGEPATHS() TO author_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Images TO author_rl;
GRANT SELECT ON TABLE Styles TO author_rl;
GRANT SELECT ON TABLE Sizes TO author_rl;
GRANT SELECT ON TABLE Frames TO author_rl;
GRANT SELECT ON TABLE Materials TO author_rl;
GRANT SELECT, INSERT, DELETE ON TABLE Image_Gallery TO author_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Invitations TO author_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Cooperations TO author_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Availability TO author_rl;
GRANT USAGE, SELECT ON SEQUENCE cooperations_cooperation_id_seq TO author_rl;
GRANT USAGE, SELECT ON SEQUENCE images_image_id_seq TO author_rl;
GRANT USAGE, SELECT ON SEQUENCE image_gallery_image_path_id_seq TO author_rl;

seller_rl
SET ROLE seller_rl;

GRANT EXECUTE ON PROCEDURE send_invitation_procedure(integer, integer, text) TO seller_rl;
GRANT EXECUTE ON PROCEDURE add_image(character varying,integer[],integer,text,integer,integer,integer,integer,integer) TO seller_rl;
GRANT EXECUTE ON PROCEDURE decline_cooperations_procedure(integer,integer) TO seller_rl; 
GRANT EXECUTE ON PROCEDURE delete_image(integer,integer) TO seller_rl;
GRANT EXECUTE ON PROCEDURE get_images() TO seller_rl;
GRANT EXECUTE ON PROCEDURE update_image(integer,character varying,integer[],integer,text,integer,integer,integer,integer,integer) TO seller_rl;
GRANT EXECUTE ON FUNCTION Author_images_wpf(integer) TO seller_rl;
GRANT EXECUTE ON FUNCTION Seller_colab_wpf(integer) TO seller_rl;
GRANT EXECUTE ON FUNCTION Author_name_and_id_colab(integer) TO seller_rl;
GRANT EXECUTE ON FUNCTION PATH_FROM_IMAGE_ID(integer) TO seller_rl;
GRANT EXECUTE ON FUNCTION ID_FROM_IMAGE_PATH(character varying) TO seller_rl;
GRANT EXECUTE ON FUNCTION ALL_STYLES() TO seller_rl;
GRANT EXECUTE ON FUNCTION ALL_SIZES() TO seller_rl;
GRANT EXECUTE ON FUNCTION ALL_FRAMES() TO seller_rl;
GRANT EXECUTE ON FUNCTION ALL_MATERIALS() TO seller_rl;
GRANT EXECUTE ON FUNCTION ALL_IMAGEPATHS() TO seller_rl;
GRANT EXECUTE ON FUNCTION ID_FROM_AUT_NAME(character varying(255)) TO seller_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Images TO seller_rl;
GRANT SELECT ON TABLE Styles TO seller_rl;
GRANT SELECT ON TABLE Sizes TO seller_rl;
GRANT SELECT ON TABLE Frames TO seller_rl;
GRANT SELECT ON TABLE Materials TO seller_rl;
GRANT SELECT, INSERT, DELETE ON TABLE Image_Gallery TO seller_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Invitations TO seller_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Cooperations TO seller_rl;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Availability TO seller_rl;
GRANT USAGE, SELECT ON SEQUENCE cooperations_cooperation_id_seq TO seller_rl;
GRANT USAGE, SELECT ON SEQUENCE invitations_invitation_id_seq TO seller_rl;
GRANT USAGE, SELECT ON SEQUENCE images_image_id_seq TO seller_rl;
GRANT USAGE, SELECT ON SEQUENCE image_gallery_image_path_id_seq TO seller_rl;

/*                                                                              Процедуры                                                                              */
select * from Cooperations
select * from sellers
/*---------------------------------------------------------------------------Регистрация-------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE registration_procedure(
    p_username character varying(255),
    p_password character varying(255),
	p_role character varying(255)
)
AS $$
BEGIN

	IF p_role != 'customer' AND p_role != 'author' AND p_role != 'seller' THEN
        RAISE EXCEPTION 'Invalid role. Allowed roles are "customer","author" and "seller".';
    END IF;
	
	IF NULLIF(p_username, '') IS NULL OR NULLIF(p_password, '') IS NULL THEN
		RAISE EXCEPTION 'Username and password cannot be empty!';
	END IF;
	
	If COUNT(*) FROM Users WHERE username = p_username THEN
		RAISE EXCEPTION 'this nickname is already taken!';
		
	END IF;
    INSERT INTO users (username, user_password, user_role)
    VALUES (p_username, p_password,p_role);
	
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE registration_procedure;

CALL registration_procedure('sPaxlss2ss3','1239129','customer');
/*---------------------------------------------------------------------------Вход-------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE login_procedure(
    p_username character varying(255),
    p_password character varying(255)
)
AS $$
DECLARE
	p_role character varying(255);
BEGIN
		
	IF NULLIF(p_username, '') IS NULL OR NULLIF(p_password, '') IS NULL THEN
		RAISE EXCEPTION 'Username and password cannot be empty!';
	END IF;
		
	IF EXISTS (SELECT 1 FROM Users WHERE username = p_username AND user_password = p_password) THEN
		SELECT user_role INTO p_role FROM Users WHERE username = p_username;
		IF p_role = 'seller' THEN
			SET ROLE seller_rl;
		ELSIF p_role = 'author' THEN
			SET ROLE author_rl;
		ELSIF p_role = 'customer' THEN
			SET ROLE customer_rl;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE login_procedure;

CALL login_procedure('asd','dasd');
/*----------------------------------------------------------Добавление больше информации-------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE add_information_procedure(
	p_username character varying(255),
    p_fst_name character varying(255),
    p_sec_name character varying(255),
    p_mail character varying(255)
)
AS $$
BEGIN
    IF EXISTS(SELECT 1 FROM Authors WHERE username_aut = p_username) THEN
        UPDATE Authors
        SET fst_name_aut = p_fst_name,
			sec_name_aut = p_sec_name,
            email_aut = p_mail
        WHERE username_aut = p_username;
    ELSIF EXISTS(SELECT 1 FROM Customers WHERE username = p_username) THEN
        UPDATE Customers
        SET fst_name = p_fst_name,
			sec_name = p_sec_name,
            email = p_mail
        WHERE username = p_username;
    ELSIF EXISTS(SELECT 1 FROM Sellers WHERE username = p_username) THEN
        UPDATE Sellers
        SET fst_name = p_fst_name,
			sec_name = p_sec_name,
            email = p_mail
        WHERE username = p_username;
    ELSE
        RAISE EXCEPTION 'this user doesnt exist';
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE add_information_procedure;

CALL add_information_procedure('asd','Pavel','Andreevich','asdasda@gmail.com');
/*----------------------------------------------------------Удаление пользователя-------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE delete_user_procedure(
    IN p_username character varying(255)
)
AS $$
BEGIN
    IF EXISTS(SELECT 1 FROM Authors WHERE fst_name_aut = p_username) THEN
        DELETE FROM Authors
        WHERE fst_name_aut = p_username;
    ELSIF EXISTS(SELECT 1 FROM Customers WHERE fst_name = p_username) THEN
        DELETE FROM Customers
        WHERE fst_name = p_username;
    ELSIF EXISTS(SELECT 1 FROM Sellers WHERE fst_name = p_username) THEN
        DELETE FROM Sellers
        WHERE fst_name = p_username;
    ELSE
        RAISE EXCEPTION 'this user doesnt exist';
    END IF;

    DELETE FROM Users
    WHERE username = p_username;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE delete_user_procedure;

CALL delete_user_procedure('Pavel');
/*----------------------------------------------------------Приглашения автора от селлера-------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE send_invitation_procedure(
    IN p_seller_id integer,
    IN p_author_id integer,
    IN p_invitation_text text Default null
)
AS $$
BEGIN

 	IF NOT EXISTS(SELECT 1 FROM Authors WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'this author doesnt exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Sellers WHERE seller_id = p_seller_id) THEN
        RAISE EXCEPTION 'this seller doesnt exist';
    END IF;
	
	IF EXISTS(SELECT 1 FROM Invitations WHERE seller_id = p_seller_id and author_id = p_author_id) THEN
        RAISE EXCEPTION 'this invitation already exist';
    END IF;
	
    INSERT INTO Invitations (seller_id, author_id, invitation_text, invitation_status, invitation_date)
    VALUES (p_seller_id, p_author_id, p_invitation_text, 'ожидает ответа',  CURRENT_TIMESTAMP);
	
	EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE send_invitation_procedure;

CALL send_invitation_procedure(97,154);
/*-----------------------------------------------------Принятие приглашения автора от селлера--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE accept_invitation_procedure(
    IN p_author_id integer,
    IN p_invitation_id integer
)
AS $$
DECLARE
    current_status text;
	existing_cooperation integer;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Authors WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'this author doesnt exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Invitations WHERE invitation_id = p_invitation_id) THEN
        RAISE EXCEPTION 'this invitation doesnt exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Invitations WHERE invitation_id = p_invitation_id AND author_id = p_author_id) THEN
        RAISE EXCEPTION 'This author does not match this invitation';
    END IF;
	
	SELECT invitation_status INTO current_status FROM Invitations WHERE invitation_id = p_invitation_id;
    
    IF current_status <> 'ожидает ответа' THEN
        RAISE EXCEPTION 'Cannot accept invitation with a status other than "ожидает ответа"';
    END IF;
    
	SELECT cooperation_id INTO existing_cooperation FROM Cooperations WHERE author_id = p_author_id;
    
    IF existing_cooperation IS NOT NULL THEN
        RAISE EXCEPTION 'This artist is already working with someone else';
    END IF;
	
    UPDATE Invitations SET invitation_status = 'принято' WHERE invitation_id = p_invitation_id;
    
	EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE accept_invitation_procedure;

CALL accept_invitation_procedure(154,17);
/*-----------------------------------------------------Отклонение приглашения автора от селлера--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE decline_invitation_procedure(
    IN p_author_id integer,
    IN p_invitation_id integer
)
AS $$
DECLARE
    current_status text;
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Authors WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'this author doesnt exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Invitations WHERE invitation_id = p_invitation_id) THEN
        RAISE EXCEPTION 'this invitation doesnt exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Invitations WHERE invitation_id = p_invitation_id AND author_id = p_author_id) THEN
        RAISE EXCEPTION 'This author does not match this invitation';
    END IF;
    
    SELECT invitation_status INTO current_status FROM Invitations WHERE invitation_id = p_invitation_id;
    
    IF current_status <> 'ожидает ответа' THEN
        RAISE EXCEPTION 'Нельзя отклонить приглашение со статусом, отличным от "ожидает ответа"';
    END IF;
	
    UPDATE Invitations SET invitation_status = 'отклонено' WHERE invitation_id = p_invitation_id;
    
	EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE accept_invitation_procedure;

CALL decline_invitation_procedure(86,3);
/*-----------------------------------------------------Удаление колаборации--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE decline_cooperations_procedure(
    IN p_Seller_id integer,
    IN p_Author_id integer
)
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Cooperations WHERE Seller_id = p_Seller_id) THEN
        RAISE EXCEPTION 'this Seller doesnt exist in any coloboration';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Cooperations WHERE Author_id = p_Author_id) THEN
        RAISE EXCEPTION 'this cooperation doesnt exist in any coloboration';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Cooperations WHERE Seller_id = p_Seller_id AND author_id = p_author_id) THEN
        RAISE EXCEPTION 'This author does not match this Cooperation';
    END IF;
    
    DELETE FROM Cooperations WHERE Seller_id = p_Seller_id AND author_id = p_author_id;
    
	EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE decline_cooperations_procedure;

CALL decline_cooperations_procedure(87,86);
/*-----------------------------------------------------------Просмотр Товаров--------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE get_images()
LANGUAGE plpgsql
AS $$
DECLARE
    image_cursor CURSOR FOR
        SELECT i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, 
               i.Date_of_creation, s.Style_name, sz.Size_value, f.Frame_type, ma.material_name,
               STRING_AGG(ig.Image_path, ', ') AS image_paths
        FROM images i
        JOIN Authors au ON i.Author_id = au.Author_id
        JOIN Styles s ON i.Style_id = s.Style_id
        JOIN Sizes sz ON i.Size_id = sz.Size_id
        JOIN Frames f ON i.Frame_id = f.Frame_id
        JOIN Materials ma ON i.Materials_id = ma.Material_id
        JOIN Image_Gallery ig ON ig.Image_path_id = ANY(i.Image_paths_id)
        GROUP BY i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, i.Date_of_creation,
                 s.Style_name, sz.Size_value, f.Frame_type, ma.material_name;
    image_row RECORD;
BEGIN
    OPEN image_cursor;
    LOOP
        FETCH image_cursor INTO image_row;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '------------------------------------------------';
        RAISE NOTICE 'Image ID: %', image_row.Image_id;
        RAISE NOTICE 'Name of the image: %', image_row.Image_name;
        RAISE NOTICE 'Image paths: %', image_row.image_paths;
        RAISE NOTICE 'Author: %', image_row.fst_name_aut;
        RAISE NOTICE 'Description: %', image_row.descriptions;
        RAISE NOTICE 'Date of creation: %', image_row.Date_of_creation;
        RAISE NOTICE 'Style: %', image_row.Style_name;
        RAISE NOTICE 'Size: % cm', image_row.Size_value;
        RAISE NOTICE 'Frame: %', image_row.Frame_type;
        RAISE NOTICE 'Materials: %', image_row.material_name;
    END LOOP;
    CLOSE image_cursor;
END;
$$;


drop PROCEDURE get_images();

CALL get_images();
/*-----------------------------------------------------------Добавление Товаров--------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE add_image(
    p_image_name character varying,
    p_image_paths_id integer[],
    p_author_id integer,
    p_descriptions text,
    p_style_id integer,
    p_date_of_creation integer,
    p_size_id integer,
    p_frame_id integer,
    p_materials_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    image_paths_id integer[];
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Authors WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'This author doesn''t exist';
    END IF;

    IF EXISTS(SELECT 1 FROM Images WHERE Image_name = p_image_name) THEN
        RAISE EXCEPTION 'This image already exists';
	END IF;
	
	IF not EXISTS(SELECT 1 FROM Styles WHERE Style_id = p_style_id) THEN
        RAISE EXCEPTION 'There no style with this id. Available style ids: %', 
		(SELECT string_agg(Style_id || '.' || style_name, ', ') From styles);
    END IF;
	
	IF not EXISTS(SELECT 1 FROM Frames WHERE Frame_id = p_Frame_id) THEN
        RAISE EXCEPTION 'There no frame with this id. Available frame ids: %', 
		(SELECT string_agg(Frame_id || '.' || Frame_type, ', ') From Frames);
    END IF;
	
	IF not EXISTS(SELECT 1 FROM Materials WHERE material_id = p_materials_id) THEN
        RAISE EXCEPTION 'There no material with this id. Available materials ids: %', 
		(SELECT string_agg(material_id || '.' || material_name, ', ') From Materials);
    END IF;
		
	SELECT ARRAY_AGG(Image_path_id) INTO image_paths_id
    FROM Image_Gallery
    WHERE Image_path_id = ANY(p_image_paths_id);
	
	 IF array_length(Image_paths_id, 1) IS NULL THEN
        RAISE EXCEPTION 'There is no image path with one of the provided ids. Available image paths: %', 
            (SELECT string_agg(Image_path_id::text, ', ') FROM Image_Gallery);
    END IF;

		
    INSERT INTO Images (Image_name, Image_paths_id, Author_id, Descriptions, Style_id, Date_of_creation, Size_id, Frame_id, Materials_id)
    VALUES (p_image_name, image_paths_id, p_author_id, p_descriptions, p_style_id, p_date_of_creation, p_size_id, p_frame_id, p_materials_id);
	
    
END;
$$;

drop PROCEDURE add_image ;

CALL add_image('The Stardry Night', ARRAY[8,9,10], 154, 'A famous painting by Vincent van Gogh depicting a night sky with swirling stars.', 4, 2022, 2, 3, 1);
CALL add_image('Mona Ldisa', ARRAY[9], 154, 'A portrait painting by Leonardo da Vinci, known for its enigmatic smile.', 2, 2022, 4, 1, 3);
CALL add_image('The Pdersistence of Memory', ARRAY[10], 154, 'A surrealist painting by Salvador Dalí featuring melting clocks in a dreamlike landscape.', 1, 2022, 3, 2, 4);
CALL add_image('The Scream', ARRAY[11], 106, 'An iconic painting by Edvard Munch, representing the existential angst and despair.', 3, 2022, 1, 4, 2);
CALL add_image('Guernica', ARRAY[12], 106, 'A powerful anti-war painting by Pablo Picasso, depicting the bombing of Guernica during the Spanish Civil War.', 3, 2022, 3, 1, 4);
CALL add_image('The Birth of Venus', ARRAY[13], 106, 'A classic painting by Sandro Botticelli depicting the goddess Venus emerging from the sea.', 2, 2022, 2, 4, 1);
CALL add_image('The Last Supper', ARRAY[14], 106, 'A renowned mural painting by Leonardo da Vinci portraying the last meal of Jesus with his disciples.', 4, 2022, 4, 2, 3);
CALL add_image('The Creation of Adam', ARRAY[15], 106, 'A famous fresco painting by Michelangelo depicting the Biblical creation of Adam.', 1, 2022, 1, 3, 2);
CALL add_image('Girl with a Pearl Earring', ARRAY[16], 106, 'A captivating painting by Johannes Vermeer featuring a young woman with a pearl earring.', 2, 2022, 4, 3, 1);
CALL add_image('The Great Wave off Kanagawa', ARRAY[18], 106, 'A woodblock print by Katsushika Hokusai, depicting a giant wave about to engulf fishing boats.', 3, 2022, 2, 1, 4);
/*-----------------------------------------------------------Обновление Товаров--------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE update_image(
    p_image_id integer,
    p_image_name character varying,
    p_image_paths_id integer[],
    p_author_id integer,
    p_descriptions text,
    p_style_id integer,
    p_date_of_creation integer,
    p_size_id integer,
    p_frame_id integer,
    p_materials_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    updated_image_paths_id integer[];
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Authors WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'This author doesn''t exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_image_id) THEN
        RAISE EXCEPTION 'This image doesn''t exist';
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Styles WHERE style_id = p_style_id) THEN
        RAISE EXCEPTION 'There is no style with this id. Available style ids: %', 
            (SELECT string_agg(style_id::text || '.' || style_name, ', ') FROM styles);
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Frames WHERE frame_id = p_frame_id) THEN
        RAISE EXCEPTION 'There is no frame with this id. Available frame ids: %', 
            (SELECT string_agg(frame_id::text || '.' || frame_type, ', ') FROM frames);
    END IF;
    
    IF NOT EXISTS(SELECT 1 FROM Materials WHERE material_id = p_materials_id) THEN
        RAISE EXCEPTION 'There is no material with this id. Available material ids: %', 
            (SELECT string_agg(material_id::text || '.' || material_name, ', ') FROM materials);
    END IF;
    
    SELECT ARRAY_AGG(image_path_id) INTO updated_image_paths_id
    FROM image_gallery
    WHERE image_path_id = ANY(p_image_paths_id);
    
    IF array_length(updated_image_paths_id, 1) IS NULL THEN
        RAISE EXCEPTION 'There is no image path with one of the provided ids. Available image paths: %', 
            (SELECT string_agg(image_path_id::text, ', ') FROM image_gallery);
    END IF;
    
    UPDATE images
    SET
        image_name = p_image_name,
        image_paths_id = updated_image_paths_id,
        author_id = p_author_id,
        descriptions = p_descriptions,
        style_id = p_style_id,
        date_of_creation = p_date_of_creation,
        size_id = p_size_id,
        frame_id = p_frame_id,
        materials_id = p_materials_id
    WHERE
        image_id = p_image_id;
    
END;
$$;

drop PROCEDURE update_image ;

CALL update_image(120, 'The Starry3 Night', ARRAY[8,9,10], 106, 'A famous painting by Vincent van Gogh depicting a night sky with swirling stars.', 4, 2022, 2, 3, 1);

/*--------------------------Удаление Товаров-------------------------------------*/
CREATE OR REPLACE PROCEDURE delete_image(
	p_author_id integer,
	p_image_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS(SELECT 1 FROM Images WHERE author_id = p_author_id) THEN
        RAISE EXCEPTION 'this author doesnt exist';
    END IF;
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_image_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE author_id = p_author_id AND image_id = p_image_id) THEN
        RAISE EXCEPTION 'this author did not exhibit this picture';
    END IF;
	
	DELETE FROM AVAILABILITY where Image_id = p_image_id;
    DELETE FROM Images WHERE image_id = p_image_id AND author_id = p_author_id;
	
	
	RAISE NOTICE 'Image deleted successfully';
	
    EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
        RAISE NOTICE 'Ошибка: %', SQLERRM;
END;
$$;

drop PROCEDURE delete_image ;

CALL delete_image(177,185);
/*----------------------------------------------------------------Удаление картинки--------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE delete_image_path_procedure(
	p_Image_path_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
	
	IF NOT EXISTS(SELECT 1 FROM Image_Gallery WHERE Image_path_id = p_Image_path_id) THEN
        RAISE EXCEPTION 'this image_path doesnt exist';
    END IF;
	
	Delete From Image_Gallery where Image_path_id = p_Image_path_id;
END;
$$;

drop PROCEDURE delete_image_path_procedure ;

CALL delete_image_path_procedure(20);
/*----------------------------------------------------------------Добавление картинки--------------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE add_image_path_procedure(
	p_image_path character varying
)
LANGUAGE plpgsql
AS $$
BEGIN
	
	IF EXISTS(SELECT 1 FROM Image_Gallery WHERE image_path = p_image_path) THEN
        RAISE EXCEPTION 'this image_path alreay exist';
    END IF;
	
	INSERT INTO Image_Gallery (Image_path)
    VALUES (p_image_path);
END;
$$;

drop PROCEDURE add_image_path_procedure ;

CALL add_image_path_procedure('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\fst.png');
/*----------------------------------------------------------------процедура изменения avaliability на false--------------------------------------------------------------------------------*/

CREATE OR REPLACE PROCEDURE update_availability_false (
    p_Image_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Available_value boolean;
BEGIN
    SELECT Available INTO v_Available_value
    FROM public.availability
    WHERE Image_id = p_Image_id;
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_image_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;
	
	IF v_Available_value IS false THEN
        RAISE EXCEPTION 'Image already not available';
    END IF;
	
	
    UPDATE public.availability
    SET Available = false
    WHERE Image_id = p_Image_id;
END;
$$;

drop PROCEDURE update_availability_false ;

CALL update_availability_false(36);

/*----------------------------------------------------------------процедура изменения avaliability на true--------------------------------------------------------------------------------*/

CREATE OR REPLACE PROCEDURE update_availability_true (
    p_Image_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Available_value boolean;
BEGIN
    SELECT Available INTO v_Available_value
    FROM public.availability
    WHERE Image_id = p_Image_id;
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_image_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;
	
	IF v_Available_value IS true THEN
        RAISE EXCEPTION 'Image already available';
    END IF;
	
	
    UPDATE public.availability
    SET Available = true
    WHERE Image_id = p_Image_id;
END;
$$;

drop PROCEDURE update_availability_true ;

CALL update_availability_true(36);

/*---------------------------------------------------Добавление в избранное--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE add_to_favorites (
    p_user_id integer,
    p_image_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_image_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;

	IF NOT EXISTS(SELECT 1 FROM Customers WHERE customer_id = p_user_id) THEN
        RAISE EXCEPTION 'this user doesnt exist';
    END IF;
	
	IF EXISTS (SELECT 1 FROM Favorites WHERE user_id = p_user_id AND images_id = p_image_id) THEN
        RAISE EXCEPTION 'The image is already in favorites.';
	END IF;
		
    INSERT INTO public.Favorites (user_id, images_id)
    VALUES (p_user_id, p_image_id);
END;
$$;

drop PROCEDURE add_to_favorites ;

CALL add_to_favorites(98,94);
/*---------------------------------------------------Удаление из избранного--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE delete_from_favorites (
    p_user_id integer,
    p_image_id integer
)
LANGUAGE plpgsql
AS $$
BEGIN
	
	IF NOT EXISTS(SELECT 1 FROM Favorites WHERE images_id = p_image_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;

	IF NOT EXISTS(SELECT 1 FROM Favorites WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'this user doesnt exist';
    END IF;
		
	Delete FROM Favorites WHERE user_id = p_user_id AND images_id = p_image_id;
END;
$$;

drop PROCEDURE delete_from_favorites ;

CALL delete_from_favorites(91,36);
/*---------------------------------------------------совершение покупки--------------------------------------------------------------------------*/
CREATE OR REPLACE PROCEDURE make_purchase (
    p_product_id integer,
    p_customer_id integer
)
LANGUAGE plpgsql
AS $$
declare
	v_purchase_date date = CURRENT_DATE;
	v_total_price numeric(10,2);
BEGIN
	
	IF NOT EXISTS(SELECT 1 FROM Images WHERE image_id = p_product_id) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;

	IF NOT EXISTS(SELECT 1 FROM Customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'this Customers doesnt exist';
    END IF;
		
	 v_total_price := (random() * (1000 - 100) + 100 )::numeric(10,2);

    INSERT INTO public.purchases (Product_id, Customer_id, purchase_date, total_price)
    					VALUES (p_product_id, p_customer_id, v_purchase_date, v_total_price);
END;
$$;

drop PROCEDURE make_purchase ;

CALL make_purchase(94,142);