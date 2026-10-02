-- ====================================================================
-- 🚀 เติมข้อมูลให้ครบทุกตารางที่ยังขึ้น "This table is empty"
-- (แก้ปัญหา profiles, user_library, users, cart_items)
-- ====================================================================

-- 1. ปลดล็อก Foreign Key ของ profiles ชั่วคราว เพื่อให้ใส่ Mock Data ได้โดยไม่ต้องรอ Supabase Auth
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE public.profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 2. เติมข้อมูลลงตาราง profiles
INSERT INTO public.profiles (id, username, full_name, email, role, avatar_url)
VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'admin', 'พลอยแสง (ผู้ดูแลระบบ)', 'admin@bookcool.com', 'admin', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200'),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'user', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200')
ON CONFLICT (id) DO UPDATE SET 
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role;

-- 3. เติมข้อมูลลงตาราง user_library (หนังสือในคลังที่ซื้อแล้วของ user)
INSERT INTO public.user_library (user_id, ebook_id, order_id, access_type, access_granted_at)
VALUES 
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 1, 'ORD-2026-001', 'purchased', NOW()),
('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 3, 'ORD-2026-002', 'purchased', NOW())
ON CONFLICT (user_id, ebook_id) DO NOTHING;

-- 4. เติมข้อมูลลงตาราง users (ตารางสมาชิก)
CREATE TABLE IF NOT EXISTS public.users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    avatar TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anon can do all on users" ON public.users;
CREATE POLICY "Anon can do all on users" ON public.users FOR ALL USING (true) WITH CHECK (true);

INSERT INTO public.users (user_id, username, name, email, password, role, avatar)
VALUES 
(1, 'admin', 'พลอยแสง (ผู้ดูแลระบบ)', 'admin@bookcool.com', 'admin', 'admin', 'พล'),
(2, 'user', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 'user', 'สม')
ON CONFLICT (user_id) DO NOTHING;

-- 5. เติมข้อมูลลงตาราง cart_items (สินค้าในตะกร้า)
ALTER TABLE public.cart_items DROP CONSTRAINT IF EXISTS cart_items_user_id_fkey;
ALTER TABLE public.cart_items ALTER COLUMN user_id DROP NOT NULL;

INSERT INTO public.cart_items (ebook_id, quantity)
VALUES 
(1, 1),
(4, 1)
ON CONFLICT DO NOTHING;
