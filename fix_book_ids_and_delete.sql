-- ====================================================================
-- 🛠️ สคริปต์แก้ปัญหา: ลบหนังสือไม่ได้ + เลข ID ไม่เรียงต่อกัน (Bookcool)
-- ====================================================================
-- วิธีใช้: คัดลอกคำสั่งทั้งหมดนี้ไปวางใน Supabase -> SQL Editor แล้วกด "RUN"
-- ====================================================================

-- 1. ปลดล็อก Foreign Key ของ order_items ให้เป็น ON DELETE SET NULL
--    (เพื่อแก้ปัญหาลบหนังสือไม่ได้ หากหนังสือนั้นเคยมีประวัติการสั่งซื้อจำลอง)
ALTER TABLE public.order_items 
DROP CONSTRAINT IF EXISTS order_items_ebook_id_fkey;

ALTER TABLE public.order_items 
ADD CONSTRAINT order_items_ebook_id_fkey 
FOREIGN KEY (ebook_id) 
REFERENCES public.ebooks(ebook_id) 
ON DELETE SET NULL;

-- 2. ปลดล็อก Policy (RLS) ตาราง ebooks ให้สิทธิ์ลบและแก้ไขทำงานได้อย่างสมบูรณ์
ALTER TABLE public.ebooks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anon can do all on ebooks" ON public.ebooks;
CREATE POLICY "Anon can do all on ebooks" ON public.ebooks FOR ALL USING (true) WITH CHECK (true);

-- 3. หากมีหนังสือทดสอบ #10 ค้างอยู่ และต้องการลบออกให้หมดจด:
DELETE FROM public.order_items WHERE ebook_id = 10;
DELETE FROM public.cart_items WHERE ebook_id = 10;
DELETE FROM public.user_library WHERE ebook_id = 10;
DELETE FROM public.book_reviews WHERE ebook_id = 10;
DELETE FROM public.ebooks WHERE ebook_id = 10;

-- 4. รีเซ็ต Sequence ของ ebooks ให้นับต่อจาก ID สูงสุดปัจจุบัน (ปัจจุบันคือ 8)
--    เมื่อเพิ่มหนังสือเล่มถัดไป รหัสจะรันเป็น #9 ทันที! (ไม่มีเลขกระโดดข้าม)
SELECT setval('public.ebooks_ebook_id_seq', (SELECT COALESCE(MAX(ebook_id), 8) FROM public.ebooks));

-- 5. ตรวจสอบผลลัพธ์
SELECT ebook_id, title, price, is_published FROM public.ebooks ORDER BY ebook_id ASC;
