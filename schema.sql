-- Création des schémas
CREATE SCHEMA IF NOT EXISTS forum;
CREATE SCHEMA IF NOT EXISTS shop;
CREATE SCHEMA IF NOT EXISTS gallery;

-- Création des tables pour le forum
CREATE TABLE IF NOT EXISTS forum.users (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    email VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS forum.threads (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    user_id BIGINT NOT NULL REFERENCES forum.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

CREATE TABLE IF NOT EXISTS forum.replies (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    thread_id BIGINT NOT NULL REFERENCES forum.threads (id) ON UPDATE CASCADE ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES forum.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- Création des tables pour le shop
CREATE TABLE IF NOT EXISTS shop.users (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    email VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    is_active BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS shop.products (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL
);

CREATE TABLE IF NOT EXISTS shop.purchases (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    user_id BIGINT NOT NULL REFERENCES shop.users (id) ON UPDATE CASCADE ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES shop.products (id) ON UPDATE CASCADE ON DELETE CASCADE,
    quantity INT NOT NULL,
    purchase_date TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- Création de la table pour la galerie d'images
CREATE TABLE IF NOT EXISTS gallery.images (
    id BIGSERIAL PRIMARY KEY NOT NULL CHECK (id > 0),
    user_id BIGINT REFERENCES forum.users (id) ON UPDATE CASCADE ON DELETE SET NULL,
    url VARCHAR(255) NOT NULL,
    title VARCHAR(100),
    description TEXT,
    uploaded_at TIMESTAMP NOT NULL DEFAULT current_timestamp
);

-- Création de la vue
CREATE VIEW shop.user_purchases
AS
    SELECT 
        U.id AS user_id,
        U.email,
        P.id AS product_id,
        P.name,
        P.price,
        Pu.quantity,
        Pu.purchase_date
    FROM shop.users AS U
    JOIN shop.purchases AS Pu
        ON U.id = Pu.user_id
    JOIN shop.products AS P
        ON P.id = Pu.product_id;

-- Création du déclencheur
CREATE OR REPLACE FUNCTION shop.trigger_purchase()
RETURNS TRIGGER
AS $$
    BEGIN
        UPDATE shop.products 
        SET quantity = quantity - NEW.quantity
        WHERE id = NEW.product_id;

        RETURN NEW;
    END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER after_purchase
    AFTER INSERT ON shop.purchases
    FOR EACH ROW
    EXECUTE PROCEDURE shop.trigger_purchase();

-- Exemple de transaction
BEGIN;
INSERT INTO shop.users(email, password, shipping_address, is_active) 
    VALUES('michel@gmail.com', 'bigpassword', '123 Rue du diable, Paris, Belgique', true);
INSERT INTO shop.products(name, price, quantity) 
    VALUES('Perfect Product', 49.29, 100);
INSERT INTO shop.purchases(user_id, product_id, quantity) 
    VALUES((SELECT id FROM shop.users WHERE email = 'michel@gmail.com'), (SELECT id FROM shop.products WHERE name = 'Perfect Product'), 20);
COMMIT;

-- Exemple de view
SELECT 
    U.id AS user_id,
    U.email,
    P.id AS product_id,
    P.name,
    P.price,
    Pu.quantity,
    Pu.purchase_date
FROM shop.users AS U
JOIN shop.purchases AS Pu
    ON U.id = Pu.user_id
JOIN shop.products AS P
    ON P.id = Pu.product_id;