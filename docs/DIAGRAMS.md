# 📐 แผนผังระบบ (Class Diagram & Sequence Diagrams)

เอกสารฉบับนี้รวบรวมแผนผังเชิงโครงสร้างและพฤติกรรมการทำงานของระบบ **Bookcool E-Book Store** โดยใช้มาตรฐาน **Mermaid Diagram** เพื่อความชัดเจนในการวิเคราะห์และพัฒนา

---

## 📑 สารบัญ
1. [Class Diagram (แผนผังคลาสและความสัมพันธ์เชิงโครงสร้าง)](#1-class-diagram)
2. [Sequence Diagram 1: กระบวนการสั่งซื้อและแนบสลิปชำระเงิน (Purchase Flow)](#2-sequence-diagram-1-purchase-flow)
3. [Sequence Diagram 2: การตรวจสอบสลิปและปลดล็อกการดาวน์โหลด (Admin Verification & Unlock Flow)](#3-sequence-diagram-2-admin-verification--unlock-flow)
4. [Sequence Diagram 3: การพิสูจน์ตัวตนและการควบคุมสิทธิ์ (Authentication & Guard Flow)](#4-sequence-diagram-3-authentication--guard-flow)

---

## 1. Class Diagram

แผนผังคลาสแสดงถึงโครงสร้างข้อมูลเชิงวัตถุ ความสัมพันธ์แบบสืบทอด (Inheritance) ความสัมพันธ์แบบรวมกลุ่ม (Composition / Aggregation) และฟังก์ชันการทำงานหลัก:

```mermaid
classDiagram
    direction TB

    %% Abstract/Base User
    class User {
        +int userId
        +string username
        +string email
        +string passwordHash
        +string role
        +login(username, password) bool
        +logout() void
        +getProfile() object
    }

    class Customer {
        +list orderHistory
        +viewPurchasedBooks() list
        +downloadBook(bookId) string
    }

    class Admin {
        +verifySlip(orderId) bool
        +approveOrder(orderId) void
        +rejectOrder(orderId, reason) void
        +addBook(bookData) bool
        +viewReports() object
    }

    User <|-- Customer : Inherits
    User <|-- Admin : Inherits

    %% Book & Category
    class EBook {
        +int ebookId
        +string title
        +string authorName
        +float price
        +string categoryName
        +string coverImage
        +string description
        +string downloadUrl
        +bool isPublished
        +getDetails() object
        +isAvailable() bool
    }

    class Category {
        +int categoryId
        +string categoryName
        +int bookCount
        +getBooks() list
    }

    Category "1" -- "0..*" EBook : categorizes

    %% Cart System
    class Cart {
        +list items
        +addItem(ebookId, qty) void
        +removeItem(ebookId) void
        +updateQuantity(ebookId, qty) void
        +calculateTotal() float
        +clear() void
    }

    class CartItem {
        +int ebookId
        +string title
        +float price
        +int quantity
        +getSubtotal() float
    }

    Cart "1" *-- "0..*" CartItem : contains
    Customer "1" o-- "1" Cart : owns
    CartItem "0..*" --> "1" EBook : references

    %% Order & Payment System
    class Order {
        +string orderId
        +int customerId
        +string customerName
        +string customerEmail
        +float totalAmount
        +string status
        +string slipImage
        +datetime orderDate
        +addItem(item) void
        +markApproved() void
        +canDownload() bool
    }

    class OrderItem {
        +int itemId
        +string orderId
        +int ebookId
        +string bookTitle
        +float price
        +int quantity
        +getSubtotal() float
    }

    class PaymentSlip {
        +string slipDataUrl
        +datetime uploadTime
        +string verificationStatus
        +validateImage() bool
    }

    Customer "1" -- "0..*" Order : places
    Order "1" *-- "1..*" OrderItem : consists of
    OrderItem "0..*" --> "1" EBook : includes
    Order "1" *-- "1" PaymentSlip : contains evidence

    %% Review System
    class Review {
        +int reviewId
        +int ebookId
        +int userId
        +string authorName
        +int rating
        +string comment
        +datetime createdAt
        +submit() bool
    }

    EBook "1" -- "0..*" Review : receives
    User "1" -- "0..*" Review : writes
```

---

## 2. Sequence Diagram 1: Purchase Flow

แสดงขั้นตอนการเลือกซื้อหนังสือ การจัดการตะกร้าสินค้า การสร้างคำสั่งซื้อ และการอัปโหลดหลักฐานการโอนเงิน:

```mermaid
sequenceDiagram
    autonumber
    actor C as ลูกค้า (Customer)
    participant UI as หน้าร้าน (index.html / cart.html)
    participant Cart as CartManager (LocalStorage)
    participant Check as หน้าชำระเงิน (checkout.html)
    participant Order as OrderManager
    participant DB as Cloud DB (Supabase / Local)

    C->>UI: 1. เลือกหนังสือ & กด "🛒 ใส่ตะกร้า"
    UI->>Cart: 2. บันทึกรายการลง cart_items
    Cart-->>UI: 3. อัปเดตตัวนับบนไอคอนตะกร้า (Cart Badge)
    
    C->>UI: 4. เข้าหน้าตะกร้า & กด "ดำเนินการชำระเงิน"
    UI->>Check: 5. นำทางสู่หน้า checkout.html
    Check->>Cart: 6. ดึงข้อมูลสินค้าและยอดเงินรวม
    Cart-->>Check: 7. สรุปรายการคำสั่งซื้อ
    Check-->>C: 8. แสดงยอดเงินและ Mock PromptPay QR Code
    
    C->>Check: 9. กรอกชื่อ-อีเมล & แนบไฟล์รูปสลิป
    C->>Check: 10. กดปุ่ม "🚀 ส่งหลักฐานการชำระเงิน"
    Check->>Order: 11. createOrder(customerInfo, items, slip)
    Order->>DB: 12. INSERT INTO orders (status='pending')
    Order->>DB: 13. INSERT INTO order_items (order_id, ebook_id, ...)
    DB-->>Order: 14. บันทึกคำสั่งซื้อสำเร็จ (Order Created)
    Order->>Cart: 15. clearCart() (ล้างตะกร้าสินค้า)
    Order-->>Check: 16. ส่งสถานะความสำเร็จ + Broadcast Event
    Check-->>C: 17. แจ้งเตือนบิลสำเร็จ & นำทางไปหน้า my-books.html
```

---

## 3. Sequence Diagram 2: Admin Verification & Unlock Flow

แสดงกระบวนการที่ผู้ดูแลระบบตรวจสอบหลักฐานการโอนเงิน อนุมัติคำสั่งซื้อ และส่งผลให้ระบบปลดล็อกการดาวน์โหลด E-Book:

```mermaid
sequenceDiagram
    autonumber
    actor Admin as ผู้ดูแลระบบ (Admin)
    participant Dash as หน้าแอดมิน (admin.html)
    participant DB as Cloud DB (Supabase)
    participant Realtime as Realtime Engine / Storage
    actor User as ลูกค้า (Customer)
    participant MyLib as คลังหนังสือ (my-books.html)

    User->>MyLib: 1. เปิดดูคลังหนังสือของฉัน
    MyLib->>DB: 2. ดึงรายการคำสั่งซื้อของ User
    DB-->>MyLib: 3. พบ order สถานะ = 'pending'
    MyLib-->>User: 4. แสดงป้าย "⏳ รอตรวจสอบสลิป" (ล็อกปุ่มดาวน์โหลด)

    Admin->>Dash: 5. ล็อกอินเข้าหน้าแอดมิน (admin.html)
    Dash->>DB: 6. ดึงรายการคำสั่งซื้อทั้งหมด
    DB-->>Dash: 7. ส่งคืนรายการบิลสถานะ 'pending'
    Admin->>Dash: 8. คลิกดูภาพสลิปโอนเงิน (Slip Preview Modal)
    Dash-->>Admin: 9. แสดงภาพหลักฐานการโอนเงินขยายชัดเจน
    
    Admin->>Dash: 10. คลิกปุ่ม "✅ ยืนยันคำสั่งซื้อ" (Approve)
    Dash->>DB: 11. UPDATE orders SET status='approved' WHERE id=orderId
    DB-->>Dash: 12. อัปเดตสถานะในฐานข้อมูลสำเร็จ
    Dash->>Realtime: 13. ส่ง Event 'orderApproved' & Broadcast
    Realtime-->>MyLib: 14. แจ้งเตือนหน้า My Library อัปเดตสถานะสด
    
    MyLib-->>User: 15. สถานะเปลี่ยนเป็น 'อนุมัติแล้ว'
    MyLib-->>User: 16. ปลดล็อกปุ่ม "📥 ดาวน์โหลด E-Book" ทันที
    User->>MyLib: 17. คลิกปุ่มดาวน์โหลดไฟล์
    MyLib-->>User: 18. ส่งมอบไฟล์ E-Book ดิจิทัลสำเร็จ
```

---

## 4. Sequence Diagram 3: Authentication & Guard Flow

แสดงขั้นตอนการเข้าสู่ระบบ การตรวจสอบข้อมูล และการควบคุมสิทธิ์ตามบทบาท (RBAC Guard):

```mermaid
sequenceDiagram
    autonumber
    actor U as ผู้ใช้งาน (User / Admin)
    participant Log as หน้าล็อกอิน (login.html)
    participant Auth as AuthManager (auth.js)
    participant DB as ฐานข้อมูลผู้ใช้ (users)
    participant Target as หน้าปลายทาง (เช่น admin.html)

    U->>Log: 1. กรอก Username และ Password
    U->>Log: 2. กดปุ่ม "เข้าสู่ระบบ"
    Log->>Auth: 3. login(username, password)
    Auth->>DB: 4. SELECT * FROM users WHERE username=username
    DB-->>Auth: 5. คืนข้อมูลผู้ใช้และ role ('user' หรือ 'admin')
    
    alt ข้อมูลถูกต้อง (Valid Credentials)
        Auth->>Auth: 6. บันทึก Session ลง LocalStorage ('currentUser')
        Auth-->>Log: 7. ส่งสถานะ Login Success
        Log-->>U: 8. แสดงข้อความต้อนรับ & Redirect
    else ข้อมูลไม่ถูกต้อง (Invalid Credentials)
        Auth-->>Log: 9. ส่งข้อความ Error "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง"
        Log-->>U: 10. แสดงแจ้งเตือนบนหน้าจอ
    end

    U->>Target: 11. พยายามเปิดหน้าเฉพาะผู้ดูแล (admin.html)
    Target->>Auth: 12. checkAdminGuard()
    alt สิทธิ์เป็น Admin (role === 'admin')
        Auth-->>Target: 13. อนุญาตให้เข้าถึงเนื้อหา (Access Granted)
        Target-->>U: 14. โหลด Dashboard ผู้ดูแลระบบ
    else สิทธิ์ไม่ใช่ Admin (role !== 'admin')
        Auth-->>Target: 15. ปฏิเสธการเข้าถึง (Access Denied)
        Target-->>U: 16. แจ้งเตือนสิทธิ์ไม่เพียงพอ & Redirect กลับ index.html
    end
```
