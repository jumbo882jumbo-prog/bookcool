-- ====================================================================
-- ⚡ ปลดล็อกสิทธิ์ (RLS Policies) และเพิ่มข้อมูลตัวอย่างให้ครบทุกตาราง
-- สำหรับให้หน้าเว็บ bookcool เชื่อมต่อกับ Supabase ได้แบบ Real-Time 100%
-- ====================================================================

-- 1. ปลดล็อกสิทธิ์ให้หน้าเว็บ (Anon Role) สามารถอ่าน-เขียนคำสั่งซื้อได้
DROP POLICY IF EXISTS "Anon can do all on orders" ON public.orders;
CREATE POLICY "Anon can do all on orders" ON public.orders FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on order_items" ON public.order_items;
CREATE POLICY "Anon can do all on order_items" ON public.order_items FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on book_reviews" ON public.book_reviews;
CREATE POLICY "Anon can do all on book_reviews" ON public.book_reviews FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on user_library" ON public.user_library;
CREATE POLICY "Anon can do all on user_library" ON public.user_library FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on cart_items" ON public.cart_items;
CREATE POLICY "Anon can do all on cart_items" ON public.cart_items FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on profiles" ON public.profiles;
CREATE POLICY "Anon can do all on profiles" ON public.profiles FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Anon can do all on ebooks" ON public.ebooks;
CREATE POLICY "Anon can do all on ebooks" ON public.ebooks FOR ALL USING (true) WITH CHECK (true);

-- 2. เพิ่มข้อมูลคำสั่งซื้อตัวอย่างลงในตาราง orders
INSERT INTO public.orders (order_id, customer_name, customer_email, customer_username, total_amount, status, payment_method)
VALUES 
('ORD-2026-001', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 320.00, 'approved', 'bank_transfer'),
('ORD-2026-002', 'วรรณิศา รัตนโชติ', 'wannisa@example.com', 'wannisa', 490.00, 'pending', 'bank_transfer')
ON CONFLICT (order_id) DO UPDATE SET 
    status = EXCLUDED.status,
    customer_name = EXCLUDED.customer_name;

-- 3. เพิ่มรายการหนังสือในบิลลงในตาราง order_items
INSERT INTO public.order_items (order_id, ebook_id, book_title, price, quantity)
VALUES 
('ORD-2026-001', 1, 'Lean Startup & Product Strategy', 320.00, 1),
('ORD-2026-002', 3, 'Practical Generative AI for Developers', 490.00, 1)
ON CONFLICT DO NOTHING;

-- 4. เพิ่มข้อมูลลงในตาราง user_library (คลังหนังสือที่ซื้อแล้ว)
INSERT INTO public.user_library (user_id, ebook_id, order_id, access_type)
SELECT 
    COALESCE((SELECT id FROM public.profiles LIMIT 1), '00000000-0000-0000-0000-000000000000'::uuid),
    1,
    'ORD-2026-001',
    'purchased'
ON CONFLICT DO NOTHING;

-- 5. เพิ่มตัวอย่างรีวิวลงในตาราง book_reviews
INSERT INTO public.book_reviews (ebook_id, rating, comment)
VALUES 
(1, 5, 'หนังสือเล่มนี้เนื้อหาเข้าใจง่ายมาก อธิบายกระบวนการทำ MVP ได้เห็นภาพชัดเจน'),
(3, 5, 'เนื้อหา AI ทันสมัย โค้ดตัวอย่างนำไปต่อยอด RAG และ Agent ได้จริงครับ แนะนำมาก'),
(6, 4, 'คู่มือภาษีอ่านเข้าใจง่าย ช่วยประหยัดเงินได้เยอะเลย')
ON CONFLICT DO NOTHING;
