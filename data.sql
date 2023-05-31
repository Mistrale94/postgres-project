-- Insert data
INSERT INTO shop.users(email, password, shipping_address, is_active) 
    VALUES('john@gmail.com', 'securepassword', '123 Rue de la Paix, Paris, France', true);
INSERT INTO shop.products(name, price, quantity) 
    VALUES('Awesome Product', 99.99, 10);

-- Add new user and product
INSERT INTO shop.users(email, password, shipping_address, is_active) 
    VALUES('rimka@gmail.com', 'mypassword', '666 rue Jean, Beauvais, Chine', true);
INSERT INTO shop.products(name, price, quantity) 
    VALUES('Mega Product', 149.59, 80);

-- Example transaction
BEGIN;
INSERT INTO shop.purchases(user_id, product_id, quantity) 
    VALUES((SELECT id FROM shop.users WHERE email = 'rimka@gmail.com'), (SELECT id FROM shop.products WHERE name = 'Mega Product'), 2);
COMMIT;
