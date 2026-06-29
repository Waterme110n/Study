/*-------------------------------------------------------Автоматическое добавление из user----------------------------------------------------------------------------*/
CREATE TRIGGER insert_user_trigger
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION insert_into_other_table();

CREATE OR REPLACE FUNCTION insert_into_other_table()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.user_role = 'customer' THEN
        INSERT INTO customers (customer_id,username)
        VALUES (NEW.User_id, NEW.username);
    ELSIF NEW.user_role = 'author' THEN
        INSERT INTO authors (author_id, username_aut)
        VALUES (NEW.User_id, NEW.username); 
    ELSIF NEW.user_role = 'seller' THEN
        INSERT INTO Sellers (Seller_id, username)
        VALUES (NEW.User_id, NEW.username); 
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

drop function insert_into_other_table();
drop trigger insert_user_trigger ON users
/*-------------------------------------------------------Автоматическое добавление cooperations------------------------------------------------------------------------*/

CREATE TRIGGER insert_cooperation_trigger
AFTER UPDATE ON Invitations
FOR EACH ROW
EXECUTE FUNCTION insert_into_cooperation();

CREATE OR REPLACE FUNCTION insert_into_cooperation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.invitation_status = 'принято' THEN
        INSERT INTO Cooperations (author_id, seller_id,cooperation_date)
        VALUES (NEW.author_id, NEW.seller_id,CURRENT_TIMESTAMP);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

drop function insert_into_cooperation();
drop trigger insert_cooperation_trigger ON Invitations;

/*---------------------------------------------------Автоматическое удаление из invitations---------------------------------------------------------------------------*/
CREATE TRIGGER auto_delete_invitation_trigger
AFTER DELETE ON Cooperations
FOR EACH ROW
EXECUTE FUNCTION delete_invitation_on_cooperation_delete();

CREATE OR REPLACE FUNCTION delete_invitation_on_cooperation_delete()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Invitations WHERE Seller_id = OLD.Seller_id AND Author_id = OLD.Author_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

/*---------------------------------------------------Автоматическое занесение в avaliability--------------------------------------------------------------------------*/
CREATE TRIGGER create_availability_trigger
AFTER INSERT ON public.Images
FOR EACH ROW
EXECUTE FUNCTION create_availability_on_insert();

CREATE OR REPLACE FUNCTION create_availability_on_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.availability (Image_id, Available)
    VALUES (NEW.Image_id, true);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*-------------------------ВЫВОД ИЗБРАННЫХ ДЛЯ ОПРЕДЕЛЕННОГО ЮСЕРА---------------------------------------*/
CREATE OR REPLACE FUNCTION get_favorites(p_user_id integer)
  RETURNS TABLE (
    image_name character varying(255),
    fst_name_aut character varying(255),
	image_paths character varying(255)[]
  )
AS $$
BEGIN
  RETURN QUERY
    SELECT i.image_name, au.fst_name_aut, ARRAY_AGG(ig.Image_path) AS image_paths
    FROM Favorites f
    JOIN Images i ON f.images_id = i.image_id
	JOIN Authors au ON i.Author_id = au.Author_id
	JOIN Image_Gallery ig ON ig.Image_path_id = ANY(i.Image_paths_id)
    WHERE f.user_id = p_user_id
	 GROUP BY i.image_name, au.fst_name_aut;
END;
$$ LANGUAGE plpgsql;

drop function get_favorites(p_user_id integer);

select * from get_favorites(108);
/*-------------------------ВЫВОД КАРТИН ДЛЯ ЮСЕРА--------------------------------------------*/
CREATE OR REPLACE FUNCTION sort_images_for_wpf(Style_id_vvod integer[],Size_id_vvod integer[],Frame_id_vvod integer[],Materials_id_vvod integer[])
RETURNS TABLE (
    Image_id INTEGER,
    Image_name character varying(255),
    fst_name_aut character varying(255),
    descriptions TEXT,
    Date_of_creation integer,
    Style_name character varying(255),
    Size_value character varying(255),
    Frame_type character varying(255),
    material_name character varying(255),
    image_paths character varying(255)[]
)
AS $$
BEGIN
    RETURN QUERY
    SELECT i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, 
           i.Date_of_creation, s.Style_name, sz.Size_value, f.Frame_type, ma.material_name,
           ARRAY_AGG(ig.Image_path) AS image_paths
    FROM images i
    JOIN Authors au ON i.Author_id = au.Author_id
    JOIN Styles s ON i.Style_id = s.Style_id
    JOIN Sizes sz ON i.Size_id = sz.Size_id
    JOIN Frames f ON i.Frame_id = f.Frame_id
    JOIN Materials ma ON i.Materials_id = ma.Material_id
    JOIN Image_Gallery ig ON ig.Image_path_id = ANY(i.Image_paths_id)
	
	 WHERE (Style_id_vvod IS NULL OR i.Style_id = ANY(Style_id_vvod))
      AND (Size_id_vvod IS NULL OR i.Size_id = ANY(Size_id_vvod))
      AND (Frame_id_vvod IS NULL OR i.Frame_id = ANY(Frame_id_vvod))
      AND (Materials_id_vvod IS NULL OR i.Materials_id = ANY(Materials_id_vvod))
	  
    GROUP BY i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, i.Date_of_creation,
             s.Style_name, sz.Size_value, f.Frame_type, ma.material_name;

    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM sort_images_for_wpf(ARRAY[4], null, null, null );

 DROP FUNCTION sort_images_for_wpf(integer[],integer[],integer[],integer[])
 /*-------------------------------ВЫВОД КАРТИН ОПРЕДЕЛЕННОГО АВТОРА--------------------------------------------------------------------*/
 CREATE OR REPLACE FUNCTION Author_images_wpf(p_user_id integer)
RETURNS TABLE (
    Image_id INTEGER,
    Image_name character varying(255),
    fst_name_aut character varying(255),
    descriptions TEXT,
    Date_of_creation integer,
    Style_name character varying(255),
    Size_value character varying(255),
    Frame_type character varying(255),
    material_name character varying(255),
    image_paths character varying(255)[]
)
AS $$
BEGIN
    RETURN QUERY
    SELECT i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, 
           i.Date_of_creation, s.Style_name, sz.Size_value, f.Frame_type, ma.material_name,
           ARRAY_AGG(ig.Image_path) AS image_paths
    FROM images i
    JOIN Authors au ON i.Author_id = au.Author_id
    JOIN Styles s ON i.Style_id = s.Style_id
    JOIN Sizes sz ON i.Size_id = sz.Size_id
    JOIN Frames f ON i.Frame_id = f.Frame_id
    JOIN Materials ma ON i.Materials_id = ma.Material_id
    JOIN Image_Gallery ig ON ig.Image_path_id = ANY(i.Image_paths_id)
	
	 WHERE p_user_id = au.Author_id 
	  
    GROUP BY i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, i.Date_of_creation,
             s.Style_name, sz.Size_value, f.Frame_type, ma.material_name;

    RETURN;
END;
$$ LANGUAGE plpgsql;

select * from authors

SELECT * FROM Author_images_wpf(106);
 /*-------------------------------ВЫВОД КОЛАБОРАЦИЙ--------------------------------------------------------------------*/
 CREATE OR REPLACE FUNCTION Seller_colab_wpf(p_user_id integer)
RETURNS TABLE (
	Cooperation_id integer,
    Seller_id integer ,
    Author_id integer 
)
AS $$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM Cooperations WHERE Cooperations.Seller_id = p_user_id) THEN
        RAISE EXCEPTION 'this Seller doesnt exist in any colaboration';
    END IF;
	
RETURN QUERY
    SELECT
        c.Cooperation_id,
        c.Seller_id,
        c.Author_id
    FROM
        Cooperations c 
    WHERE
        c.Seller_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

select * from authors where fst_name_aut = 

SELECT * FROM Seller_colab_wpf(97);
 /*-------------------------------ВЫВОД Автора_id и атор_name КОЛАБОРАЦИЙ--------------------------------------------------------------------*/
  CREATE OR REPLACE FUNCTION Author_name_and_id_colab(p_user_id integer)
RETURNS TABLE (
    Author_id integer,
	Author_name character varying(255)
)
AS $$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM Cooperations WHERE Cooperations.Seller_id = p_user_id) THEN
        RAISE EXCEPTION 'this Seller doesnt exist in any colaboration';
    END IF;
	
RETURN QUERY
    SELECT
        c.Author_id,
		au.fst_name_aut
    FROM
        Cooperations c Join Authors au ON c.Author_id = au.Author_id
    WHERE
        c.Seller_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM Author_name_and_id_colab(97);

 /*---------------------------------------------------------------------------login_function------------------------------------------------------------------------------*/
CREATE OR REPLACE FUNCTION login_function(
    p_username character varying(255),
    p_password character varying(255)
)
RETURNS TABLE(
	user_role character varying(255)
)
AS $$
BEGIN

IF NOT EXISTS(SELECT 1 FROM users WHERE Users.username = p_username) THEN
        RAISE EXCEPTION 'this User doesnt exist';
    END IF;
	
IF NOT EXISTS(SELECT 1 FROM users WHERE username = p_username AND user_password = p_password) THEN
        RAISE EXCEPTION 'Invalid username or password';
    END IF;

RETURN QUERY
    SELECT users.user_role
    FROM users
    WHERE username = p_username
        AND user_password = p_password;
		
END;
$$ LANGUAGE plpgsql;

SELECT * FROM login_function('Pal','1239129');
/*-------------------------------ПОЛУЧЕНИЕ USER_ID ПО USERNAME------------------------------------*/
CREATE OR REPLACE FUNCTION ID_FROM_USERNAME(
    p_username character varying(255)
)
RETURNS TABLE(
	user_ID integer
)
AS $$
BEGIN

	IF NOT EXISTS(SELECT 1 FROM users WHERE Users.username = p_username) THEN
        RAISE EXCEPTION 'this User doesnt exist';
    END IF;
	
	RETURN QUERY 
	SELECT USERS.user_id FROM Users WHERE username = p_username;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION id_from_username(character varying)

SELECT * FROM ID_FROM_USERNAME('Pal');
/*-------------------------------ПОЛУЧЕНИЕ author_id ПО fst_name_aut------------------------------------*/
CREATE OR REPLACE FUNCTION ID_FROM_AUT_NAME(
    p_fst_name_aut character varying(255)
)
RETURNS TABLE(
	p_author_id integer
)
AS $$
BEGIN

	IF NOT EXISTS(SELECT 1 FROM authors WHERE authors.fst_name_aut = p_fst_name_aut) THEN
        RAISE EXCEPTION 'this author doesnt exist';
    END IF;
	
	RETURN QUERY 
	SELECT author_id FROM authors WHERE fst_name_aut = p_fst_name_aut;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ID_FROM_AUT_NAME(character varying)

SELECT * FROM ID_FROM_AUT_NAME('Pavel');
/*-------------------------------ПОЛУЧЕНИЕ image_ID ПО imagename------------------------------------*/
CREATE OR REPLACE FUNCTION ID_FROM_IMAGE_NAME(
    p_image_name character varying(255)
)
RETURNS TABLE(
	image_ID integer
)
AS $$
BEGIN

	IF NOT EXISTS(SELECT 1 FROM images WHERE images.image_name = p_image_name) THEN
        RAISE EXCEPTION 'this image doesnt exist';
    END IF;
	
	RETURN QUERY 
	SELECT images.image_id FROM images WHERE image_name = p_image_name;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ID_FROM_IMAGE_NAME(character varying)

SELECT * FROM ID_FROM_IMAGE_NAME('Guernica');
/*-------------------------------Получение пути из ID------------------------------------*/
CREATE OR REPLACE FUNCTION PATH_FROM_IMAGE_ID(
    P_Image_path_id integer
)
RETURNS TABLE(
	Image_path character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT Image_Gallery.Image_path FROM Image_Gallery WHERE Image_path_id = P_Image_path_id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION PATH_FROM_IMAGE_ID(integer)

SELECT * FROM PATH_FROM_IMAGE_ID(10);
/*-------------------------------Получение ID из пути------------------------------------*/
CREATE OR REPLACE FUNCTION ID_FROM_IMAGE_PATH(
	p_Image_path character varying(255)
)
RETURNS TABLE(
	P_Image_path_id integer
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT Image_path_id FROM Image_Gallery WHERE Image_path = p_Image_path;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ID_FROM_IMAGE_PATH(character varying)

SELECT * FROM ID_FROM_IMAGE_PATH('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\third.png');
/*-------------------------------ПРОВЕРКА НА FAVORITE------------------------------------*/
CREATE OR REPLACE FUNCTION IsFavorite(
	p_Image_id integer,
	p_user_id integer
)
RETURNS TABLE(
	counted bigint
)
AS $$
BEGIN

	IF NOT EXISTS(SELECT 1 FROM users WHERE Users.user_id = p_user_id) THEN
        RAISE EXCEPTION 'this User doesnt exist';
    END IF;
	IF NOT EXISTS(SELECT 1 FROM images WHERE images.image_id = p_Image_id) THEN
        RAISE EXCEPTION 'this Image doesnt exist';
    END IF;
	
	RETURN QUERY 
	SELECT COUNT(*) FROM Favorites WHERE images_id = p_Image_id AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IsFavorite(integer,integer)

SELECT * FROM IsFavorite(109,187);
/*-------------------------------Получение всех стилей------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_STYLES()
RETURNS TABLE(
	p_Style_id integer,
	p_style_name character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT Style_id, style_name FROM styles;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_STYLES(character varying)

SELECT * FROM ALL_STYLES();
/*-------------------------------Получение всех размеров------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_SIZES()
RETURNS TABLE(
	p_Size_id integer,
	p_Size_value character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT Size_id, Size_value FROM sizes;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_SIZES()

SELECT * FROM ALL_SIZES();
/*-------------------------------Получение всех frames------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_FRAMES()
RETURNS TABLE(
	p_frame_id integer,
	p_frame_type character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT frame_id, frame_type FROM frames;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_FRAMES()

SELECT * FROM ALL_FRAMES();
/*-------------------------------Получение всех material------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_MATERIALS()
RETURNS TABLE(
	p_material_id integer,
	p_material_name character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT material_id, material_name FROM materials;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_MATERIALS()

SELECT * FROM ALL_MATERIALS();	
/*-------------------------------Получение всех IMAGEPATHS------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_IMAGEPATHS()
RETURNS TABLE(
	p_image_path_id integer,
	p_image_path character varying(255)
)
AS $$
BEGIN
	RETURN QUERY 
	SELECT * FROM Image_gallery;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_IMAGEPATHS()

SELECT * FROM ALL_IMAGEPATHS();
/*-------------------------------Получение Purchases для usera------------------------------------*/
CREATE OR REPLACE FUNCTION ALL_PURCHASES(p_user_id integer)
RETURNS TABLE(
    p_purchase_id integer,
    p_product_id integer,
    p_customer_id integer,
    p_purchase_date date,
    p_total_price numeric(10,2),
    p_image_name character varying(255),
    p_image_paths character varying(255)[],
    p_author_name character varying(255)
)
AS $$
BEGIN
    RETURN QUERY 
    SELECT p.purchase_id, p.product_id, p.customer_id, p.purchase_date, p.total_price, i.image_name, ARRAY_AGG(ig.image_path) AS p_image_paths, au.fst_name_aut
    FROM purchases p
    JOIN images i ON p.product_id = i.image_id
    JOIN authors au ON i.author_id = au.author_id
    JOIN image_gallery ig ON ig.image_path_id = ANY(i.image_paths_id)
    WHERE p.customer_id = p_user_id
    GROUP BY p.purchase_id, p.product_id, p.customer_id, p.purchase_date, p.total_price, i.image_name, au.fst_name_aut;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION ALL_PURCHASES(integer)
select * from Image_Gallery
SELECT * FROM ALL_PURCHASES(213);