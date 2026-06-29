CREATE TABLE IF NOT EXISTS public.Users
(
    User_id serial NOT NULL,
    username character varying(255) COLLATE pg_catalog."default" NOT NULL,
    user_password character varying(255) COLLATE pg_catalog."default" NOT NULL,
    user_role character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT Users_pkey PRIMARY KEY (User_id),
	CONSTRAINT unique_username UNIQUE (username)
);

INSERT INTO Users (username, user_password, user_role)
VALUES ('Pavel', '123231', 'customer'),
       ('Maksim', '12412414', 'author'),
       ('Nikolay', '12412414', 'seller'),
       ('Ivan', 'password1', 'customer'),
       ('Anna', 'password2', 'author'),
       ('Olga', 'password3', 'seller'),
       ('Dmitry', 'password4', 'customer'),
	   ('Maria', 'password5', 'customer'),
       ('Alex', 'password6', 'author'),
       ('Elena', 'password7', 'seller');
	   	
select * from Users where User_id =154
DELETE FROM Users;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Authors
(
    Author_id integer NOT NULL,
	username_aut character varying(255)  NOT NULL,
    fst_name_aut character varying(255) COLLATE pg_catalog."default",
    sec_name_aut character varying(255) COLLATE pg_catalog."default",
    email_aut character varying(255) COLLATE pg_catalog."default", 
    CONSTRAINT Authors_pkey PRIMARY KEY (Author_id),
	CONSTRAINT Authors_fkey FOREIGN KEY (Author_id) REFERENCES Users (User_id)
);
	   


select * from Authors where fst_name_aut is not null
DELETE FROM Authors;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Customers
(
    customer_id integer NOT NULL,
	username character varying(255)  NOT NULL,
    fst_name character varying(255) COLLATE pg_catalog."default" ,
    sec_name character varying(255) COLLATE pg_catalog."default" , 
    email character varying(255) COLLATE pg_catalog."default" ,
    CONSTRAINT customers_pkey PRIMARY KEY (customer_id),
	CONSTRAINT customers_fkey FOREIGN KEY (customer_id) REFERENCES Users (User_id)
);

select * from Customers
DELETE FROM Customers;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Sellers
(
    Seller_id serial NOT NULL,
	username character varying(255) NOT NULL;
    fst_name character varying(255) COLLATE pg_catalog."default",
    sec_name character varying(255) COLLATE pg_catalog."default",
    email character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT Sellers_pkey PRIMARY KEY (Seller_id),
	CONSTRAINT Sellers_fkey FOREIGN KEY (Seller_id) REFERENCES Users (User_id),
);


select * from Sellers 
DELETE FROM Sellers;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

CREATE TABLE IF NOT EXISTS public.Invitations (
    invitation_id serial NOT NULL,
    seller_id integer NOT NULL,
    author_id integer NOT NULL,
    invitation_text text,
    invitation_status character varying(20) NOT NULL,
	invitation_date TIMESTAMP NOT NULL
	CONSTRAINT invitation_pkey PRIMARY KEY (invitation_id),
	CONSTRAINT invitation_seller_fkey FOREIGN KEY (seller_id) REFERENCES Sellers (Seller_id),
	CONSTRAINT invitation_author_fkey FOREIGN KEY (author_id) REFERENCES Authors (author_id)
);

select * from Invitations
DELETE FROM Invitations;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Cooperations
(
	Cooperation_id serial,
    Seller_id serial NOT NULL,
    Author_id serial NOT NULL,
	Info_coop character varying(255),
	cooperation_date TIMESTAMP NOT NULL,
    CONSTRAINT Cooperation_pkey PRIMARY KEY (Cooperation_id),
    CONSTRAINT Cooperation_seller_fkey FOREIGN KEY (Seller_id) REFERENCES Sellers (Seller_id),
    CONSTRAINT Cooperation_Author_fkey FOREIGN KEY (Author_id) REFERENCES Authors (Author_id),
	CONSTRAINT author_uniq UNIQUE (Author_id),
);

select * from Cooperations
DELETE FROM Cooperations;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Images
(
    Image_id serial NOT NULL,
	Image_name character varying(255) COLLATE pg_catalog."default" NOT NULL unique,
    Image_paths_id integer[] NOT NULL,
	Author_id serial NOT NULL, 
	descriptions text,
	Style_id serial NOT NULL,
	Date_of_creation integer NOT NULL,
	Size_id serial NOT NULL,
	Frame_id serial NOT NULL,
	Materials_id serial NOT NULL,
    CONSTRAINT Images_pkey PRIMARY KEY (Image_id),
	CONSTRAINT Images_authors_fkey FOREIGN KEY (Author_id) REFERENCES Authors (Author_id),
	CONSTRAINT image_style_fkey FOREIGN KEY (Style_id) REFERENCES Styles (Style_id),
	CONSTRAINT image_size_fkey FOREIGN KEY (Size_id) REFERENCES Sizes (Size_id),
	CONSTRAINT image_frame_fkey FOREIGN KEY (Frame_id) REFERENCES Frames (Frame_id),
	CONSTRAINT image_material_fkey FOREIGN KEY (Materials_id) REFERENCES Materials (material_id),
	
);

select * from images
DELETE FROM Images;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Styles
(
	Style_id serial NOT NULL,
	style_name character varying(255) COLLATE pg_catalog."default" NOT NULL,
	style_description character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT Style_pkey PRIMARY KEY (Style_id)
);

INSERT INTO public.Styles (style_name, style_description) 
VALUES('Абстракционизм', 'Искусство, основанное на представлении абстрактных форм и цветов без прямого отображения реальных объектов.'),
      ('Импрессионизм', 'Художественное направление, стремящееся передать мгновенные впечатления и эмоции отображаемого объекта, акцентируя внимание на свете, цвете и настроении.'),
      ('Реализм', 'Искусство, стремящееся к максимально реалистичному и точному изображению реальных объектов и сцен.'),
      ('Сюрреализм', 'Художественное направление, представляющее сновидения, фантазии и подсознательные проявления в форме неожиданных и нереальных комбинаций объектов.');
      


select * from Styles
DELETE FROM Styles;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Sizes
(
	Size_id serial NOT NULL,
	Size_value character varying(255) COLLATE pg_catalog."default" NOT NULL,
	Size_propoution character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT size_pkey PRIMARY KEY (Size_id)

);
INSERT INTO public.Sizes (Size_value, Size_propoution)
VALUES
('70x39', '16:9'),
('20x20', '1:1'),
('120x213', '9:16'),
('180x320', '3:5');
	
select * from Sizes
DELETE FROM Sizes;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Frames
(
	Frame_id serial NOT NULL,
	Frame_type character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT Frame_pkey PRIMARY KEY (Frame_id),
);
INSERT INTO public.Frames (Frame_type)
VALUES
    ('none'),
    ('Black'),
	('White'),
	('Gray');
	
select * from Frames
DELETE FROM Frames;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Image_Gallery
(
	Image_path_id serial NOT NULL,
    Image_path character varying(255) NOT NULL unique,
    CONSTRAINT image_paths_id_pkey PRIMARY KEY (Image_path_id)
);

INSERT INTO public.Image_Gallery (Image_path)
VALUES
    ('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\fst.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\fst_2.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\third.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\4.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\5.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\6.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\7.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\8.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\9.png'),
	('C:\labi_2kurs_2_sem\Kursach\Kursovaya\Kursovaya\image_paths\10.png');
	
	
	
	
select * from Image_Gallery
DELETE FROM Image_Gallery;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Materials (
    material_id SERIAL Not Null,
    material_name VARCHAR(255) NOT NULL,
    description TEXT,
	CONSTRAINT material_pkey PRIMARY KEY (material_id)
);

INSERT INTO public.Materials (material_name, description)
VALUES
    ('Acrylic Paint', 'Quick-drying paint based on acrylic, available in a wide range of colors. Can be used on various surfaces such as canvas, wood, paper, and more.'),
    ('Oil Paint', 'Traditional paint based on oil, known for its rich colors and ability to create deep and vibrant effects. Typically used on canvas or wood.'),
    ('Watercolor', 'Transparent paint that is diluted with water. It allows for creating transparent layers and color blending effects. Usually applied on specialized watercolor paper.'),
    ('Gouache', 'Water-based paint with high pigment density. Provides bright and saturated colors. Used on paper, cardboard, or canvas.'),
    ('Markers', 'Markers based on alcohol or water, allowing for creating clear and vibrant lines. Used on paper or other surfaces.');
	
select * from Materials
DELETE FROM Materials;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.Favorites
(
	favorite_id serial NOT NULL,
	user_id integer NOT NULL,
	images_id integer NOT NULL,
    CONSTRAINT favorite_pkey PRIMARY KEY (favorite_id),
	CONSTRAINT favorite_user_fkey FOREIGN KEY (user_id) REFERENCES Sellers (User_id),
	CONSTRAINT favorite_image_fkey FOREIGN KEY (images_id) REFERENCES Images (image_id)
);

select * from Favorites
DELETE FROM Favorites;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

CREATE TABLE IF NOT EXISTS public.purchases
(
	purchase_id serial NOT NULL,
    Product_id serial NOT NULL,
	Customer_id serial NOT NULL,
	purchase_date date,
	total_price numeric(10,2) NOT NULL,
    CONSTRAINT purchase_pkey PRIMARY KEY (purchase_id),
	CONSTRAINT purch_customer_fkey FOREIGN KEY (Customer_id) REFERENCES Customers (customer_id),
	CONSTRAINT purch_image_fkey FOREIGN KEY (Product_id) REFERENCES Images (image_id) 
);

select * from purchases
DELETE FROM purchases;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS public.availability
(
    Image_id serial NOT NULL,
	Available bool NOT NULL,
	CONSTRAINT avail_image_fkey FOREIGN KEY (Image_id) REFERENCES Images (Image_id)
);

select * from availability
DELETE FROM availability;
/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*ALTER TABLE purchases
DROP COLUMN Seller_id

ALTER TABLE Frames
DROP COLUMN Seller_id;



drop table Cooperation;

ALTER TABLE Cooperations
ADD CONSTRAINT author_uniq UNIQUE (Author_id)

ALTER TABLE availability
add CONSTRAINT avail_image_fkey FOREIGN KEY (Product_id) REFERENCES Images (Image_id) ;

ALTER TABLE Frames
drop CONSTRAINT Frame_size_fkey
*/

