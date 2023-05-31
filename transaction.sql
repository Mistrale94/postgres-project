BEGIN;
INSERT INTO shop.purchases(user_id, product_id, quantity) 
    VALUES((SELECT id FROM shop.users WHERE email = 'rimka@gmail.com'), (SELECT id FROM shop.products WHERE name = 'Mega Product'), 82);
COMMIT;
