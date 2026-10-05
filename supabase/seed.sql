-- Chopmark demo data: two dealers, 34 items, history and scan logs.
-- Run this in the Supabase SQL editor AFTER schema.sql.
-- Running it again resets the demo dealers and everything they own.
--
-- Demo logins (password for both: chopmark-demo)
--   halvorsen@example.com   Halvorsen Coin & Stamp
--   thirdrail@example.com   Third Rail Collectibles

begin;

delete from auth.users where email in ('halvorsen@example.com', 'thirdrail@example.com');

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new
) values (
  '00000000-0000-0000-0000-000000000000', '11111111-1111-4111-8111-111111111111', 'authenticated', 'authenticated',
  'halvorsen@example.com', crypt('chopmark-demo', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{"dealer_name": "Halvorsen Coin & Stamp"}', now() - interval '410 days 0 hours', now(),
  '', '', '', ''
);
insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
values (
  gen_random_uuid(), '11111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111',
  jsonb_build_object('sub', '11111111-1111-4111-8111-111111111111', 'email', 'halvorsen@example.com', 'email_verified', true, 'phone_verified', false),
  'email', now(), now() - interval '410 days 0 hours', now()
);
update public.dealers set created_at = now() - interval '410 days 0 hours' where id = '11111111-1111-4111-8111-111111111111';

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change, email_change_token_new
) values (
  '00000000-0000-0000-0000-000000000000', '22222222-2222-4222-8222-222222222222', 'authenticated', 'authenticated',
  'thirdrail@example.com', crypt('chopmark-demo', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}', '{"dealer_name": "Third Rail Collectibles"}', now() - interval '265 days 0 hours', now(),
  '', '', '', ''
);
insert into auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
values (
  gen_random_uuid(), '22222222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222',
  jsonb_build_object('sub', '22222222-2222-4222-8222-222222222222', 'email', 'thirdrail@example.com', 'email_verified', true, 'phone_verified', false),
  'email', now(), now() - interval '265 days 0 hours', now()
);
update public.dealers set created_at = now() - interval '265 days 0 hours' where id = '22222222-2222-4222-8222-222222222222';

-- History below is written by hand with past dates, so the automatic
-- event trigger is switched off while the items go in.
alter table public.items disable trigger items_log_event;

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('NYTAJYGW', '11111111-1111-4111-8111-111111111111', '1921 Morgan Silver Dollar', 'coins', 95, 'MS-63', 'Philadelphia mint. Frosty luster, light bag marks on the cheek.', 'in_stock', now() - interval '114 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'NYTAJYGW'), 'added', '{"price": 105}', null, '11111111-1111-4111-8111-111111111111', now() - interval '114 days 5 hours'),
  ((select id from public.items where goid = 'NYTAJYGW'), 'noted', '{}', 'Moved to the front case.', '11111111-1111-4111-8111-111111111111', now() - interval '41 days 3 hours'),
  ((select id from public.items where goid = 'NYTAJYGW'), 'repriced', '{"from": 105, "to": 95}', null, '11111111-1111-4111-8111-111111111111', now() - interval '31 days 4 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'NYTAJYGW'), now() - interval '12 days 11 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'NYTAJYGW'), now() - interval '10 days 4 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('AJ425WRV', '11111111-1111-4111-8111-111111111111', '1909-S VDB Lincoln Cent', 'coins', 1150, 'VF-30', 'Key date. Even chocolate brown, full VDB on the reverse.', 'in_stock', now() - interval '234 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'AJ425WRV'), 'added', '{"price": 1320}', null, '11111111-1111-4111-8111-111111111111', now() - interval '234 days 5 hours'),
  ((select id from public.items where goid = 'AJ425WRV'), 'noted', '{}', 'Checked against the dealer''s ledger entry.', '11111111-1111-4111-8111-111111111111', now() - interval '130 days 9 hours'),
  ((select id from public.items where goid = 'AJ425WRV'), 'repriced', '{"from": 1320, "to": 1150}', null, '11111111-1111-4111-8111-111111111111', now() - interval '125 days 0 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'AJ425WRV'), now() - interval '43 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AJ425WRV'), now() - interval '19 days 7 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('AQSCTPH7', '11111111-1111-4111-8111-111111111111', '1881-S Morgan Silver Dollar', 'coins', 285, 'MS-65', 'Sharp strike, proof-like fields on the obverse.', 'sold', now() - interval '207 days 5 hours', now() - interval '5 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'AQSCTPH7'), 'added', '{"price": 285}', null, '11111111-1111-4111-8111-111111111111', now() - interval '207 days 5 hours'),
  ((select id from public.items where goid = 'AQSCTPH7'), 'noted', '{}', 'Moved to the front case.', '11111111-1111-4111-8111-111111111111', now() - interval '125 days 8 hours'),
  ((select id from public.items where goid = 'AQSCTPH7'), 'sold', '{"from": "in_stock", "price": 285}', null, '11111111-1111-4111-8111-111111111111', now() - interval '5 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '43 days 16 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '15 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '22 days 2 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '33 days 3 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '37 days 6 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '27 days 16 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '34 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '4 days 18 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '1 days 16 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '41 days 20 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '2 days 17 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '32 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '11 days 4 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '42 days 5 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '10 days 6 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '12 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AQSCTPH7'), now() - interval '41 days 10 hours', 'Desktop / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('QZVF2PJX', '11111111-1111-4111-8111-111111111111', '1916-D Mercury Dime', 'coins', 1050, 'G-4', 'Full rims, clear mint mark.', 'in_stock', now() - interval '193 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'QZVF2PJX'), 'added', '{"price": 1050}', null, '11111111-1111-4111-8111-111111111111', now() - interval '193 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'QZVF2PJX'), now() - interval '10 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'QZVF2PJX'), now() - interval '39 days 8 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('UR7928UY', '11111111-1111-4111-8111-111111111111', '1955 Doubled Die Lincoln Cent', 'coins', 1900, 'AU-50', 'Strong doubling on the date and motto.', 'hold', now() - interval '197 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'UR7928UY'), 'added', '{"price": 1900}', null, '11111111-1111-4111-8111-111111111111', now() - interval '197 days 5 hours'),
  ((select id from public.items where goid = 'UR7928UY'), 'held', '{"from": "in_stock", "price": 1900}', null, '11111111-1111-4111-8111-111111111111', now() - interval '1 days 7 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '29 days 6 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '0 days 21 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '4 days 6 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '34 days 1 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '30 days 15 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '43 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '31 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '29 days 13 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '30 days 11 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '33 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '2 days 6 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '0 days 17 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '7 days 8 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '42 days 8 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '20 days 12 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '40 days 17 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '44 days 23 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '37 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '26 days 4 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '2 days 22 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '25 days 13 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '12 days 13 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'UR7928UY'), now() - interval '12 days 9 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('QSF7UGZN', '11111111-1111-4111-8111-111111111111', '1911-B British Trade Dollar, chopmarked', 'coins', 240, 'VF', 'Bombay mint. Six merchant chopmarks on the obverse, two on the reverse.', 'in_stock', now() - interval '33 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'QSF7UGZN'), 'added', '{"price": 290}', null, '11111111-1111-4111-8111-111111111111', now() - interval '33 days 5 hours'),
  ((select id from public.items where goid = 'QSF7UGZN'), 'repriced', '{"from": 290, "to": 240}', null, '11111111-1111-4111-8111-111111111111', now() - interval '18 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'QSF7UGZN'), now() - interval '21 days 4 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'QSF7UGZN'), now() - interval '5 days 4 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'QSF7UGZN'), now() - interval '3 days 4 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('K2PKRZ24', '11111111-1111-4111-8111-111111111111', '1877-S Trade Dollar, chopmarked', 'coins', 325, 'XF-40', 'Three clear chops. Original grey toning.', 'in_stock', now() - interval '159 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'K2PKRZ24'), 'added', '{"price": 290}', null, '11111111-1111-4111-8111-111111111111', now() - interval '159 days 5 hours'),
  ((select id from public.items where goid = 'K2PKRZ24'), 'repriced', '{"from": 290, "to": 325}', null, '11111111-1111-4111-8111-111111111111', now() - interval '155 days 0 hours'),
  ((select id from public.items where goid = 'K2PKRZ24'), 'noted', '{}', 'Re-photographed under daylight lamps.', '11111111-1111-4111-8111-111111111111', now() - interval '89 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '43 days 8 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '1 days 10 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '10 days 13 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '42 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '26 days 9 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '27 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '11 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '18 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '8 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '3 days 1 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '20 days 3 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'K2PKRZ24'), now() - interval '4 days 8 hours', 'iPad / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('KU7RA4FG', '11111111-1111-4111-8111-111111111111', '1936 Walking Liberty Half Dollar', 'coins', 160, 'MS-64', null, 'in_stock', now() - interval '171 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'KU7RA4FG'), 'added', '{"price": 160}', null, '11111111-1111-4111-8111-111111111111', now() - interval '171 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '15 days 2 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '4 days 20 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '16 days 6 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '45 days 18 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '16 days 3 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '25 days 17 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '0 days 7 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '44 days 10 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '36 days 21 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '6 days 8 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '17 days 3 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '32 days 6 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '27 days 6 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '35 days 19 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '14 days 3 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '17 days 1 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'KU7RA4FG'), now() - interval '42 days 13 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('VEWYHC7F', '11111111-1111-4111-8111-111111111111', '1883 Liberty Nickel, No Cents', 'coins', 48, 'AU-58', 'First-year type. Sold as a pair with a ''With Cents'' example on request.', 'in_stock', now() - interval '161 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'VEWYHC7F'), 'added', '{"price": 48}', null, '11111111-1111-4111-8111-111111111111', now() - interval '161 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '1 days 22 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '38 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '34 days 12 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '14 days 16 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '42 days 1 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '44 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '37 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VEWYHC7F'), now() - interval '32 days 11 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('ECB3KG8U', '11111111-1111-4111-8111-111111111111', '1918 24c Curtiss Jenny airmail (Scott C3), used', 'stamps', 95, 'F-VF', 'Light cancel, no thins.', 'sold', now() - interval '223 days 5 hours', now() - interval '2 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'ECB3KG8U'), 'added', '{"price": 95}', null, '11111111-1111-4111-8111-111111111111', now() - interval '223 days 5 hours'),
  ((select id from public.items where goid = 'ECB3KG8U'), 'sold', '{"from": "in_stock", "price": 95}', null, '11111111-1111-4111-8111-111111111111', now() - interval '2 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'ECB3KG8U'), now() - interval '33 days 15 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'ECB3KG8U'), now() - interval '19 days 5 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('JRF68FFY', '11111111-1111-4111-8111-111111111111', '1893 Columbian Exposition $1 (Scott 241), mint hinged', 'stamps', 650, 'Fine', 'Original gum, one hinge remnant.', 'in_stock', now() - interval '50 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'JRF68FFY'), 'added', '{"price": 745}', null, '11111111-1111-4111-8111-111111111111', now() - interval '50 days 5 hours'),
  ((select id from public.items where goid = 'JRF68FFY'), 'noted', '{}', 'Re-photographed under daylight lamps.', '11111111-1111-4111-8111-111111111111', now() - interval '11 days 2 hours'),
  ((select id from public.items where goid = 'JRF68FFY'), 'repriced', '{"from": 745, "to": 650}', null, '11111111-1111-4111-8111-111111111111', now() - interval '8 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '29 days 23 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '25 days 13 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '1 days 22 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '41 days 20 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '31 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '18 days 15 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '32 days 21 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRF68FFY'), now() - interval '35 days 6 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('YBYX6AQG', '11111111-1111-4111-8111-111111111111', '1847 5c Franklin (Scott 1), used', 'stamps', 425, 'Four margins', 'Red grid cancel. Small corner crease noted.', 'in_stock', now() - interval '162 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'YBYX6AQG'), 'added', '{"price": 425}', null, '11111111-1111-4111-8111-111111111111', now() - interval '162 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'YBYX6AQG'), now() - interval '0 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'YBYX6AQG'), now() - interval '7 days 21 hours', 'iPad / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('JRMD237X', '11111111-1111-4111-8111-111111111111', '1930 Graf Zeppelin $1.30 (Scott C14), mint', 'stamps', 475, 'VF', null, 'in_stock', now() - interval '166 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'JRMD237X'), 'added', '{"price": 475}', null, '11111111-1111-4111-8111-111111111111', now() - interval '166 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'JRMD237X'), now() - interval '37 days 12 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRMD237X'), now() - interval '8 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRMD237X'), now() - interval '40 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'JRMD237X'), now() - interval '6 days 7 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'JRMD237X'), now() - interval '44 days 0 hours', 'Desktop / Firefox');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('AJFEE4KD', '11111111-1111-4111-8111-111111111111', '1840 Penny Black, plate 6, used', 'stamps', 210, 'Three margins', 'Red Maltese cross cancel.', 'in_stock', now() - interval '122 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'AJFEE4KD'), 'added', '{"price": 210}', null, '11111111-1111-4111-8111-111111111111', now() - interval '122 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '1 days 11 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '15 days 17 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '21 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '32 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '2 days 3 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '18 days 14 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '35 days 6 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AJFEE4KD'), now() - interval '25 days 15 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('AVJZA3SE', '11111111-1111-4111-8111-111111111111', '1869 Pictorial 3c Locomotive (Scott 114), used', 'stamps', 22, 'VF', null, 'sold', now() - interval '120 days 5 hours', now() - interval '2 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'AVJZA3SE'), 'added', '{"price": 22}', null, '11111111-1111-4111-8111-111111111111', now() - interval '120 days 5 hours'),
  ((select id from public.items where goid = 'AVJZA3SE'), 'noted', '{}', 'Re-photographed under daylight lamps.', '11111111-1111-4111-8111-111111111111', now() - interval '22 days 6 hours'),
  ((select id from public.items where goid = 'AVJZA3SE'), 'sold', '{"from": "in_stock", "price": 22}', null, '11111111-1111-4111-8111-111111111111', now() - interval '2 days 3 hours');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('DZMMZGF3', '11111111-1111-4111-8111-111111111111', 'Omega Seamaster De Ville, 1966, cal. 552', 'watches', 1450, 'Very good, serviced', 'Original dial, unpolished case. Serviced this year, receipt included.', 'in_stock', now() - interval '64 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'DZMMZGF3'), 'added', '{"price": 1305}', null, '11111111-1111-4111-8111-111111111111', now() - interval '64 days 5 hours'),
  ((select id from public.items where goid = 'DZMMZGF3'), 'repriced', '{"from": 1305, "to": 1450}', null, '11111111-1111-4111-8111-111111111111', now() - interval '22 days 7 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'DZMMZGF3'), now() - interval '21 days 7 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'DZMMZGF3'), now() - interval '9 days 8 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'DZMMZGF3'), now() - interval '38 days 18 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'DZMMZGF3'), now() - interval '39 days 6 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'DZMMZGF3'), now() - interval '11 days 20 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('RCHNERVX', '11111111-1111-4111-8111-111111111111', 'Hamilton GG-W-113 military issue, 1974', 'watches', 380, 'Good, running', 'Case back markings legible. Replacement strap.', 'in_stock', now() - interval '216 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'RCHNERVX'), 'added', '{"price": 380}', null, '11111111-1111-4111-8111-111111111111', now() - interval '216 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '15 days 22 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '24 days 2 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '21 days 10 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '44 days 21 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '22 days 9 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '3 days 20 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '25 days 16 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '13 days 18 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '3 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '3 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '2 days 6 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '1 days 19 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '27 days 15 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '13 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '12 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '34 days 18 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '40 days 16 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '19 days 2 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '35 days 19 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '40 days 13 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '24 days 13 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '1 days 9 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '24 days 12 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '25 days 14 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '42 days 20 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '7 days 17 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '12 days 16 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '26 days 12 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '1 days 12 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '11 days 14 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '23 days 10 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '44 days 1 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '1 days 11 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '23 days 0 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '5 days 21 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '22 days 0 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '14 days 16 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '24 days 7 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '17 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '34 days 23 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'RCHNERVX'), now() - interval '7 days 21 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('H8T8RDZ3', '11111111-1111-4111-8111-111111111111', 'Engraved map of New Jersey, 1834, hand coloured', 'art', 260, 'Good, light toning', 'Matted, not framed.', 'in_stock', now() - interval '24 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'H8T8RDZ3'), 'added', '{"price": 260}', null, '11111111-1111-4111-8111-111111111111', now() - interval '24 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'H8T8RDZ3'), now() - interval '12 days 7 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'H8T8RDZ3'), now() - interval '0 days 7 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('D5KBZRXN', '22222222-2222-4222-8222-222222222222', '1989 Upper Deck Ken Griffey Jr. #1', 'cards', 160, 'PSA 8', null, 'sold', now() - interval '47 days 5 hours', now() - interval '4 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'D5KBZRXN'), 'added', '{"price": 160}', null, '22222222-2222-4222-8222-222222222222', now() - interval '47 days 5 hours'),
  ((select id from public.items where goid = 'D5KBZRXN'), 'sold', '{"from": "in_stock", "price": 160}', null, '22222222-2222-4222-8222-222222222222', now() - interval '4 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'D5KBZRXN'), now() - interval '4 days 7 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D5KBZRXN'), now() - interval '2 days 2 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('TJQ9U35Y', '22222222-2222-4222-8222-222222222222', '1986 Fleer Michael Jordan #57', 'cards', 4200, 'PSA 5', 'Centering 60/40. Clean surface.', 'hold', now() - interval '191 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'TJQ9U35Y'), 'added', '{"price": 4200}', null, '22222222-2222-4222-8222-222222222222', now() - interval '191 days 5 hours'),
  ((select id from public.items where goid = 'TJQ9U35Y'), 'held', '{"from": "in_stock", "price": 4200}', null, '22222222-2222-4222-8222-222222222222', now() - interval '0 days 0 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'TJQ9U35Y'), now() - interval '30 days 9 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'TJQ9U35Y'), now() - interval '29 days 5 hours', 'Desktop / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('VJMQCCUP', '22222222-2222-4222-8222-222222222222', '1999 Pokemon Base Set Charizard Holo #4, Unlimited', 'cards', 520, 'PSA 7', null, 'in_stock', now() - interval '177 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'VJMQCCUP'), 'added', '{"price": 470}', null, '22222222-2222-4222-8222-222222222222', now() - interval '177 days 5 hours'),
  ((select id from public.items where goid = 'VJMQCCUP'), 'repriced', '{"from": 470, "to": 520}', null, '22222222-2222-4222-8222-222222222222', now() - interval '14 days 4 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'VJMQCCUP'), now() - interval '15 days 17 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'VJMQCCUP'), now() - interval '2 days 2 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'VJMQCCUP'), now() - interval '24 days 2 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'VJMQCCUP'), now() - interval '31 days 16 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'VJMQCCUP'), now() - interval '45 days 20 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('AHTGXDNP', '22222222-2222-4222-8222-222222222222', '1993 SP Derek Jeter Foil #279', 'cards', 310, 'Raw, near mint', 'Light edge wear on the reverse, typical for the foil.', 'in_stock', now() - interval '60 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'AHTGXDNP'), 'added', '{"price": 310}', null, '22222222-2222-4222-8222-222222222222', now() - interval '60 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '29 days 21 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '10 days 14 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '42 days 6 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '24 days 10 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '37 days 13 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '18 days 9 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '6 days 17 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '40 days 8 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '28 days 21 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '20 days 13 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '3 days 19 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '2 days 21 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '12 days 5 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '17 days 16 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '35 days 6 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '30 days 1 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '13 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '20 days 17 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '32 days 23 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '35 days 18 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '19 days 13 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '11 days 3 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'AHTGXDNP'), now() - interval '30 days 15 hours', 'iPhone / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('D73GA3FV', '22222222-2222-4222-8222-222222222222', 'Magic: The Gathering Revised Underground Sea', 'cards', 780, 'Lightly played', null, 'in_stock', now() - interval '112 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'D73GA3FV'), 'added', '{"price": 860}', null, '22222222-2222-4222-8222-222222222222', now() - interval '112 days 5 hours'),
  ((select id from public.items where goid = 'D73GA3FV'), 'repriced', '{"from": 860, "to": 780}', null, '22222222-2222-4222-8222-222222222222', now() - interval '74 days 9 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '44 days 7 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '21 days 19 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '38 days 6 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '3 days 11 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '12 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '36 days 18 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '43 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '24 days 12 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '40 days 11 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '36 days 14 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '9 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '29 days 20 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '42 days 23 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '26 days 2 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '40 days 10 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '19 days 5 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '38 days 1 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '24 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '45 days 2 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '0 days 2 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '27 days 1 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '32 days 23 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '24 days 16 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '9 days 18 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '16 days 9 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '6 days 10 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '25 days 0 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '37 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '6 days 9 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '13 days 15 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '28 days 4 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '30 days 13 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '10 days 0 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '4 days 6 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '21 days 8 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '43 days 0 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '13 days 12 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '32 days 22 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '36 days 10 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '28 days 21 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'D73GA3FV'), now() - interval '13 days 10 hours', 'iPad / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('VRWMU6X9', '22222222-2222-4222-8222-222222222222', '1979 O-Pee-Chee Wayne Gretzky #18', 'cards', 1350, 'PSA 4', 'Rough cut as issued.', 'in_stock', now() - interval '180 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'VRWMU6X9'), 'added', '{"price": 1350}', null, '22222222-2222-4222-8222-222222222222', now() - interval '180 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '3 days 7 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '17 days 0 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '2 days 21 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '25 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '8 days 20 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '9 days 20 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '44 days 18 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'VRWMU6X9'), now() - interval '32 days 21 hours', 'iPad / Safari');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('BK5VTV74', '22222222-2222-4222-8222-222222222222', 'Amazing Spider-Man #300 (1988)', 'comics', 650, 'CGC 9.2', 'White pages.', 'in_stock', now() - interval '131 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'BK5VTV74'), 'added', '{"price": 700}', null, '22222222-2222-4222-8222-222222222222', now() - interval '131 days 5 hours'),
  ((select id from public.items where goid = 'BK5VTV74'), 'repriced', '{"from": 700, "to": 650}', null, '22222222-2222-4222-8222-222222222222', now() - interval '107 days 1 hours');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('GZ3FZEJP', '22222222-2222-4222-8222-222222222222', 'Uncanny X-Men #266 (1990)', 'comics', 140, 'Raw, VF/NM', null, 'sold', now() - interval '172 days 5 hours', now() - interval '7 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'GZ3FZEJP'), 'added', '{"price": 140}', null, '22222222-2222-4222-8222-222222222222', now() - interval '172 days 5 hours'),
  ((select id from public.items where goid = 'GZ3FZEJP'), 'noted', '{}', 'Moved to the front case.', '22222222-2222-4222-8222-222222222222', now() - interval '67 days 2 hours'),
  ((select id from public.items where goid = 'GZ3FZEJP'), 'sold', '{"from": "in_stock", "price": 140}', null, '22222222-2222-4222-8222-222222222222', now() - interval '7 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '16 days 16 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '4 days 11 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '17 days 17 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '34 days 5 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '10 days 21 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '18 days 22 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '30 days 23 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '35 days 15 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '5 days 7 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '22 days 10 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '20 days 15 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'GZ3FZEJP'), now() - interval '28 days 15 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('B4KD8NKB', '22222222-2222-4222-8222-222222222222', 'Giant-Size X-Men #1 (1975)', 'comics', 1900, 'CGC 6.5', 'Off-white to white pages.', 'in_stock', now() - interval '55 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'B4KD8NKB'), 'added', '{"price": 1900}', null, '22222222-2222-4222-8222-222222222222', now() - interval '55 days 5 hours'),
  ((select id from public.items where goid = 'B4KD8NKB'), 'noted', '{}', 'Re-photographed under daylight lamps.', '22222222-2222-4222-8222-222222222222', now() - interval '11 days 9 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '4 days 7 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '30 days 1 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '13 days 18 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '18 days 3 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '15 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '40 days 14 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '19 days 12 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'B4KD8NKB'), now() - interval '35 days 2 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('MJMZD9F8', '22222222-2222-4222-8222-222222222222', 'Saga #1 (2012), first print', 'comics', 120, 'Near mint', null, 'sold', now() - interval '230 days 5 hours', now() - interval '8 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'MJMZD9F8'), 'added', '{"price": 120}', null, '22222222-2222-4222-8222-222222222222', now() - interval '230 days 5 hours'),
  ((select id from public.items where goid = 'MJMZD9F8'), 'sold', '{"from": "in_stock", "price": 120}', null, '22222222-2222-4222-8222-222222222222', now() - interval '8 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'MJMZD9F8'), now() - interval '30 days 11 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'MJMZD9F8'), now() - interval '30 days 1 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'MJMZD9F8'), now() - interval '7 days 3 hours', 'Desktop / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('A6Z93RKT', '22222222-2222-4222-8222-222222222222', 'Teenage Mutant Ninja Turtles #1 (1984), third print', 'comics', 900, 'Very good', 'Spine roll, complete.', 'in_stock', now() - interval '101 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'A6Z93RKT'), 'added', '{"price": 1035}', null, '22222222-2222-4222-8222-222222222222', now() - interval '101 days 5 hours'),
  ((select id from public.items where goid = 'A6Z93RKT'), 'repriced', '{"from": 1035, "to": 900}', null, '22222222-2222-4222-8222-222222222222', now() - interval '10 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '3 days 0 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '26 days 10 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '10 days 23 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '6 days 2 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '5 days 8 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '10 days 20 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '0 days 18 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '45 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '36 days 23 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '28 days 15 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '0 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'A6Z93RKT'), now() - interval '7 days 10 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('8U4W9DX6', '22222222-2222-4222-8222-222222222222', 'Seiko 6139-6002 chronograph, 1973', 'watches', 520, 'Good, running', 'Yellow dial. Chronograph resets to zero.', 'in_stock', now() - interval '81 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = '8U4W9DX6'), 'added', '{"price": 560}', null, '22222222-2222-4222-8222-222222222222', now() - interval '81 days 5 hours'),
  ((select id from public.items where goid = '8U4W9DX6'), 'repriced', '{"from": 560, "to": 520}', null, '22222222-2222-4222-8222-222222222222', now() - interval '6 days 3 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '21 days 4 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '22 days 0 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '19 days 11 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '17 days 21 hours', 'Desktop / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '1 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '16 days 14 hours', 'iPad / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '41 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '27 days 4 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '37 days 10 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '14 days 16 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '11 days 5 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '25 days 13 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '5 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '12 days 23 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '12 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '21 days 11 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '39 days 19 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '31 days 3 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '38 days 18 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '16 days 0 hours', 'Android / Chrome'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '18 days 0 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '23 days 19 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = '8U4W9DX6'), now() - interval '16 days 7 hours', 'Android / Chrome');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('2UJ32G5Z', '22222222-2222-4222-8222-222222222222', 'Timex Marlin, 1968, manual wind', 'watches', 145, 'Very good', null, 'sold', now() - interval '90 days 5 hours', now() - interval '1 days 3 hours');
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = '2UJ32G5Z'), 'added', '{"price": 145}', null, '22222222-2222-4222-8222-222222222222', now() - interval '90 days 5 hours'),
  ((select id from public.items where goid = '2UJ32G5Z'), 'sold', '{"from": "in_stock", "price": 145}', null, '22222222-2222-4222-8222-222222222222', now() - interval '1 days 3 hours');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('RBKKTYMF', '22222222-2222-4222-8222-222222222222', 'Woodcut, ''Mill Street, Morning'', signed in pencil, c. 1938', 'art', 340, 'Good, light foxing', 'Unframed. Sheet 11 x 14 in.', 'hold', now() - interval '73 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'RBKKTYMF'), 'added', '{"price": 340}', null, '22222222-2222-4222-8222-222222222222', now() - interval '73 days 5 hours'),
  ((select id from public.items where goid = 'RBKKTYMF'), 'noted', '{}', 'Shown at the spring show, table 14.', '22222222-2222-4222-8222-222222222222', now() - interval '30 days 4 hours'),
  ((select id from public.items where goid = 'RBKKTYMF'), 'held', '{"from": "in_stock", "price": 340}', null, '22222222-2222-4222-8222-222222222222', now() - interval '1 days 1 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'RBKKTYMF'), now() - interval '44 days 2 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'RBKKTYMF'), now() - interval '30 days 20 hours', 'Desktop / Firefox'),
  ((select id from public.items where goid = 'RBKKTYMF'), now() - interval '26 days 9 hours', 'Desktop / Firefox');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('XPTJASDW', '22222222-2222-4222-8222-222222222222', 'Linocut, ''Elevated Line'', edition 14/50, 1972', 'art', 220, 'Very good', null, 'in_stock', now() - interval '189 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'XPTJASDW'), 'added', '{"price": 200}', null, '22222222-2222-4222-8222-222222222222', now() - interval '189 days 5 hours'),
  ((select id from public.items where goid = 'XPTJASDW'), 'noted', '{}', 'Moved to the front case.', '22222222-2222-4222-8222-222222222222', now() - interval '128 days 4 hours'),
  ((select id from public.items where goid = 'XPTJASDW'), 'repriced', '{"from": 200, "to": 220}', null, '22222222-2222-4222-8222-222222222222', now() - interval '30 days 7 hours');

insert into public.items (goid, dealer_id, name, category, price, condition, notes, status, created_at, sold_at)
values ('PUQ8P85U', '22222222-2222-4222-8222-222222222222', 'Japanese woodblock print, snow scene, Meiji-period edition', 'art', 480, 'Good, trimmed margins', 'Publisher seal present in the left margin.', 'in_stock', now() - interval '239 days 5 hours', null);
insert into public.events (item_id, type, detail, note, actor_id, created_at) values
  ((select id from public.items where goid = 'PUQ8P85U'), 'added', '{"price": 480}', null, '22222222-2222-4222-8222-222222222222', now() - interval '239 days 5 hours');
insert into public.scans (item_id, scanned_at, device) values
  ((select id from public.items where goid = 'PUQ8P85U'), now() - interval '38 days 0 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'PUQ8P85U'), now() - interval '32 days 20 hours', 'iPhone / Safari'),
  ((select id from public.items where goid = 'PUQ8P85U'), now() - interval '27 days 5 hours', 'iPad / Safari'),
  ((select id from public.items where goid = 'PUQ8P85U'), now() - interval '10 days 16 hours', 'Android / Chrome'),
  ((select id from public.items where goid = 'PUQ8P85U'), now() - interval '17 days 22 hours', 'iPhone / Safari');

alter table public.items enable trigger items_log_event;

commit;
