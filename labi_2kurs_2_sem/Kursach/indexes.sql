/*-------------------------------------FULL TEXT SEARCH-------------------------*/
CREATE INDEX idx_Image_name_fts 
ON Images 
USING gin(to_tsvector('english', Image_name));

/*--------------------------Различные формы слова------------------------------*/
SELECT Image_name,
       ts_rank(to_tsvector('english', Image_name), plainto_tsquery('english', 'night')) AS rank
FROM Images
WHERE to_tsvector('english', Image_name) @@ plainto_tsquery('english', 'night')
ORDER BY rank DESC;

/*--------------------------Словосочетание----------------------------*/
SELECT *,
       ts_rank(to_tsvector('english', Image_name), websearch_to_tsquery('english', 'the night')) AS rank
FROM Images
WHERE to_tsvector('english', Image_name) @@ websearch_to_tsquery('english', 'the night')
ORDER BY rank DESC;





CREATE OR REPLACE FUNCTION sort_images_for_wpf(
    Style_id_vvod integer[],
    Size_id_vvod integer[],
    Frame_id_vvod integer[],
    Materials_id_vvod integer[],
    keyword TEXT
)
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
    image_paths character varying(255)[],
    rank REAL
)
AS $$
BEGIN
    IF keyword IS NULL OR keyword = '' THEN 	
        RETURN QUERY
        SELECT i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, 
               i.Date_of_creation, s.Style_name, sz.Size_value, f.Frame_type, ma.material_name,
               ARRAY_AGG(ig.Image_path) AS image_paths,
               CAST(NULL AS REAL) AS rank
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
    ELSE
        RETURN QUERY
        SELECT i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, 
               i.Date_of_creation, s.Style_name, sz.Size_value, f.Frame_type, ma.material_name,
               ARRAY_AGG(ig.Image_path) AS image_paths,
               COALESCE(ts_rank(to_tsvector('english', i.Image_name), plainto_tsquery('english', keyword)), 0) AS rank
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
          AND to_tsvector('english', i.Image_name) @@ plainto_tsquery('english', keyword)
        GROUP BY i.Image_id, i.Image_name, au.fst_name_aut, i.descriptions, i.Date_of_creation,
                 s.Style_name, sz.Size_value, f.Frame_type, ma.material_name, rank
        ORDER BY rank DESC;
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

drop function sort_images_for_wpf

select * from sort_images_for_wpf(null, null, null, null, '')
/*----------------------------------------------------Оптимизация----------------------------------*/
create index idx_users on users (username)

CREATE OR REPLACE FUNCTION fill_users_table()
RETURNS VOID AS $$
DECLARE
    i INT;
    roles TEXT[] := ARRAY['customer', 'author', 'seller'];
BEGIN
    -- Устанавливаем значение i на 1
    i := 1;
    
    -- Заполняем таблицу "Users" случайными данными
    WHILE i <= 100000 LOOP
        INSERT INTO Users (username, user_password, user_role)
        VALUES (substring(md5(random()::text) from 1 for 10), left(md5(random()::text), 6), roles[i % 3 + 1]);
        
        i := i + 1;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT fill_users_table();
SELECT COUNT(*) FROM users;
select * from users
/*----------------------------------------------------Импорт/экспорт данных----------------------------------*/

CREATE OR REPLACE FUNCTION export_purchases(purchases_id INT)
RETURNS VOID 
SECURITY DEFINER
AS $$
DECLARE
    p_fst_name_user TEXT;
    p_sec_name_user TEXT;
	p_image_name TEXT;
	p_author_fst_name TEXT;
    p_purchase_date date;
    p_total_price numeric(10,2);
	
BEGIN
        SELECT c.fst_name, c.sec_name, i.Image_name, au.fst_name_aut, p.purchase_date, p.total_price
		INTO p_fst_name_user, p_sec_name_user, p_image_name, p_author_fst_name, p_purchase_date, p_total_price
		FROM purchases p 
		INNER JOIN customers c ON p.Customer_id = c.Customer_id
		INNER JOIN images i ON p.Product_id = i.Image_id
		INNER JOIN Authors au ON i.Author_id = au.Author_id
		WHERE p.purchase_id = purchases_id;

	
    EXECUTE format(
        'COPY (
            SELECT JSONB_BUILD_OBJECT(
                ''Имя'', %L,
                ''Фамилия'', %L,
                ''Картина'', %L,
                ''Автор картины'', %L,
                ''Дата покупки'', %L,
        		''Цена'', %L
            )
        ) TO %L',
        p_fst_name_user, p_sec_name_user, p_image_name, p_author_fst_name, p_purchase_date,p_total_price,
		'C:\labi_2kurs_2_sem\Kursach\purchase.json'
    );
END;
$$ LANGUAGE plpgsql;

select export_purchases(28);




CREATE OR REPLACE FUNCTION import_Images()
  RETURNS VOID 
  SECURITY DEFINER
AS $$
DECLARE
  json_data JSONB;
BEGIN
  json_data := PG_READ_FILE('C:/labi_2kurs_2_sem/Kursach/Images.json');
  

  INSERT INTO Images (Image_name, Image_paths_id, Author_id, Descriptions, Style_id, Date_of_creation, Size_id, Frame_id, Materials_id)
  SELECT (image->>'image_name')::VARCHAR(255),
         ARRAY(SELECT jsonb_array_elements_text(image->'image_paths_id'))::INT[],
         (image->>'author_id')::INTEGER,
         (image->>'descriptions')::TEXT,
         (image->>'style_id')::INTEGER,
         (image->>'date_of_creation')::INTEGER,
         (image->>'size_id')::INTEGER,
         (image->>'frame_id')::INTEGER,
         (image->>'materials_id')::INTEGER
  FROM jsonb_array_elements(json_data->'data') AS image;

  RETURN;
END;
$$ LANGUAGE plpgsql;

select import_Images();