# 🧪 การทดสอบอัตโนมัติและผลการรัน CI (Automated Testing & CI Pipeline Results)

> **สถานะ CI:** [![CI Test](https://github.com/jumbo882jumbo-prog/bookcool/actions/workflows/ci.yml/badge.svg)](https://github.com/jumbo882jumbo-prog/bookcool/actions/workflows/ci.yml)  
> **หน้าผลการรัน CI บน GitHub Actions:** [👉 ดูผลการรันจริงบน GitHub Actions Run Page](https://github.com/jumbo882jumbo-prog/bookcool/actions)  
> **ไฟล์ตั้งค่า CI Pipeline:** [.github/workflows/ci.yml](file:///.github/workflows/ci.yml)  
> **ชุดไฟล์ทดสอบอัตโนมัติ:** [tests/test_app.py](file:///tests/test_app.py)  

---

## 📑 สารบัญ
1. [ภาพรวมของระบบทดสอบอัตโนมัติ (Automated Testing Overview)](#1-ภาพรวมของระบบทดสอบอัตโนมัติ)
2. [ผลการรันการทดสอบในเครื่องและบน CI (Test Run Results)](#2-ผลการรันการทดสอบ)
3. [ตารางรายการกรณีทดสอบ (Test Cases Matrix)](#3-ตารางรายการกรณีทดสอบ)
4. [โครงสร้างไปป์ไลน์ GitHub Actions CI (CI Pipeline Architecture)](#4-โครงสร้างไปป์ไลน์-github-actions-ci)
5. [วิธีการรันชุดทดสอบด้วยตัวเอง (How to Run Tests Locally)](#5-วิธีการรันชุดทดสอบด้วยตัวเอง)

---

## 1. ภาพรวมของระบบทดสอบอัตโนมัติ

โครงการ **Bookcool** จัดเตรียมชุดการทดสอบอัตโนมัติ (Automated Test Suite) ครอบคลุมทั้งระดับ **Unit Testing** และ **Integration Testing** โดยพัฒนาด้วย Python `unittest` Framework ซึ่งทดสอบ:
* ความพร้อมใช้งานของหน้าเว็บหลักทั้งหมด (Static & Dynamic Route Availability)
* ฟังก์ชันการสืบค้นข้อมูลหนังสือ (Catalog Search Engine)
* ฟังก์ชันการกรองข้อมูลตามหมวดหมู่ (Category Filtering)
* REST API Endpoint สำหรับดึงข้อมูลและเพิ่มหนังสือ (`GET /api/books` และ `POST /api/books`)
* ความสมบูรณ์และความถูกต้องของโครงสร้างข้อมูลหนังสือเริ่มต้น (Database Seed Integrity)

---

## 2. ผลการรันการทดสอบ (Test Run Results)

### สรุปผลการทดสอบ
* **จำนวนกรณีทดสอบทั้งหมด:** 8 Test Cases (17 Subtests)
* **สถานะการทดสอบ:** ✅ **PASSED 100% (0 Failures, 0 Errors)**
* **ระยะเวลาประมวลผล:** **0.086 วินาที**

### บันทึกผลการรันจริง (Terminal Execution Output)

```text
$ python -m unittest discover -s tests -v

test_01_index_page (test_app.BookcoolAppTestCase.test_01_index_page)
Test home / index page responds with status code 200 ... ok

test_02_static_pages_load_successfully (test_app.BookcoolAppTestCase.test_02_static_pages_load_successfully)
Test essential HTML pages are reachable ... ok

test_03_search_functionality (test_app.BookcoolAppTestCase.test_03_search_functionality)
Test search query filtering on index page ... ok

test_04_category_filter (test_app.BookcoolAppTestCase.test_04_category_filter)
Test category filtering on index page ... ok

test_05_api_get_books (test_app.BookcoolAppTestCase.test_05_api_get_books)
Test REST API endpoint GET /api/books returns valid list of books ... ok

test_06_api_post_new_book (test_app.BookcoolAppTestCase.test_06_api_post_new_book)
Test REST API endpoint POST /api/books adds a new book successfully ... ok

test_07_api_post_empty_data_validation (test_app.BookcoolAppTestCase.test_07_api_post_empty_data_validation)
Test REST API endpoint POST /api/books handles missing payload properly ... ok

test_08_database_integrity (test_app.BookcoolAppTestCase.test_08_database_integrity)
Test database seed integrity - verify initial book list has valid prices and IDs ... ok

----------------------------------------------------------------------
Ran 8 tests in 0.086s

OK
```

---

## 3. ตารางรายการกรณีทดสอบ (Test Cases Matrix)

| รหัสทดสอบ | ชื่อฟังก์ชันทดสอบ | สิ่งที่ทำการทดสอบ | ค่าอินพุต (Input) | ผลลัพธ์ที่คาดหวัง | ผลจริง |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **TC-01** | `test_01_index_page` | ตรวจสอบการโหลดหน้าแรกของร้านค้า | `GET /` | Status: 200 OK, มีชื่อร้าน "E-Book Store" | ✅ PASS |
| **TC-02** | `test_02_static_pages_load` | ตรวจสอบหน้าจอสำคัญทั้ง 10 หน้า (`login`, `cart`, `checkout`, `admin`, `my-books`, `reports`, `sql-console`, `reviews`, `book-detail`, `add-book`) | `GET <route>` | Status: 200 OK ทุกหน้า | ✅ PASS |
| **TC-03** | `test_03_search_functionality` | ตรวจสอบการค้นหาชื่อหนังสือแบบไดนามิก | `GET /?search=Startup` | Status: 200, ผลลัพธ์มีหนังสือ "Lean Startup" | ✅ PASS |
| **TC-04** | `test_04_category_filter` | ตรวจสอบการกรองหนังสือตามหมวดหมู่ | `GET /?category=ธุรกิจ & การตลาด` | Status: 200, แสดงเฉพาะหนังสือหมวดธุรกิจ | ✅ PASS |
| **TC-05** | `test_05_api_get_books` | ตรวจสอบ REST API ดึงรายการหนังสือในรูปแบบ JSON | `GET /api/books` | Status: 200, คืน Array มีฟิลด์ `ebook_id`, `title`, `price` | ✅ PASS |
| **TC-06** | `test_06_api_post_new_book` | ตรวจสอบ REST API บันทึกหนังสือเล่มใหม่ | `POST /api/books` (JSON Payload) | Status: 201 Created, ส่งคืน Object หนังสือใหม่ | ✅ PASS |
| **TC-07** | `test_07_api_post_empty_validation`| ตรวจสอบการปฏิเสธคำขอเมื่อข้อมูลไม่ครบ | `POST /api/books` (Empty Body) | Status: 400 Bad Request ป้องกันข้อมูลผิดพลาด | ✅ PASS |
| **TC-08** | `test_08_database_integrity` | ตรวจสอบโครงสร้างข้อมูลเริ่มต้นในฐานข้อมูล | ตรวจสอบ `ebooks_database` | จำนวน >= 8 เล่ม, ราคา > 0, ID มีค่าถูกต้อง | ✅ PASS |

---

## 4. โครงสร้างไปป์ไลน์ GitHub Actions CI

ไปป์ไลน์ CI ถูกกำหนดไว้ในไฟล์ `.github/workflows/ci.yml` โดยทำงานอัตโนมัติทุกครั้งที่มีการ **Push** หรือสร้าง **Pull Request** ไปยังกิ่ง `main`:

```yaml
name: Bookcool CI Workflow

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  test:
    name: Run Automated Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install Dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Run Automated Unittest Suite
        run: |
          python -m unittest discover -s tests -v
```

### ประโยชน์ของ CI Pipeline ในโครงงานนี้:
1. **Automated Verification:** ตรวจสอบโค้ดโดยอัตโนมัติทันทีที่นักพัฒนาส่งงานขึ้น GitHub ป้องกันไม่ให้โค้ดที่มีข้อผิดพลาดถูกรวมเข้าสู่ระบบหลัก
2. **Standardized Environment:** รันบนสภาพแวดล้อม Ubuntu Clean Environment มั่นใจได้ว่าโค้ดทำงานได้จริงบนทุกแพลตฟอร์ม
3. **Traceability:** สามารถดูประวัติการทดสอบย้อนหลังของแต่ละ Commit ได้ที่หน้า GitHub Actions ตลอดเวลา

---

## 5. วิธีการรันชุดทดสอบด้วยตัวเอง (How to Run Tests Locally)

สามารถสั่งรันชุดทดสอบอัตโนมัติในคอมพิวเตอร์ของตนเองได้ด้วยคำสั่งเดียว:

```bash
# 1. ติดตั้งไลบรารีที่จำเป็น
pip install -r requirements.txt

# 2. รันการทดสอบอัตโนมัติทั้งหมดพร้อมแสดงรายละเอียด
python -m unittest discover -s tests -v
```
