-- ====================================================================
-- ⚡ เปิดใช้งาน Supabase Realtime ให้ครบทุกตาราง
-- เพื่อให้เมื่อแก้ไขข้อมูลใน Table Editor (เช่น แก้ชื่อ, แก้ราคา, เปลี่ยนสถานะ)
-- หน้าเว็บ bookcool จะอัปเดตและแสดงผลสดๆ ทันทีโดยไม่ต้องกดรีเฟรช!
-- ====================================================================

DO $$
DECLARE
    tbl text;
    tables text[] := ARRAY['ebooks', 'categories', 'orders', 'order_items', 'book_reviews', 'user_library', 'cart_items', 'users', 'profiles'];
BEGIN
    FOREACH tbl IN ARRAY tables LOOP
        BEGIN
            EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE public.%I;', tbl);
        EXCEPTION 
            WHEN duplicate_object THEN
                -- ตารางนี้เปิด Realtime ไว้อยู่แล้ว ให้ข้ามได้
                NULL;
            WHEN OTHERS THEN
                -- กรณีอื่นๆ ให้ข้ามเพื่อไม่ให้สคริปต์หยุดทำงาน
                NULL;
        END;
    END LOOP;
END $$;
