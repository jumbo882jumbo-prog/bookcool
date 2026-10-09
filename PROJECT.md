# 📚 โครงงาน Bookcool: E-Book Store Management System

[![CI Test](https://github.com/jumbo882jumbo-prog/bookcool/actions/workflows/ci.yml/badge.svg)](https://github.com/jumbo882jumbo-prog/bookcool/actions/workflows/ci.yml)
[![Repository](https://img.shields.io/badge/GitHub-Repository-blue.svg)](https://github.com/jumbo882jumbo-prog/bookcool)
[![Tests Passed](https://img.shields.io/badge/Tests-8%20Passed%20(100%25)-success.svg)](docs/CI_TEST_RESULTS.md)
[![Accessibility](https://img.shields.io/badge/Accessibility-96%2F100-emerald.svg)](docs/UX_PERSONA_WIREFRAME_ACCESSIBILITY.md#3-ผลตรวจความสามารถในการเข้าถึง-accessibility-audit)

> **ยินดีต้อนรับอาจารย์ผู้สอนและผู้ตรวจประเมินโครงงาน**  
> เอกสารฉบับนี้เป็นสารบัญหลัก (Master Hub) สำหรับตรวจประเมินผลงานโครงงานระบบร้านขาย E-Book (Bookcool)  
> อาจารย์สามารถคลิกลิงก์ในตารางสารบัญด้านล่างนี้ เพื่อเข้าดูเอกสารและหลักฐานการทำงานในแต่ละหัวข้อได้โดยตรงทันทีครับ 👇

---

## 📌 สารบัญการตรวจประเมินโครงงาน (Evaluation Quick Links)

| ลำดับ | หัวข้อที่ตรวจประเมิน | ลิงก์เข้าสู่เอกสารฉบับเต็ม | สรุปสาระสำคัญ |
| :---: | :--- | :--- | :--- |
| **1** | **spec ของระบบ** | 🔗 [docs/SPECIFICATION.md](docs/SPECIFICATION.md)<br>*(และ [SYSTEM_STRUCTURE.md](SYSTEM_STRUCTURE.md))* | • ขอบเขตและสิทธิ์ผู้ใช้งาน (Guest, Customer, Admin)<br>• ข้อกำหนดเชิงฟังก์ชัน 10 หัวข้อ (FR-01 ถึง FR-10)<br>• ข้อกำหนดคุณภาพ (NFR: Security, Performance, WCAG)<br>• รายละเอียด API Routes ทั้งหมดในระบบ |
| **2** | **class diagram หรือ sequence diagram** | 🔗 [docs/DIAGRAMS.md](docs/DIAGRAMS.md) | • **Class Diagram:** คลาส User, Customer, Admin, EBook, Cart, Order, Review แบบ Mermaid<br>• **Sequence Diagram 1:** การสั่งซื้อและแนบสลิป (Purchase Flow)<br>• **Sequence Diagram 2:** แอดมินตรวจสลิปและปลดล็อกดาวน์โหลด<br>• **Sequence Diagram 3:** ระบบล็อกอินและ Guard ควบคุมสิทธิ์ |
| **3** | **งานฝั่งผู้ใช้: persona, wireframe และผลตรวจ accessibility** | 🔗 [docs/UX_PERSONA_WIREFRAME_ACCESSIBILITY.md](docs/UX_PERSONA_WIREFRAME_ACCESSIBILITY.md) | • **Persona 3 กลุ่ม:** พนักงานออฟฟิศ, นักศึกษา, ผู้ดูแลร้าน<br>• **Wireframe ครบวงจร:** หน้าแรก, ตะกร้า, ชำระเงิน, คลังหนังสือ, หน้าแอดมิน<br>• **ผลตรวจ Accessibility:** คะแนน Lighthouse 96/100 และ Checklist ผ่านเกณฑ์ WCAG 2.1 Level AA |
| **4** | **test อัตโนมัติ และหน้าผลการรัน CI** | 🔗 [docs/CI_TEST_RESULTS.md](docs/CI_TEST_RESULTS.md)<br>*(และ [.github/workflows/ci.yml](.github/workflows/ci.yml))* | • **ชุดทดสอบอัตโนมัติ:** [tests/test_app.py](tests/test_app.py) ผ่าน 100% (8/8 tests, 0.086s)<br>• **CI Pipeline:** ทำงานอัตโนมัติด้วย GitHub Actions บน Ubuntu<br>• **หน้าผลรัน CI บน GitHub:** [👉 GitHub Actions Run Page](https://github.com/jumbo882jumbo-prog/bookcool/actions) |
| **5** | **บันทึกการใช้ AI** | 🔗 [docs/AI_USAGE_LOG.md](docs/AI_USAGE_LOG.md) | • บันทึก Prompt และการโต้ตอบกับ AI 5 ขั้นตอนสำคัญ<br>• รายละเอียดการตรวจสอบและปรับแก้โค้ดโดยมนุษย์<br>• คำรับรองความโปร่งใสและจริยธรรมตามหลักวิชาการ |

---

## 📖 สรุปเนื้อหาแต่ละหัวข้อโดยย่อ (Summary Highlights)

### 1. 📋 spec ของระบบ (System Specification)
* **ลิงก์เอกสาร:** [docs/SPECIFICATION.md](docs/SPECIFICATION.md)
* **เป้าหมายระบบ:** แพลตฟอร์มจำหน่าย E-Book แบบดิจิทัลครบวงจร พร้อมระบบรักษาความปลอดภัยและการวิเคราะห์ข้อมูล
* **สิทธิ์ผู้ใช้ (RBAC):**
  - **Guest:** ค้นหา ดูแคตตาล็อก เรื่องย่อ รีวิว และหยิบใส่ตะกร้า
  - **Customer:** สั่งซื้อ แนบสลิปโอนเงิน (PromptPay Mock) และดาวน์โหลด E-Book เฉพาะเล่มที่อนุมัติแล้ว
  - **Admin:** ตรวจสอบสลิป อนุมัติบิล จัดการหนังสือ ดู Analytics Dashboard และรัน SQL Queries
* **เงื่อนไขความปลอดภัยสำคัญ:** ปลดล็อกสิทธิ์ดาวน์โหลดไฟล์ E-Book ให้เฉพาะคำสั่งซื้อที่มีสถานะ `approved` เท่านั้น หากยังเป็น `pending` หรือถูกยกเลิก ระบบจะล็อกการเข้าถึงไฟล์

---

### 2. 📐 Class Diagram และ Sequence Diagrams
* **ลิงก์เอกสาร:** [docs/DIAGRAMS.md](docs/DIAGRAMS.md)
* **เครื่องมือ:** จัดทำด้วย **Mermaid Markdown** เพื่อความคมชัดและสามารถเรนเดอร์ได้โดยตรงบน GitHub
* **เนื้อหาสำคัญ:**
  - **Class Diagram:** ความสัมพันธ์ระหว่าง `User` (Parent) กับ `Customer` / `Admin` (Children), `Cart` กับ `CartItem`, และ `Order` กับ `OrderItem` & `PaymentSlip`
  - **Purchase Sequence:** ลำดับการส่งข้อมูลจากหน้าร้านค้าสู่ `CartManager` -> `checkout.html` -> สร้าง Record คำสั่งซื้อสถานะ `pending` -> ล้างตะกร้า
  - **Verification & Unlock Sequence:** แอดมินตรวจสอบสลิปใน `admin.html` -> อนุมัติบิล -> สถานะเปลี่ยนเป็น `approved` -> หน้า `my-books.html` ปลดล็อกปุ่มดาวน์โหลดไฟล์ทันทีแบบเรียลไทม์

---

### 3. 🎨 งานฝั่งผู้ใช้: Persona, Wireframe และผลตรวจ Accessibility
* **ลิงก์เอกสาร:** [docs/UX_PERSONA_WIREFRAME_ACCESSIBILITY.md](docs/UX_PERSONA_WIREFRAME_ACCESSIBILITY.md)
* **User Personas:**
  1. *นายสมชาย (วัยทำงาน):* ต้องการซื้อ E-Book ธุรกิจ/AI จ่ายผ่าน QR รวดเร็ว และดาวน์โหลดไฟล์ได้ทันทีหลังอนุมัติ
  2. *น.ส. กัญญาภัทร (นักศึกษา):* งบจำกัด ชอบกรองหนังสือตามหมวดหมู่ เรียงตามราคา และอ่านรีวิวก่อนซื้อ
  3. *นายอาทิตย์ (แอดมิน):* ต้องการตรวจสลิปโอนเงินรวดเร็ว กดยืนยันในคลิกเดียว และดูสรุปยอดขายบน Dashboard
* **Wireframes:** โครงร่างหน้าจอ Text/ASCII Layout แสดงตำแหน่งองค์ประกอบชัดเจนทั้ง 5 หน้าจอหลัก
* **Accessibility Audit:**
  - ผลคะแนน Google Lighthouse Accessibility: **96 / 100**
  - ผ่านเกณฑ์ **WCAG 2.1 Level AA**: มี `alt` text ครบทุกรูป, Contrast Ratio เกิน 4.5:1, รองรับ Keyboard Navigation (`Tab`, `Enter`, `Esc`), มี `<label>` ครบทุก Form Control และระบุ `lang="th"`

---

### 4. 🧪 Test อัตโนมัติ และหน้าผลการรัน CI
* **ลิงก์เอกสาร:** [docs/CI_TEST_RESULTS.md](docs/CI_TEST_RESULTS.md)
* **ไฟล์ชุดทดสอบ:** [tests/test_app.py](tests/test_app.py)
* **ผลการรันชุดทดสอบ:**
  - ผ่านการทดสอบทั้งหมด **8 จาก 8 กรณีทดสอบ (100% Passed)**
  - ครอบคลุม: การโหลดหน้าเว็บทั้ง 10 หน้า, ระบบค้นหา Instant Search, การกรองหมวดหมู่, REST API `GET` และ `POST /api/books`, การ Validate ข้อมูลนำเข้า, และความสมบูรณ์ของ Seed Database
* **GitHub Actions CI Workflow:**
  - ไฟล์คอนฟิก: [.github/workflows/ci.yml](.github/workflows/ci.yml)
  - ทำงานอัตโนมัติทุกครั้งที่มี Commit ใหม่บนกิ่ง `main`
  - ลิงก์หน้าผลการรัน CI สด: [👉 หน้าแสดงผลการรัน GitHub Actions CI](https://github.com/jumbo882jumbo-prog/bookcool/actions)

---

### 5. 🤖 บันทึกการใช้ AI (AI Usage Log)
* **ลิงก์เอกสาร:** [docs/AI_USAGE_LOG.md](docs/AI_USAGE_LOG.md)
* **เครื่องมือ:** Antigravity IDE (Gemini 3.8 Flash / Claude 3.5 Sonnet) และ LLM Engine
* **บันทึก Prompt และบทบาท:**
  - ปรึกษาและออกแบบสถาปัตยกรรมฐานข้อมูล 5 ตารางตามกฎ 3NF
  - ปรึกษาการออกแบบ Sequence Flow สำหรับระบบ Real-time Custom Events
  - สร้างชุดทดสอบอัตโนมัติ Unit Tests และ CI Workflow
  - ประเมินเกณฑ์ความสามารถในการเข้าถึง (WCAG 2.1 AA Checklist)
* **การตรวจสอบโดยมนุษย์ (Human Validation):** ตรวจสอบและแก้ไขโค้ดทุกจุดด้วยตนเอง ทดสอบการทำงานจริง และป้องกันช่องโหว่ด้านความปลอดภัยในการเข้าถึงไฟล์ดิจิทัล

---

## 🛠️ โครงสร้างไฟล์ทั้งหมดในโปรเจกต์ (Repository Directory Structure)

```text
bookcool/
├── .github/
│   └── workflows/
│       └── ci.yml                          <- CI Workflow สำหรับรันเทสอัตโนมัติบน GitHub
├── docs/
│   ├── SPECIFICATION.md                    <- 1. spec ของระบบ
│   ├── DIAGRAMS.md                         <- 2. class diagram และ sequence diagram
│   ├── UX_PERSONA_WIREFRAME_ACCESSIBILITY.md <- 3. persona, wireframe และผลตรวจ accessibility
│   ├── CI_TEST_RESULTS.md                  <- 4. รายละเอียดผลการรันเทสอัตโนมัติ และ CI
│   └── AI_USAGE_LOG.md                     <- 5. บันทึกการใช้ AI
├── tests/
│   └── test_app.py                         <- ชุดทดสอบอัตโนมัติ (Python unittest)
├── PROJECT.md                              <- ศูนย์รวมการตรวจประเมินโครงงาน (ไฟล์นี้)
├── SYSTEM_STRUCTURE.md                     <- เอกสารอธิบายโครงสร้างระบบและ Data Flow
├── MINI_PROJECT_DATABASE_REPORT.md         <- เล่มรายงานโครงงานฉบับสมบูรณ์
├── project-report.html                     <- หน้าเอกสารรายงานแบบเว็บสำหรับสั่งพิมพ์
├── index.html                              <- หน้าร้านค้าหลัก
├── book-detail.html                        <- หน้ารายละเอียดหนังสือ
├── cart.html                               <- หน้าตะกร้าสินค้า
├── checkout.html                           <- หน้าชำระเงินและแนบสลิป
├── my-books.html                           <- หน้าคลังหนังสือส่วนตัวและดาวน์โหลด
├── login.html                              <- หน้าเข้าสู่ระบบและสมัครสมาชิก
├── admin.html                              <- หน้าผู้ดูแลระบบอนุมัติคำสั่งซื้อ
├── reports.html                            <- หน้าแดชบอร์ดสรุปยอดขาย 4 มิติ
├── sql-console.html                        <- หน้ารันคำสั่ง SQL Query
├── reviews.html                            <- หน้ารีวิวหนังสือ
├── app.py                                  <- Flask Web Application & REST API
├── auth.js                                 <- ระบบจัดการสิทธิ์ผู้ใช้งาน (RBAC)
├── supabase-browser.js                     <- ไลบรารีเชื่อมต่อ Supabase Database
└── requirements.txt                        <- รายการไลบรารีภาษา Python
```

---

## 💻 วิธีการรันโปรเจกต์ในเครื่อง (Quick Start Guide)

```bash
# 1. ติดตั้ง Dependencies
pip install -r requirements.txt

# 2. รันการทดสอบอัตโนมัติ (Automated Tests)
python -m unittest discover -s tests -v

# 3. เริ่มต้นรันเซิร์ฟเวอร์
python app.py
# เปิดเว็บบราวเซอร์ไปที่: http://localhost:5000
```
