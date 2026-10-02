-- ====================================================================
-- 📦 SEED DATA: 35 ORDERS & ORDER ITEMS FOR BOOKCOOL DATABASE
-- ====================================================================
-- สคริปต์เติมข้อมูลคำสั่งซื้อตัวอย่าง 35 รายการ (ผ่านเกณฑ์ขั้นต่ำ 30 คำสั่งซื้อ)
-- ครอบคลุมหลากหลายลูกค้า, ช่วงเวลา (25 ก.ย. 2026 - 2 ต.ค. 2026),
-- สถานะคำสั่งซื้อ (approved, pending, cancelled) และมีสินค้าหลากหลายเล่ม
-- สามารถรันใน Supabase SQL Editor ได้ทันที!
-- ====================================================================

-- 1. ล้างข้อมูล orders และ order_items เดิมเพื่อสร้างชุดข้อมูลใหม่อย่างแม่นยำ
TRUNCATE TABLE public.order_items CASCADE;
TRUNCATE TABLE public.orders CASCADE;

-- 2. เติมข้อมูลคำสั่งซื้อ 35 บิล (Orders)
INSERT INTO public.orders (order_id, customer_name, customer_email, customer_username, total_amount, status, order_date, payment_method)
VALUES 
-- วันที่ 25 ก.ย. 2026
('ORD-2026-001', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 515.00, 'approved', '2026-09-25 09:30:00+07', 'bank_transfer'),
('ORD-2026-002', 'กัญญา 3D', 'kanya@example.com', 'kanya', 420.00, 'approved', '2026-09-25 11:15:00+07', 'promptpay'),
('ORD-2026-003', 'ณัฐวุฒิ นักพัฒนา', 'nuttawut@example.com', 'nuttawut', 320.00, 'approved', '2026-09-25 14:00:00+07', 'bank_transfer'),
('ORD-2026-004', 'ธนากร ธุรกิจ', 'thanakorn@example.com', 'thanakorn', 250.00, 'approved', '2026-09-25 16:45:00+07', 'promptpay'),

-- วันที่ 26 ก.ย. 2026
('ORD-2026-005', 'วิชัย ไอที', 'wichai@example.com', 'wichai', 710.00, 'approved', '2026-09-26 10:10:00+07', 'bank_transfer'),
('ORD-2026-006', 'ปรียา การเงิน', 'preeya@example.com', 'preeya', 280.00, 'approved', '2026-09-26 13:20:00+07', 'promptpay'),
('ORD-2026-007', 'ศิริพร อ่านเพลิน', 'siriporn@example.com', 'siriporn', 195.00, 'approved', '2026-09-26 15:30:00+07', 'bank_transfer'),
('ORD-2026-008', 'อนุชา สถาปัตย์', 'anucha@example.com', 'anucha', 350.00, 'approved', '2026-09-26 18:00:00+07', 'promptpay'),

-- วันที่ 27 ก.ย. 2026
('ORD-2026-009', 'กวี ศรีสยาม', 'kawee@example.com', 'kawee', 195.00, 'approved', '2026-09-27 09:00:00+07', 'bank_transfer'),
('ORD-2026-010', 'มณีรัตน์ วรรณศิลป์', 'manee@example.com', 'manee', 445.00, 'approved', '2026-09-27 11:40:00+07', 'promptpay'),
('ORD-2026-011', 'สมศักดิ์ นิยาย', 'somsak@example.com', 'somsak', 195.00, 'approved', '2026-09-27 14:15:00+07', 'bank_transfer'),
('ORD-2026-012', 'อาจารย์ พรชัย', 'pornchai@example.com', 'pornchai', 420.00, 'approved', '2026-09-27 17:00:00+07', 'bank_transfer'),

-- วันที่ 28 ก.ย. 2026
('ORD-2026-013', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 390.00, 'approved', '2026-09-28 10:25:00+07', 'promptpay'),
('ORD-2026-014', 'ชิดชนก ออกแบบ', 'chidchanok@example.com', 'chidchanok', 420.00, 'approved', '2026-09-28 12:50:00+07', 'bank_transfer'),
('ORD-2026-015', 'ภานุพงศ์ นักลงทุน', 'panupong@example.com', 'panupong', 570.00, 'approved', '2026-09-28 15:10:00+07', 'promptpay'),
('ORD-2026-016', 'กัญญา 3D', 'kanya@example.com', 'kanya', 320.00, 'approved', '2026-09-28 19:30:00+07', 'bank_transfer'),

-- วันที่ 29 ก.ย. 2026
('ORD-2026-017', 'ธนากร ธุรกิจ', 'thanakorn@example.com', 'thanakorn', 390.00, 'approved', '2026-09-29 08:45:00+07', 'bank_transfer'),
('ORD-2026-018', 'ศิริพร อ่านเพลิน', 'siriporn@example.com', 'siriporn', 515.00, 'approved', '2026-09-29 11:20:00+07', 'promptpay'),
('ORD-2026-019', 'วิชัย ไอที', 'wichai@example.com', 'wichai', 420.00, 'approved', '2026-09-29 14:40:00+07', 'bank_transfer'),
('ORD-2026-020', 'ปรียา การเงิน', 'preeya@example.com', 'preeya', 320.00, 'approved', '2026-09-29 17:15:00+07', 'promptpay'),

-- วันที่ 30 ก.ย. 2026
('ORD-2026-021', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 670.00, 'approved', '2026-09-30 09:15:00+07', 'bank_transfer'),
('ORD-2026-022', 'อนุชา สถาปัตย์', 'anucha@example.com', 'anucha', 250.00, 'approved', '2026-09-30 11:55:00+07', 'promptpay'),
('ORD-2026-023', 'ณัฐวุฒิ นักพัฒนา', 'nuttawut@example.com', 'nuttawut', 420.00, 'approved', '2026-09-30 14:30:00+07', 'bank_transfer'),
('ORD-2026-024', 'กวี ศรีสยาม', 'kawee@example.com', 'kawee', 390.00, 'approved', '2026-09-30 16:50:00+07', 'bank_transfer'),
('ORD-2026-025', 'มณีรัตน์ วรรณศิลป์', 'manee@example.com', 'manee', 195.00, 'approved', '2026-09-30 20:10:00+07', 'promptpay'),

-- วันที่ 1 ต.ค. 2026
('ORD-2026-026', 'สมชาย สมาชิกนักอ่าน', 'user@bookcool.com', 'user', 320.00, 'approved', '2026-10-01 09:40:00+07', 'bank_transfer'),
('ORD-2026-027', 'กัญญา 3D', 'kanya@example.com', 'kanya', 840.00, 'approved', '2026-10-01 11:30:00+07', 'bank_transfer'),
('ORD-2026-028', 'ภานุพงศ์ นักลงทุน', 'panupong@example.com', 'panupong', 280.00, 'approved', '2026-10-01 13:20:00+07', 'promptpay'),
('ORD-2026-029', 'ชิดชนก ออกแบบ', 'chidchanok@example.com', 'chidchanok', 195.00, 'approved', '2026-10-01 15:45:00+07', 'bank_transfer'),
('ORD-2026-030', 'อาจารย์ พรชัย', 'pornchai@example.com', 'pornchai', 670.00, 'approved', '2026-10-01 18:20:00+07', 'bank_transfer'),

-- วันที่ 2 ต.ค. 2026 (รวมสถานะ pending และ cancelled เพื่อทดสอบคุณภาพข้อมูล)
('ORD-2026-031', 'สมศักดิ์ นิยาย', 'somsak@example.com', 'somsak', 320.00, 'approved', '2026-10-02 08:30:00+07', 'bank_transfer'),
('ORD-2026-032', 'วิชัย ไอที', 'wichai@example.com', 'wichai', 420.00, 'approved', '2026-10-02 10:15:00+07', 'promptpay'),
('ORD-2026-033', 'ธนากร ธุรกิจ', 'thanakorn@example.com', 'thanakorn', 250.00, 'pending', '2026-10-02 11:00:00+07', 'bank_transfer'),
('ORD-2026-034', 'ปรียา การเงิน', 'preeya@example.com', 'preeya', 390.00, 'pending', '2026-10-02 11:45:00+07', 'promptpay'),
('ORD-2026-035', 'ศิริพร อ่านเพลิน', 'siriporn@example.com', 'siriporn', 195.00, 'cancelled', '2026-10-02 12:10:00+07', 'bank_transfer');

-- 3. เติมข้อมูลรายการหนังสือในคำสั่งซื้อ (Order Items: 48 รายการ)
INSERT INTO public.order_items (order_id, ebook_id, book_title, price, quantity)
VALUES 
-- ORD-001 (515 บ.)
('ORD-2026-001', 1, 'Lean Startup & Product Strategy', 320.00, 1),
('ORD-2026-001', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-002 (420 บ.)
('ORD-2026-002', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-003 (320 บ.)
('ORD-2026-003', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-004 (250 บ.)
('ORD-2026-004', 3, 'Mindset for Peak Performance', 250.00, 1),

-- ORD-005 (710 บ.)
('ORD-2026-005', 1, 'Lean Startup & Product Strategy', 320.00, 1),
('ORD-2026-005', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1),

-- ORD-006 (280 บ.)
('ORD-2026-006', 5, 'Financial Freedom Blueprint', 280.00, 1),

-- ORD-007 (195 บ.)
('ORD-2026-007', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-008 (350 บ.)
('ORD-2026-008', 6, 'Clean Architecture & System Design', 350.00, 1),

-- ORD-009 (195 บ.)
('ORD-2026-009', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-010 (445 บ.)
('ORD-2026-010', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),
('ORD-2026-010', 3, 'Mindset for Peak Performance', 250.00, 1),

-- ORD-011 (195 บ.)
('ORD-2026-011', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-012 (420 บ.)
('ORD-2026-012', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-013 (390 บ.)
('ORD-2026-013', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1),

-- ORD-014 (420 บ.)
('ORD-2026-014', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-015 (570 บ.)
('ORD-2026-015', 3, 'Mindset for Peak Performance', 250.00, 1),
('ORD-2026-015', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-016 (320 บ.)
('ORD-2026-016', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-017 (390 บ.)
('ORD-2026-017', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1),

-- ORD-018 (515 บ.)
('ORD-2026-018', 1, 'Lean Startup & Product Strategy', 320.00, 1),
('ORD-2026-018', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-019 (420 บ.)
('ORD-2026-019', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-020 (320 บ.)
('ORD-2026-020', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-021 (670 บ.)
('ORD-2026-021', 6, 'Clean Architecture & System Design', 350.00, 1),
('ORD-2026-021', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-022 (250 บ.)
('ORD-2026-022', 3, 'Mindset for Peak Performance', 250.00, 1),

-- ORD-023 (420 บ.)
('ORD-2026-023', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-024 (390 บ.)
('ORD-2026-024', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1),

-- ORD-025 (195 บ.)
('ORD-2026-025', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-026 (320 บ.)
('ORD-2026-026', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-027 (840 บ. - 2 เล่มเล่มละ 420)
('ORD-2026-027', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 2),

-- ORD-028 (280 บ.)
('ORD-2026-028', 5, 'Financial Freedom Blueprint', 280.00, 1),

-- ORD-029 (195 บ.)
('ORD-2026-029', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1),

-- ORD-030 (670 บ.)
('ORD-2026-030', 1, 'Lean Startup & Product Strategy', 320.00, 1),
('ORD-2026-030', 6, 'Clean Architecture & System Design', 350.00, 1),

-- ORD-031 (320 บ.)
('ORD-2026-031', 1, 'Lean Startup & Product Strategy', 320.00, 1),

-- ORD-032 (420 บ.)
('ORD-2026-032', 7, 'Full-Stack Web Development with Python & Modern Stack', 420.00, 1),

-- ORD-033 (250 บ. - pending)
('ORD-2026-033', 3, 'Mindset for Peak Performance', 250.00, 1),

-- ORD-034 (390 บ. - pending)
('ORD-2026-034', 4, 'The Modern Growth Hacking & Digital Marketing', 390.00, 1),

-- ORD-035 (195 บ. - cancelled)
('ORD-2026-035', 2, 'กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)', 195.00, 1);
