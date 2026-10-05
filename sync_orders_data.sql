-- ====================================================================
-- 📦 ซิงก์ข้อมูล Orders & Order Items ใน Supabase ให้ตรงกับหน้าเว็บ 100%
-- รันคำสั่งนี้เพื่อให้ผลลัพธ์คำสั่ง Query ใน Supabase ตรงกับหน้าเว็บเป๊ะๆ
-- ====================================================================

-- 1. ล้างข้อมูลเก่าใน orders และ order_items เพื่อตั้งค่าใหม่ให้ตรงกัน
TRUNCATE TABLE public.order_items CASCADE;
TRUNCATE TABLE public.orders CASCADE;

-- 2. เพิ่มคำสั่งซื้อ (Orders)
INSERT INTO public.orders (order_id, customer_name, customer_email, customer_username, total_amount, status, order_date, payment_method)
VALUES 
('ORD-2026-001', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 975.00, 'approved', '2026-10-01 10:00:00+07', 'bank_transfer'),
('ORD-2026-002', 'กัญญา 3D', 'kanya@example.com', 'kanya', 840.00, 'approved', '2026-10-01 11:30:00+07', 'bank_transfer'),
('ORD-2026-003', 'ณัฐวุฒิ นักพัฒนา', 'nuttawut@example.com', 'nuttawut', 320.00, 'approved', '2026-10-01 12:15:00+07', 'bank_transfer'),
('ORD-2026-004', 'ธนากร ธุรกิจ', 'thanakorn@example.com', 'thanakorn', 250.00, 'approved', '2026-10-01 14:00:00+07', 'bank_transfer'),
('ORD-2026-005', 'วิชัย ไอที', 'wichai@example.com', 'wichai', 299.00, 'approved', '2026-10-01 15:20:00+07', 'bank_transfer'),
('ORD-2026-006', 'ปรียา การเงิน', 'preeya@example.com', 'preeya', 280.00, 'approved', '2026-10-01 16:45:00+07', 'bank_transfer'),
('ORD-2026-007', 'ศิริพร อ่านเพลิน', 'siriporn@example.com', 'siriporn', 300.00, 'approved', '2026-10-01 17:10:00+07', 'bank_transfer'),
('ORD-2026-008', 'อนุชา สถาปัตย์', 'anucha@example.com', 'anucha', 450.00, 'approved', '2026-10-01 18:00:00+07', 'bank_transfer'),
('ORD-2026-009', 'กวี ศรีสยาม', 'kawee@example.com', 'kawee', 195.00, 'approved', '2026-10-01 19:00:00+07', 'bank_transfer'),
('ORD-2026-010', 'มณีรัตน์ วรรณศิลป์', 'manee@example.com', 'manee', 195.00, 'approved', '2026-10-01 20:00:00+07', 'bank_transfer'),
('ORD-2026-011', 'สมศักดิ์ นิยาย', 'somsak@example.com', 'somsak', 195.00, 'approved', '2026-10-01 21:00:00+07', 'bank_transfer'),
('ORD-2026-012', 'อาจารย์ พรชัย', 'pornchai@example.com', 'pornchai', 420.00, 'approved', '2026-10-01 22:00:00+07', 'bank_transfer');

-- 3. เพิ่มรายการหนังสือในคำสั่งซื้อ (Order Items) พร้อมผูก category_id ให้ครบถ้วน
INSERT INTO public.order_items (order_id, ebook_id, category_id, book_title, price, quantity)
VALUES 
-- 1. กำเนิดจักรกลนิรันดร์: ขาย 5 เล่ม | ยอด 975.00 | 5 orders (category_id = 2)
('ORD-2026-001', 2, 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),
('ORD-2026-009', 2, 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),
('ORD-2026-010', 2, 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),
('ORD-2026-011', 2, 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),
('ORD-2026-007', 2, 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- 2. Full-Stack Web Development: ขาย 2 เล่ม | ยอด 840.00 | 2 orders (category_id = 6)
('ORD-2026-002', 7, 6, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),
('ORD-2026-012', 7, 6, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- 3. Lean Startup: ขาย 1 เล่ม | ยอด 320.00 | 1 order (category_id = 1)
('ORD-2026-003', 1, 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- 4. จิตวิทยาการบริหารเวลา: ขาย 1 เล่ม | ยอด 250.00 | 1 order (category_id = 4)
('ORD-2026-004', 5, 4, 'จิตวิทยาการบริหารเวลา Focus & Productivity', 250.00, 1),

-- 5. Mastering Database Design & SQL: ขาย 1 เล่ม | ยอด 299.00 | 1 order (category_id = 6)
('ORD-2026-005', 8, 6, 'Mastering Database Design & SQL', 299.00, 1),

-- 6. จิตวิทยาการเจรจาต่อรองให้ชนะทุกสโคป: ขาย 1 เล่ม | ยอด 280.00 | 1 order (category_id = 1)
('ORD-2026-006', 4, 1, 'จิตวิทยาการเจรจาต่อรองให้ชนะทุกสโคป', 280.00, 1),

-- 7. ถอดรหัสวิญญาณแห่งดวงดาว: ขาย 1 เล่ม | ยอด 300.00 | 1 order (category_id = 2)
('ORD-2026-007', 2, 2, 'ถอดรหัสวิญญาณแห่งดวงดาว', 300.00, 1),

-- 8. Clean Architecture & Design Patterns: ขาย 1 เล่ม | ยอด 450.00 | 1 order (category_id = 6)
('ORD-2026-008', 4, 6, 'Clean Architecture & Design Patterns', 450.00, 1);
