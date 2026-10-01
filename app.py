from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# จำลองฐานข้อมูล E-Book (หรือข้อมูลที่คุณดึงมาจาก SQL)
ebooks_database = [
    {
        "ebook_id": 1,
        "title": "ถอดรหัสวิญญาณแห่งดวงดาว",
        "author_name": "กวิน ทัศนีย์",
        "price": 300.00,
        "category_name": "พัฒนาตนเอง",
        "description": "การพะวงเรื่องของจิตวิญญาณและการค้นหาความหมายของการยกระดับจิตใจ",
        "cover_image": "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400",
        "download_url": "#"
    },
    {
        "ebook_id": 2,
        "title": "Data Analytics with SQL & Business",
        "author_name": "ดร.สมชาย ปัญญาชัย",
        "price": 380.00,
        "category_name": "Data & AI",
        "description": "การกรองข้อมูลเชิงลึกด้วยคำสั่ง SQL วิเคราะห์ธุรกิจเพื่อสร้าง Dashboard อัจฉริยะ",
        "cover_image": "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&q=80&w=400",
        "download_url": "#"
    },
    {
        "ebook_id": 3,
        "title": "จิตวิทยาการเจรจาต่อรองให้ชนะทุกสโคป",
        "author_name": "ศิลป์การสื่อสาร",
        "price": 280.00,
        "category_name": "ธุรกิจ & การตลาด",
        "description": "ศิลปะการสื่อสารโน้มน้าวใจ การเจรจาทางธุรกิจและการสร้างความสัมพันธ์ Win-Win",
        "cover_image": "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&q=80&w=400",
        "download_url": "#"
    },
    {
        "ebook_id": 4,
        "title": "Clean Architecture & Design Patterns",
        "author_name": "ทีมวิศวกรซอฟต์แวร์",
        "price": 450.00,
        "category_name": "Programming",
        "description": "กระบวนการออกแบบสถาปัตยกรรมระบบซอฟต์แวร์ให้ยั่งยืน และดูแลรักษาง่าย",
        "cover_image": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=400",
        "download_url": "#"
    }
]

# หน้าแรกของเว็บไซต์ (แสดงรายการหนังสือและระบบค้นหา)
@app.route('/')
def index():
    search_query = request.args.get('search', '')
    selected_category = request.args.get('category', '')

    # กรองข้อมูลตามคำค้นหาหรือหมวดหมู่
    result_ebooks = ebooks_database
    if search_query:
        result_ebooks = [b for b in result_ebooks if search_query.lower() in b['title'].lower()]
    
    if selected_category and selected_category != 'all':
        result_ebooks = [b for b in result_ebooks if b['category_name'] == selected_category]

    return render_template('index.html', 
                           ebooks=result_ebooks, 
                           search_query=search_query, 
                           selected_category=selected_category,
                           current_user={"name": "พลอยแสง", "role": "Admin"})

# หน้าตะกร้าสินค้า
@app.route('/cart')
def cart():
    return render_template('cart.html')

# หน้าชำระเงิน
@app.route('/checkout')
def checkout():
    return render_template('checkout.html')

# หน้าผู้ดูแลระบบ (Admin Dashboard)
@app.route('/admin')
def admin():
    return render_template('admin.html')

# หน้าหนังสือของฉัน (ประวัติการซื้อ / My Library)
@app.route('/my-books')
@app.route('/my-books.html')
def my_books():
    return render_template('my-books.html')

# หน้ารายงานวิเคราะห์ข้อมูล (Reports & Analytics Dashboard)
@app.route('/reports')
@app.route('/reports.html')
def reports():
    return render_template('reports.html')

# หน้าแสดงรายละเอียดหนังสือ (Book Detail Page)
@app.route('/book-detail')
@app.route('/book-detail.html')
@app.route('/book/<int:book_id>')
def book_detail(book_id=None):
    return render_template('book-detail.html')

# หน้าจอเพิ่ม E-Book เล่มใหม่ (Add New Book Form)
@app.route('/add-book')
@app.route('/add-book.html', methods=['GET', 'POST'])
def add_book():
    return render_template('add-book.html')

if __name__ == '__main__':
    app.run(debug=True)