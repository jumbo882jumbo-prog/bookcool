-- ====================================================================
-- 📚 BOOKCOOL DATABASE SCHEMA FOR SUPABASE (8 TABLES)
-- ====================================================================
-- คำสั่ง SQL สำหรับสร้างฐานข้อมูล 8 ตารางที่สัมพันธ์กันอย่างสมบูรณ์
-- สำหรับระบบร้านค้า E-Book และการจัดการหนังสือ (E-Book Store & Library System)
-- รองรับ RLS (Row Level Security), Foreign Keys, Indexes และ Mock Data
-- สามารถคัดลอกทั้งหมดนี้ไปวางใน "Supabase SQL Editor" แล้วกด "RUN" ได้ทันที!
-- ====================================================================

-- 0. เปิดใช้งาน Extension สำหรับ UUID (หากยังไม่ได้เปิด)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ====================================================================
-- 1. ตาราง categories (หมวดหมู่หนังสือ)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50) DEFAULT '📚',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 2. ตาราง ebooks (ข้อมูลหนังสือ - ตารางหลักของระบบ)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.ebooks (
    ebook_id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    category_id INT REFERENCES public.categories(category_id) ON DELETE SET NULL,
    category_name VARCHAR(100),
    description TEXT,
    cover_image TEXT,
    download_url TEXT DEFAULT '#',
    sample_url TEXT,
    page_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 3. ตาราง profiles (ข้อมูลผู้ใช้งาน เชื่อมโยงกับ auth.users ของ Supabase)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(150),
    email VARCHAR(255),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 4. ตาราง orders (ข้อมูลคำสั่งซื้อ / หัวบิลชำระเงิน)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_name VARCHAR(150) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_username VARCHAR(50),
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    slip_url TEXT,
    payment_method VARCHAR(50) DEFAULT 'bank_transfer',
    order_date TIMESTAMPTZ DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 5. ตาราง order_items (รายการหนังสือในแต่ละคำสั่งซื้อ: 1 Order มีหลาย Items)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.order_items (
    item_id BIGSERIAL PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    ebook_id BIGINT REFERENCES public.ebooks(ebook_id) ON DELETE RESTRICT,
    category_id INT REFERENCES public.categories(category_id) ON DELETE SET NULL,
    book_title VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 6. ตาราง user_library (คลังหนังสือที่ครอบครอง / การยืม-คืน / สิทธิ์การอ่าน)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.user_library (
    library_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    ebook_id BIGINT NOT NULL REFERENCES public.ebooks(ebook_id) ON DELETE CASCADE,
    order_id VARCHAR(50) REFERENCES public.orders(order_id) ON DELETE SET NULL,
    access_type VARCHAR(20) DEFAULT 'purchased' CHECK (access_type IN ('purchased', 'borrowed', 'gift')),
    borrow_started_at TIMESTAMPTZ,
    borrow_expires_at TIMESTAMPTZ,
    is_returned BOOLEAN DEFAULT FALSE,
    access_granted_at TIMESTAMPTZ DEFAULT NOW(),
    last_downloaded_at TIMESTAMPTZ,
    CONSTRAINT unique_user_book UNIQUE (user_id, ebook_id)
);

-- ====================================================================
-- 7. ตาราง book_reviews (รีวิวและความคิดเห็นหนังสือ)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.book_reviews (
    review_id BIGSERIAL PRIMARY KEY,
    ebook_id BIGINT NOT NULL REFERENCES public.ebooks(ebook_id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 8. ตาราง cart_items (ตะกร้าสินค้าของผู้ใช้งานแบบเชื่อมต่อฐานข้อมูล)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.cart_items (
    cart_item_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    ebook_id BIGINT NOT NULL REFERENCES public.ebooks(ebook_id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_cart UNIQUE (user_id, ebook_id)
);

-- ====================================================================
-- 9. สร้าง Indexes เพื่อเพิ่มความเร็วในการค้นหาและเชื่อมโยงข้อมูล
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_ebooks_category ON public.ebooks(category_id);
CREATE INDEX IF NOT EXISTS idx_ebooks_title ON public.ebooks(title);
CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_category ON public.order_items(category_id);
CREATE INDEX IF NOT EXISTS idx_user_library_user ON public.user_library(user_id);
CREATE INDEX IF NOT EXISTS idx_book_reviews_ebook ON public.book_reviews(ebook_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user ON public.cart_items(user_id);

-- ====================================================================
-- 10. ระบบความปลอดภัย Row Level Security (RLS) & นโยบายความปลอดภัย (Policies)
-- ====================================================================

-- 10.1 เปิดใช้งาน RLS บนทุกตาราง
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ebooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_library ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- 10.2 กำหนด Policies ให้แต่ละตาราง

-- [categories] ทุกคนสามารถอ่านได้
DROP POLICY IF EXISTS "Public can view categories" ON public.categories;
CREATE POLICY "Public can view categories" ON public.categories FOR SELECT USING (true);

-- [ebooks] ทุกคนสามารถอ่านหนังสือที่เผยแพร่แล้วได้
DROP POLICY IF EXISTS "Public can view published ebooks" ON public.ebooks;
CREATE POLICY "Public can view published ebooks" ON public.ebooks FOR SELECT USING (is_published = true);

-- [ebooks] อนุญาตให้อัปเดต/เพิ่ม สำหรับแอดมินหรือ Service Role
DROP POLICY IF EXISTS "Admins can manage ebooks" ON public.ebooks;
CREATE POLICY "Admins can manage ebooks" ON public.ebooks FOR ALL USING (
    auth.role() = 'service_role' OR 
    EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- [profiles] ทุกคนอ่านโปรไฟล์สาธารณะได้
DROP POLICY IF EXISTS "Public can view profiles" ON public.profiles;
CREATE POLICY "Public can view profiles" ON public.profiles FOR SELECT USING (true);

-- [profiles] ผู้ใช้แก้ไขได้เฉพาะข้อมูลตนเอง
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- [orders] ผู้ใช้สร้างออเดอร์ใหม่ได้
DROP POLICY IF EXISTS "Users can insert own orders" ON public.orders;
CREATE POLICY "Users can insert own orders" ON public.orders FOR INSERT WITH CHECK (
    auth.uid() IS NULL OR auth.uid() = user_id
);

-- [orders] ผู้ใช้ดูออเดอร์ของตนเองได้ แอดมินดูได้ทั้งหมด
DROP POLICY IF EXISTS "Users view own orders or Admin view all" ON public.orders;
CREATE POLICY "Users view own orders or Admin view all" ON public.orders FOR SELECT USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- [orders] แอดมินอัปเดตสถานะออเดอร์ได้
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;
CREATE POLICY "Admins can update orders" ON public.orders FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
);

-- [order_items] อนุญาตให้เพิ่มรายการพร้อมการสั่งซื้อ
DROP POLICY IF EXISTS "Allow insert order_items" ON public.order_items;
CREATE POLICY "Allow insert order_items" ON public.order_items FOR INSERT WITH CHECK (true);

-- [order_items] ผู้ใช้ดูรายการในออเดอร์ของตนเองได้
DROP POLICY IF EXISTS "Users view own order items" ON public.order_items;
CREATE POLICY "Users view own order items" ON public.order_items FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.orders 
        WHERE orders.order_id = order_items.order_id 
        AND (orders.user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin'))
    )
);

-- [user_library] ผู้ใช้เข้าถึงได้เฉพาะหนังสือในคลังของตนเอง
DROP POLICY IF EXISTS "Users can view own library" ON public.user_library;
CREATE POLICY "Users can view own library" ON public.user_library FOR SELECT USING (auth.uid() = user_id);

-- [book_reviews] ทุกคนอ่านรีวิวได้
DROP POLICY IF EXISTS "Public can view reviews" ON public.book_reviews;
CREATE POLICY "Public can view reviews" ON public.book_reviews FOR SELECT USING (true);

-- [book_reviews] สมาชิกที่ล็อกอินสามารถเขียนรีวิวได้
DROP POLICY IF EXISTS "Authenticated users can add reviews" ON public.book_reviews;
CREATE POLICY "Authenticated users can add reviews" ON public.book_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

-- [cart_items] ผู้ใช้จัดการตะกร้าตนเองได้อย่างอิสระ
DROP POLICY IF EXISTS "Users manage own cart" ON public.cart_items;
CREATE POLICY "Users manage own cart" ON public.cart_items FOR ALL USING (auth.uid() = user_id);


-- ====================================================================
-- 11. Trigger อัตโนมัติ: สร้าง Profile เมื่อมีผู้ใช้ลงทะเบียนใหม่ใน Supabase Auth
-- ====================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username, full_name, email, role, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
        NEW.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ผูก Trigger กับ auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ====================================================================
-- 12. ข้อมูลตั้งต้นสำหรับระบบ (Initial Mock / Seed Data)
-- ====================================================================

-- 12.1 เพิ่มหมวดหมู่หนังสือ
INSERT INTO public.categories (category_id, category_name, description, icon) VALUES
(1, 'ธุรกิจ & การตลาด', 'หนังสือกลยุทธ์ธุรกิจ การสร้างสตาร์ทอัพ และการตลาดดิจิทัล', '💼'),
(2, 'วรรณกรรม & นวนิยาย', 'นวนิยายแฟนตาซี ไซไฟ สืบสวนสอบสวน และวรรณกรรมคลาสสิก', '📖'),
(3, 'วิทยาศาสตร์ข้อมูล & AI', 'ปัญญาประดิษฐ์ Machine Learning, Prompt Engineering และ Data Science', '🤖'),
(4, 'พัฒนาตนเอง & จิตวิทยา', 'การพัฒนาบุคลิกภาพ จิตวิทยาการทำงาน และการบริหารเวลา', '🧠'),
(5, 'การเงิน & การลงทุน', 'การวางแผนภาษี หุ้น กองทุนรวม และการสร้างอิสรภาพทางการเงิน', '📈'),
(6, 'เทคโนโลยี & การเขียนโปรแกรม', 'การพัฒนาเว็บแอปพลิเคชัน ฐานข้อมูล และวิศวกรรมซอฟต์แวร์', '💻')
ON CONFLICT (category_id) DO UPDATE SET 
    category_name = EXCLUDED.category_name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon;

-- 12.2 เพิ่มหนังสือ 8 เล่มตามฐานข้อมูลของ bookcool
INSERT INTO public.ebooks (ebook_id, title, author_name, price, category_id, category_name, description, cover_image, download_url) VALUES
(1, 'Lean Startup & Product Strategy', 'ณัฐพร นวัตกรรม', 320.00, 1, 'ธุรกิจ & การตลาด', 'คู่มือทดสอบไอเดียธุรกิจ สร้าง MVP และปรับเปลี่ยนทิศทางอย่างรวดเร็วโดยไม่เผางบประมาณ', 'https://images.unsplash.com/photo-1553729459-efe14ef6055d?auto=format&fit=crop&q=80&w=600', '#'),
(2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 'กวี ศรีสยาม', 195.00, 2, 'วรรณกรรม & นวนิยาย', 'นวนิยายไซไฟแฟนตาซี การเดินทางข้ามห้วงกาลเวลาเพื่อกอบกู้ดวงดาวที่สาบสูญ', 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=600', '#'),
(3, 'Practical Generative AI for Developers', 'ดร. ธีรภัทร ปัญญาประดิษฐ์', 490.00, 3, 'วิทยาศาสตร์ข้อมูล & AI', 'คู่มือนักพัฒนาในการเชื่อมต่อ LLM APIs, Prompt Engineering, RAG Architecture และการสร้าง AI Agents', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=600', '#'),
(4, 'The Modern Growth Hacking & Digital Marketing', 'อนันต์ การตลาดดิจิทัล', 390.00, 1, 'ธุรกิจ & การตลาด', 'กลยุทธ์ยิงแอดและสร้าง Funnel ปิดการขายอัตโนมัติ สำหรับธุรกิจออนไลน์ที่ต้องการสเกลยอดขาย', 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=600', '#'),
(5, 'จิตวิทยาการบริหารเวลา Focus & Productivity', 'พญ. ธิดารัตน์ สุขภาพจิต', 250.00, 4, 'พัฒนาตนเอง & จิตวิทยา', 'เคล็ดลับทางประสาทวิทยาในการกำจัดนิสัยผลัดวันประกันพรุ่งและโฟกัสกับงานสำคัญอย่างเด็ดขาด', 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&q=80&w=600', '#'),
(6, 'คู่มือวางแผนภาษีและการลงทุนฉบับประชาชน', 'ชัชวาล เศรษฐศาสตร์', 290.00, 5, 'การเงิน & การลงทุน', 'เข้าใจการลดหย่อนภาษีอย่างถูกต้อง พร้อมกลยุทธ์สร้างอิสรภาพทางการเงินผ่านกองทุนรวมและหุ้นปันผล', 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&q=80&w=600', '#'),
(7, 'Full-Stack Web Development with Python & Modern Stack', 'อาจารย์ พรชัย เทคโนโลยี', 420.00, 6, 'เทคโนโลยี & การเขียนโปรแกรม', 'สร้างเว็บแอปพลิเคชันระดับโปรดักชันด้วย Flask, RESTful API และฐานข้อมูล พร้อมการทำ Deployment', 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&q=80&w=600', '#'),
(8, 'Mastering Database Design & SQL', 'ดร. กิตติพงษ์ วิริยะกุล', 299.00, 6, 'เทคโนโลยี & การเขียนโปรแกรม', 'เจาะลึกการออกแบบฐานข้อมูลเชิงสัมพันธ์ตั้งแต่ระดับพื้นฐาน Normalization 3NF จนถึงการ Optimize Query', 'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&q=80&w=600', '#')
ON CONFLICT (ebook_id) DO UPDATE SET 
    title = EXCLUDED.title,
    author_name = EXCLUDED.author_name,
    price = EXCLUDED.price,
    category_id = EXCLUDED.category_id,
    category_name = EXCLUDED.category_name,
    description = EXCLUDED.description,
    cover_image = EXCLUDED.cover_image;

-- อัปเดต Sequence ID สำหรับ ebooks และ categories ให้ถูกต้อง
SELECT setval('public.ebooks_ebook_id_seq', (SELECT MAX(ebook_id) FROM public.ebooks));
SELECT setval('public.categories_category_id_seq', (SELECT MAX(category_id) FROM public.categories));
