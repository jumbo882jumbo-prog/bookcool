from flask import Flask, render_template, request, redirect, url_for, jsonify

app = Flask(__name__, template_folder='.', static_folder='.', static_url_path='')

# จำลองฐานข้อมูล E-Book 8 เล่มตามหน้าเว็บไซต์
ebooks_database = [
    {
        "ebook_id": 1,
        "title": "Lean Startup & Product Strategy",
        "author_name": "ณัฐพร นวัตกรรม",
        "price": 320.00,
        "category_name": "ธุรกิจ & การตลาด",
        "description": "คู่มือทดสอบไอเดียธุรกิจ สร้าง MVP และปรับเปลี่ยนทิศทางอย่างรวดเร็วโดยไม่เผางบประมาณ",
        "cover_image": "https://images.unsplash.com/photo-1553729459-efe14ef6055d?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 2,
        "title": "กำเนิดจักรกลนิรันดร์ (Chronicles of Eternity)",
        "author_name": "กวี ศรีสยาม",
        "price": 195.00,
        "category_name": "วรรณกรรม & นวนิยาย",
        "description": "นวนิยายไซไฟแฟนตาซี การเดินทางข้ามห้วงกาลเวลาเพื่อกอบกู้ดวงดาวที่สาบสูญ",
        "cover_image": "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 3,
        "title": "Practical Generative AI for Developers",
        "author_name": "ดร. ธีรภัทร ปัญญาประดิษฐ์",
        "price": 490.00,
        "category_name": "วิทยาศาสตร์ข้อมูล & AI",
        "description": "คู่มือนักพัฒนาในการเชื่อมต่อ LLM APIs, Prompt Engineering, RAG Architecture และการสร้าง AI Agents",
        "cover_image": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 4,
        "title": "The Modern Growth Hacking & Digital Marketing",
        "author_name": "อนันต์ การตลาดดิจิทัล",
        "price": 390.00,
        "category_name": "ธุรกิจ & การตลาด",
        "description": "กลยุทธ์ยิงแอดและสร้าง Funnel ปิดการขายอัตโนมัติ สำหรับธุรกิจออนไลน์ที่ต้องการสเกลยอดขาย",
        "cover_image": "https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 5,
        "title": "จิตวิทยาการบริหารเวลา Focus & Productivity",
        "author_name": "พญ. ธิดารัตน์ สุขภาพจิต",
        "price": 250.00,
        "category_name": "พัฒนาตนเอง & จิตวิทยา",
        "description": "เคล็ดลับทางประสาทวิทยาในการกำจัดนิสัยผลัดวันประกันพรุ่งและโฟกัสกับงานสำคัญอย่างเด็ดขาด",
        "cover_image": "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 6,
        "title": "คู่มือวางแผนภาษีและการลงทุนฉบับประชาชน",
        "author_name": "ชัชวาล เศรษฐศาสตร์",
        "price": 290.00,
        "category_name": "การเงิน & การลงทุน",
        "description": "เข้าใจการลดหย่อนภาษีอย่างถูกต้อง พร้อมกลยุทธ์สร้างอิสรภาพทางการเงินผ่านกองทุนรวมและหุ้นปันผล",
        "cover_image": "https://images.unsplash.com/photo-1585829365295-ab7cd400c167?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 7,
        "title": "Full-Stack Web Development with Python & Modern Stack",
        "author_name": "อาจารย์ พรชัย เทคโนโลยี",
        "price": 420.00,
        "category_name": "เทคโนโลยี & การเขียนโปรแกรม",
        "description": "สร้างเว็บแอปพลิเคชันระดับโปรดักชันด้วย Flask, RESTful API และฐานข้อมูล พร้อมการทำ Deployment",
        "cover_image": "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    },
    {
        "ebook_id": 8,
        "title": "Mastering Database Design & SQL",
        "author_name": "ดร. กิตติพงษ์ วิริยะกุล",
        "price": 299.00,
        "category_name": "เทคโนโลยี & การเขียนโปรแกรม",
        "description": "เจาะลึกการออกแบบฐานข้อมูลเชิงสัมพันธ์ตั้งแต่ระดับพื้นฐาน Normalization 3NF จนถึงการ Optimize Query",
        "cover_image": "https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&q=80&w=600",
        "download_url": "#"
    }
]

# หน้าแรกของเว็บไซต์ (แสดงรายการหนังสือและระบบค้นหา)
@app.route('/')
@app.route('/index.html')
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
                           selected_category=selected_category)

# หน้าเข้าสู่ระบบและสมัครสมาชิก
@app.route('/login')
@app.route('/login.html')
def login():
    return render_template('login.html')

# หน้าตะกร้าสินค้า
@app.route('/cart')
@app.route('/cart.html')
def cart():
    return render_template('cart.html')

# หน้าชำระเงิน
@app.route('/checkout')
@app.route('/checkout.html')
def checkout():
    return render_template('checkout.html')

# หน้าผู้ดูแลระบบ (Admin Dashboard)
@app.route('/admin')
@app.route('/admin.html')
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

# หน้าคำสั่งเขียน SQL (SQL Query Console)
@app.route('/sql-console')
@app.route('/sql-console.html')
def sql_console():
    return render_template('sql-console.html')

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

# หน้าจอแก้ไข E-Book (Edit Book Form)
@app.route('/edit-book')
@app.route('/edit-book.html')
def edit_book():
    return render_template('add-book.html')

# REST API สำหรับดึงและเพิ่มหนังสือในระบบ
@app.route('/api/books', methods=['GET', 'POST'])
def api_books():
    global ebooks_database
    if request.method == 'POST':
        data = request.get_json(silent=True) or request.form.to_dict()
        if not data:
            return jsonify({"status": "error", "message": "No data provided"}), 400
        
        new_id = max([b.get('ebook_id', 0) for b in ebooks_database], default=0) + 1
        new_book = {
            "ebook_id": new_id,
            "title": data.get('title', 'หนังสือไม่มีชื่อ'),
            "author_name": data.get('author', 'ไม่ระบุผู้แต่ง'),
            "price": float(data.get('price', 0)),
            "category_name": data.get('category', 'ทั่วไป'),
            "description": data.get('description', ''),
            "cover_image": data.get('cover', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400'),
            "download_url": "#"
        }
        ebooks_database.append(new_book)
        return jsonify({"status": "success", "book": new_book}), 201
    
    return jsonify(ebooks_database)

if __name__ == '__main__':
    app.run(debug=True)