-- ====================================================================
-- 👤 สร้างตาราง users และ cart_items พร้อมข้อมูลตัวอย่าง (Bookcool)
-- ====================================================================

-- 1. สร้างตาราง users (ข้อมูลบัญชีผู้ใช้ตามโครงสร้าง bookcool)
CREATE TABLE IF NOT EXISTS public.users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    avatar TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. สร้าง/ปรับปรุงตาราง cart_items (ตะกร้าสินค้าของผู้ใช้งาน)
DROP TABLE IF EXISTS public.cart_items CASCADE;
CREATE TABLE public.cart_items (
    cart_item_id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES public.users(user_id) ON DELETE CASCADE,
    username VARCHAR(50) DEFAULT 'user',
    ebook_id BIGINT REFERENCES public.ebooks(ebook_id) ON DELETE CASCADE,
    book_title VARCHAR(255),
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ปลดล็อกสิทธิ์ความปลอดภัย (RLS Policies) ให้หน้าเว็บเข้าถึงได้
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anon can do all on users" ON public.users;
CREATE POLICY "Anon can do all on users" ON public.users FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anon can do all on cart_items" ON public.cart_items;
CREATE POLICY "Anon can do all on cart_items" ON public.cart_items FOR ALL USING (true) WITH CHECK (true);

-- 4. เติมข้อมูลบัญชีผู้ใช้งานตัวอย่าง 2 บัญชี (Admin และ User ทั่วไป)
INSERT INTO public.users (user_id, username, name, email, password, role, avatar)
VALUES 
(1, 'admin', 'พลอยแสง (ผู้ดูแลระบบ)', 'admin@bookcool.com', 'admin', 'admin', 'พล'),
(2, 'user', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 'user', 'สม')
ON CONFLICT (user_id) DO UPDATE SET 
    username = EXCLUDED.username,
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    role = EXCLUDED.role;

SELECT setval('public.users_user_id_seq', (SELECT MAX(user_id) FROM public.users));

-- 5. เติมข้อมูลหนังสือในตะกร้าสินค้าตัวอย่าง (cart_items)
INSERT INTO public.cart_items (user_id, username, ebook_id, book_title, price, quantity)
VALUES 
(2, 'user', 1, 'Lean Startup & Product Strategy', 320.00, 1),
(2, 'user', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1);
