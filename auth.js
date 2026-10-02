/**
 * auth.js - ระบบบริหารจัดการสิทธิ์ผู้ใช้งานและการล็อกอิน (User & Admin RBAC)
 * สำหรับระบบร้านค้า E-Book Store
 */

const auth = {
    // บัญชีเริ่มต้นสำหรับทดสอบระบบ
    defaultAccounts: [
        {
            username: 'admin',
            email: 'admin@bookcool.com',
            password: 'admin',
            name: 'พลอยแสง (ผู้ดูแลระบบ)',
            role: 'admin',
            avatar: 'พล'
        },
        {
            username: 'user',
            email: 'user@bookcool.com',
            password: 'user',
            name: 'สมชาย สมาชิกนักอ่าน',
            role: 'user',
            avatar: 'สม'
        }
    ],

    // ดึงรายชื่อบัญชีผู้ใช้ทั้งหมด (รวมที่สมัครใหม่)
    getAllAccounts() {
        const stored = localStorage.getItem('registered_users');
        if (stored) {
            try {
                return JSON.parse(stored);
            } catch (e) {
                console.error("Error reading registered users", e);
            }
        }
        localStorage.setItem('registered_users', JSON.stringify(this.defaultAccounts));
        return [...this.defaultAccounts];
    },

    // ดึงข้อมูลผู้ใช้ปัจจุบันที่ล็อกอินอยู่
    getCurrentUser() {
        const userJson = localStorage.getItem('current_user');
        if (userJson) {
            try {
                return JSON.parse(userJson);
            } catch (e) {
                console.error("Error parsing current_user", e);
            }
        }
        return null;
    },

    // ตรวจสอบว่าเป็น Admin หรือไม่
    isAdmin() {
        const user = this.getCurrentUser();
        return user && user.role === 'admin';
    },

    // ตรวจสอบว่าเป็น User ทั่วไปหรือไม่
    isUser() {
        const user = this.getCurrentUser();
        return user && user.role === 'user';
    },

    // ตรวจสอบว่าล็อกอินอยู่หรือไม่
    isLoggedIn() {
        return this.getCurrentUser() !== null;
    },

    // การตั้งค่า Supabase
    getSupabaseConfig() {
        const defaultUrl = 'https://cowzufrrwntajvhiqajg.supabase.co';
        const defaultKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvd3p1ZnJyd250YWp2aGlxYWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4NjIwMDksImV4cCI6MjEwNjQzODAwOX0.9oVNjcWkNNfyhOO8cPKYSccQCU2kRV6z8L1ZX0Px0gs';
        const saved = JSON.parse(localStorage.getItem('bookcool_supabase_config') || '{}');
        return {
            url: saved.url || (typeof window !== 'undefined' && window.ENV_SUPABASE_URL) || defaultUrl,
            key: saved.key || (typeof window !== 'undefined' && window.ENV_SUPABASE_KEY) || defaultKey
        };
    },

    // ซิงค์รายชื่อผู้ใช้จาก Supabase เข้าสู่ localStorage
    async syncUsersFromSupabase() {
        try {
            const { url, key } = this.getSupabaseConfig();
            const resp = await fetch(`${url}/rest/v1/users?select=*`, {
                headers: {
                    'apikey': key,
                    'Authorization': `Bearer ${key}`
                }
            });
            if (!resp.ok) return;
            const remoteUsers = await resp.json();
            if (Array.isArray(remoteUsers) && remoteUsers.length > 0) {
                const localUsers = this.getAllAccounts();
                const merged = [...localUsers];
                
                remoteUsers.forEach(ru => {
                    const idx = merged.findIndex(lu => 
                        (lu.username && lu.username.toLowerCase() === (ru.username || '').toLowerCase()) ||
                        (lu.email && lu.email.toLowerCase() === (ru.email || '').toLowerCase())
                    );
                    if (idx >= 0) {
                        merged[idx] = { ...merged[idx], ...ru };
                    } else {
                        merged.push(ru);
                    }
                });
                localStorage.setItem('registered_users', JSON.stringify(merged));
            }
        } catch (e) {
            console.warn('Could not sync users from Supabase:', e);
        }
    },

    // ฟังก์ชันเข้าสู่ระบบ (รองรับทั้ง localStorage และตรวจสอบสดกับ Supabase)
    async login(usernameOrEmail, password, forcedRole = null) {
        let accounts = this.getAllAccounts();
        let user = accounts.find(acc => 
            (acc.username && acc.username.toLowerCase() === usernameOrEmail.toLowerCase().trim() || 
             acc.email && acc.email.toLowerCase() === usernameOrEmail.toLowerCase().trim()) &&
            acc.password === password
        );

        // หากหาใน Local ไม่พบ ให้ลองดึงสดจาก Supabase public.users
        if (!user) {
            try {
                const { url, key } = this.getSupabaseConfig();
                const term = encodeURIComponent(usernameOrEmail.trim());
                const resp = await fetch(`${url}/rest/v1/users?or=(username.ilike.${term},email.ilike.${term})&password=eq.${encodeURIComponent(password)}`, {
                    headers: {
                        'apikey': key,
                        'Authorization': `Bearer ${key}`
                    }
                });
                if (resp.ok) {
                    const data = await resp.json();
                    if (Array.isArray(data) && data.length > 0) {
                        user = data[0];
                        accounts.push(user);
                        localStorage.setItem('registered_users', JSON.stringify(accounts));
                    }
                }
            } catch (e) {
                console.warn('Supabase login query error:', e);
            }
        }

        if (!user) {
            return { success: false, message: 'ชื่อผู้ใช้/อีเมล หรือรหัสผ่านไม่ถูกต้อง' };
        }

        // หากมีการระบุบทบาทแต่ไม่ตรงกับบัญชี
        if (forcedRole && user.role !== forcedRole) {
            return { 
                success: false, 
                message: `บัญชีนี้มีสิทธิ์เป็น "${user.role.toUpperCase()}" ไม่ตรงกับที่เลือกเป็น "${forcedRole.toUpperCase()}"` 
            };
        }

        // บันทึก Session ลงใน localStorage
        localStorage.setItem('current_user', JSON.stringify(user));
        return { success: true, user: user };
    },

    // ล็อกอินแบบด่วน (One-Click Quick Login สำหรับเดโม)
    quickLogin(role) {
        const accounts = this.getAllAccounts();
        const target = accounts.find(a => a.role === role);
        if (target) {
            localStorage.setItem('current_user', JSON.stringify(target));
            return { success: true, user: target };
        }
        return { success: false, message: 'ไม่พบบัญชีสำหรับบทบาทนี้' };
    },

    // สมัครสมาชิกใหม่ (บันทึกลงทั้ง LocalStorage และ Supabase users table)
    async register(name, email, username, password, role = 'user') {
        const accounts = this.getAllAccounts();
        const exists = accounts.some(a => 
            (a.username && a.username.toLowerCase() === username.toLowerCase().trim()) ||
            (a.email && a.email.toLowerCase() === email.toLowerCase().trim())
        );

        if (exists) {
            return { success: false, message: 'ชื่อผู้ใช้หรืออีเมลนี้มีอยู่ในระบบแล้ว' };
        }

        const newUser = {
            username: username.trim(),
            name: name.trim(),
            email: email.trim(),
            password: password,
            role: role,
            avatar: name.trim().substring(0, 2)
        };

        // 1. บันทึกข้อมูลไปยังตาราง users ใน Supabase ทันที
        try {
            const { url, key } = this.getSupabaseConfig();
            
            // เช็คกับตาราง users ใน Supabase เพื่อป้องกันชื่อซ้ำ
            const checkTerm = encodeURIComponent(username.trim());
            const checkEmail = encodeURIComponent(email.trim());
            const checkResp = await fetch(`${url}/rest/v1/users?or=(username.ilike.${checkTerm},email.ilike.${checkEmail})`, {
                headers: {
                    'apikey': key,
                    'Authorization': `Bearer ${key}`
                }
            });
            if (checkResp.ok) {
                const existingRemote = await checkResp.json();
                if (Array.isArray(existingRemote) && existingRemote.length > 0) {
                    return { success: false, message: 'ชื่อผู้ใช้หรืออีเมลนี้มีอยู่ในฐานข้อมูล Supabase แล้ว' };
                }
            }

            // บันทึกผู้ใช้เข้าสู่ Supabase public.users
            const resp = await fetch(`${url}/rest/v1/users`, {
                method: 'POST',
                headers: {
                    'apikey': key,
                    'Authorization': `Bearer ${key}`,
                    'Content-Type': 'application/json',
                    'Prefer': 'return=representation'
                },
                body: JSON.stringify(newUser)
            });

            if (resp.ok) {
                const inserted = await resp.json();
                if (Array.isArray(inserted) && inserted.length > 0) {
                    newUser.user_id = inserted[0].user_id;
                    newUser.created_at = inserted[0].created_at;
                    console.log('✅ บันทึกผู้ใช้เข้า Supabase public.users สำเร็จ:', inserted[0]);
                }
            } else {
                const errData = await resp.json().catch(() => ({}));
                console.warn('⚠️ Supabase users insert error:', errData);
            }
        } catch (e) {
            console.error('❌ เกิดข้อผิดพลาดในการเชื่อมต่อ Supabase users:', e);
        }

        // 2. บันทึกลง LocalStorage
        accounts.push(newUser);
        localStorage.setItem('registered_users', JSON.stringify(accounts));
        localStorage.setItem('current_user', JSON.stringify(newUser));
        return { success: true, user: newUser };
    },

    // ออกจากระบบ
    logout() {
        localStorage.removeItem('current_user');
        alert('👋 ออกจากระบบเรียบร้อยแล้ว');
        window.location.href = 'index.html';
    },

    // ฟังก์ชันป้องกันหน้าแอดมินหลังบ้าน (Admin Guard)
    // เรียกใช้ใน admin.html, add-book.html, edit-book.html, reports.html
    protectAdminPage() {
        const user = this.getCurrentUser();
        const currentPage = window.location.pathname.split('/').pop() || 'admin.html';

        if (!user) {
            alert('⚠️ กรุณาเข้าสู่ระบบก่อนเข้าใช้งานส่วนผู้ดูแลระบบ (Admin Portal)');
            window.location.replace(`login.html?redirect=${encodeURIComponent(currentPage)}`);
            return false;
        }

        if (user.role !== 'admin') {
            alert('⛔ สิทธิ์การใช้งานไม่เพียงพอ!\n\nบัญชีของคุณคือ: "' + user.name + '" (สิทธิ์: User สมาชิกทั่วไป)\nไม่สามารถเข้าถึงหน้าจัดการหลังบ้านของ Admin ได้\n\nระบบจะพาท่านกลับไปยังหน้าร้านค้า');
            window.location.replace('index.html');
            return false;
        }

        return true;
    },

    // อัปเดตแถบนำทาง (Navbar) ในทุกหน้าเว็บโดยอัตโนมัติ
    updateNavbarUI() {
        const user = this.getCurrentUser();
        const navAuthContainers = document.querySelectorAll('.auth-nav-container');

        navAuthContainers.forEach(container => {
            if (!user) {
                // กรณี: ยังไม่ได้เข้าสู่ระบบ (Guest)
                container.innerHTML = `
                    <div class="flex items-center space-x-2">
                        <a href="login.html?role=user" class="text-xs bg-gray-800 hover:bg-gray-700 text-gray-200 px-3 py-1.5 rounded-lg border border-gray-700 transition flex items-center gap-1.5">
                            👤 <span>เข้าสู่ระบบ</span>
                        </a>
                        <a href="login.html?role=admin" class="text-xs bg-red-600/90 hover:bg-red-600 text-white px-2.5 py-1.5 rounded-lg font-semibold transition flex items-center gap-1 shadow-sm" title="เข้าสู่ระบบผู้ดูแล">
                            🛡️ <span>Admin</span>
                        </a>
                    </div>
                `;
            } else if (user.role === 'admin') {
                // กรณี: แอดมิน (Admin)
                container.innerHTML = `
                    <div class="flex items-center space-x-3">
                        <a href="admin.html" class="flex items-center space-x-1.5 bg-red-600 hover:bg-red-700 text-white px-2.5 py-1.5 rounded-lg text-xs font-bold transition shadow-sm" title="แดชบอร์ดหลังบ้าน">
                            <span>⚙️</span>
                            <span class="hidden sm:inline">ระบบหลังบ้าน</span>
                        </a>
                        <div class="flex items-center space-x-2 border-l border-gray-700 pl-3">
                            <div class="w-8 h-8 rounded-full bg-red-600 flex items-center justify-center font-bold text-white text-xs ring-2 ring-red-400/40">
                                ${user.avatar || 'AD'}
                            </div>
                            <div class="hidden lg:flex flex-col text-left">
                                <span class="text-xs font-semibold text-gray-200">${user.name}</span>
                                <span class="text-[10px] text-red-400 font-bold uppercase tracking-wider">ADMIN</span>
                            </div>
                            <button onclick="auth.logout()" title="ออกจากระบบ" class="text-xs bg-gray-800 hover:bg-red-900/60 text-gray-300 hover:text-red-200 px-2.5 py-1.5 rounded-lg border border-gray-700 transition cursor-pointer flex items-center gap-1">
                                🚪 <span class="hidden xl:inline">ออก</span>
                            </button>
                        </div>
                    </div>
                `;
            } else {
                // กรณี: สมาชิกทั่วไป (User)
                container.innerHTML = `
                    <div class="flex items-center space-x-3">
                        <div class="flex items-center space-x-2 border-l border-gray-700 pl-3">
                            <div class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center font-bold text-white text-xs ring-2 ring-blue-400/40">
                                ${user.avatar || 'US'}
                            </div>
                            <div class="hidden lg:flex flex-col text-left">
                                <span class="text-xs font-semibold text-gray-200">${user.name}</span>
                                <span class="text-[10px] text-blue-400 font-semibold uppercase tracking-wider">MEMBER</span>
                            </div>
                            <button onclick="auth.logout()" title="ออกจากระบบ" class="text-xs bg-gray-800 hover:bg-gray-700 text-gray-300 hover:text-white px-2.5 py-1.5 rounded-lg border border-gray-700 transition cursor-pointer flex items-center gap-1">
                                🚪 <span class="hidden xl:inline">ออก</span>
                            </button>
                        </div>
                    </div>
                `;
            }
        });

        // ควบคุมการแสดงปุ่มแก้ไขบนหน้าแรกและหน้ารายละเอียดหนังสือ
        // หากไม่ใช่ Admin ให้ซ่อนปุ่มแก้ไขหนังสือ
        const editButtons = document.querySelectorAll('.admin-only-control');
        editButtons.forEach(btn => {
            if (this.isAdmin()) {
                btn.classList.remove('hidden');
            } else {
                btn.classList.add('hidden');
            }
        });

        // ควบคุมปุ่มเข้าสู่ระบบหลังบ้านใน Footer
        const adminLinks = document.querySelectorAll('.admin-link-nav');
        adminLinks.forEach(link => {
            if (!user) {
                link.href = 'login.html?redirect=admin.html';
            } else if (user.role === 'admin') {
                link.href = 'admin.html';
                link.classList.remove('opacity-50');
            } else {
                // หากเป็น User ทั่วไป เมื่อคลิกลิงก์ Admin ให้ขึ้นเตือน
                link.href = 'javascript:void(0);';
                link.onclick = () => {
                    alert('⛔ สิทธิ์ไม่เพียงพอ: บัญชีของคุณเป็น User ทั่วไป ไม่สามารถเข้าสู่ระบบหลังบ้านของ Admin ได้ครับ');
                };
            }
        });
    }
};

/**
 * cartManager - บริหารจัดการตะกร้าสินค้า (Cart Storage)
 */
const cartManager = {
    getCart() {
        try {
            const data = localStorage.getItem('cart_items');
            return data ? JSON.parse(data) : [];
        } catch (e) {
            console.error("Error reading cart", e);
            return [];
        }
    },

    saveCart(items) {
        try {
            localStorage.setItem('cart_items', JSON.stringify(items));
        } catch (e) {
            console.error("Error saving cart", e);
        }
        this.updateCartBadges();
        window.dispatchEvent(new Event('cartUpdated'));
    },

    addToCart(book) {
        if (!book) return [];
        const cart = this.getCart();
        const bookId = String(book.id || book.ebook_id);
        const existing = cart.find(item => String(item.id) === bookId);

        let priceNum = 0;
        if (typeof book.price === 'string') {
            priceNum = parseFloat(book.price.replace(/[^\d.-]/g, '')) || 0;
        } else {
            priceNum = parseFloat(book.price) || 0;
        }

        if (existing) {
            existing.quantity = (existing.quantity || 1) + 1;
        } else {
            cart.push({
                id: bookId,
                title: book.title || 'หนังสือไม่มีชื่อ',
                author: book.author || book.author_name || 'ไม่ระบุผู้แต่ง',
                price: priceNum,
                cover: book.cover || book.cover_image || 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
                category: book.category || book.category_name || 'ทั่วไป',
                quantity: 1
            });
        }
        this.saveCart(cart);
        return cart;
    },

    removeFromCart(bookId) {
        let cart = this.getCart();
        cart = cart.filter(item => String(item.id) !== String(bookId));
        this.saveCart(cart);
        return cart;
    },

    clearCart() {
        localStorage.removeItem('cart_items');
        this.updateCartBadges();
        window.dispatchEvent(new Event('cartUpdated'));
    },

    getCartCount() {
        const cart = this.getCart();
        return cart.reduce((sum, item) => sum + (item.quantity || 1), 0);
    },

    getCartTotal() {
        const cart = this.getCart();
        return cart.reduce((sum, item) => sum + ((parseFloat(item.price) || 0) * (item.quantity || 1)), 0);
    },

    updateCartBadges() {
        const count = this.getCartCount();
        const badge1 = document.getElementById('cartCount');
        if (badge1) badge1.innerText = count;
        const badge2 = document.getElementById('cartCountBadge');
        if (badge2) badge2.innerText = count;
    }
};

/**
 * orderManager - บริหารจัดการคำสั่งซื้อและสถานะการตรวจสอบสลิป (Orders & Admin Confirmation)
 */
const defaultOrders = [
    {
        id: "ORD-2026-001",
        customerName: "สมชาย สมาชิกนักอ่าน",
        customerEmail: "user@bookcool.com",
        customerUsername: "user",
        items: [
            {
                id: "1",
                title: "Lean Startup & Product Strategy",
                author: "ณัฐพร นวัตกรรม",
                price: 320.00,
                cover: "https://images.unsplash.com/photo-1553729459-efe14ef6055d?auto=format&fit=crop&q=80&w=400",
                category: "ธุรกิจ & การตลาด",
                quantity: 1
            }
        ],
        total: 320.00,
        status: "pending", // "pending" = รอแอดมินตรวจสอบสลิป, "approved" = ยืนยันแล้ว ปลดล็อกดาวน์โหลด
        slipImage: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&q=80&w=400",
        date: "2026-10-01 18:30",
        timestamp: 1727803800000
    },
    {
        id: "ORD-2026-002",
        customerName: "กัญญา 3D",
        customerEmail: "kanya@example.com",
        customerUsername: "kanya",
        items: [
            {
                id: "4",
                title: "Clean Architecture & Design Patterns",
                author: "ทีมวิศวกรซอฟต์แวร์",
                price: 450.00,
                cover: "https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&q=80&w=400",
                category: "Programming",
                quantity: 1
            }
        ],
        total: 450.00,
        status: "approved",
        slipImage: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&q=80&w=400",
        date: "2026-10-01 14:15",
        timestamp: 1727788500000
    }
];

const orderManager = {
    getOrders() {
        const stored = localStorage.getItem('orders_list');
        if (stored) {
            try {
                return JSON.parse(stored);
            } catch (e) {
                console.error("Error reading orders", e);
            }
        }
        localStorage.setItem('orders_list', JSON.stringify(defaultOrders));
        return [...defaultOrders];
    },

    saveOrders(orders) {
        try {
            localStorage.setItem('orders_list', JSON.stringify(orders));
        } catch (e) {
            console.error("Error saving orders", e);
        }
        window.dispatchEvent(new Event('ordersUpdated'));
    },

    createOrder(customerInfo, items, total, slipDataUrl = null, customOrderId = null) {
        const orders = this.getOrders();
        let orderId = customOrderId;

        if (!orderId) {
            // คำนวณรหัสคำสั่งซื้อใหม่ ป้องกันการชนกับบิลเดิมในระบบหรือ Supabase
            let maxNum = 19; // ตั้งต้นขั้นต่ำ 19 ป้องกันชนกับ ORD-2026-001 ถึง 019
            orders.forEach(o => {
                const m = String(o.id).match(/ORD-\d+-(\d+)/);
                if (m) {
                    const n = parseInt(m[1], 10);
                    if (n > maxNum) maxNum = n;
                }
            });
            const nextNum = maxNum + 1;
            orderId = `ORD-2026-${String(nextNum).padStart(3, '0')}`;
        }

        const now = new Date();
        const dateStr = now.getFullYear() + '-' + 
            String(now.getMonth() + 1).padStart(2, '0') + '-' + 
            String(now.getDate()).padStart(2, '0') + ' ' + 
            String(now.getHours()).padStart(2, '0') + ':' + 
            String(now.getMinutes()).padStart(2, '0') + ':' +
            String(now.getSeconds()).padStart(2, '0');

        // ทำสำเนา items ให้มีข้อมูลครบถ้วนสมบูรณ์
        const sanitizedItems = (items || []).map(it => ({
            id: String(it.id || it.ebook_id || '1'),
            ebook_id: String(it.id || it.ebook_id || '1'),
            title: it.title || it.book_title || 'หนังสือสั่งซื้อ',
            author: it.author || it.author_name || 'ไม่ระบุผู้แต่ง',
            price: typeof it.price === 'string' ? (parseFloat(it.price.replace(/[^\d.-]/g, '')) || 0) : (parseFloat(it.price) || 0),
            cover: it.cover || it.cover_image || 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
            category: it.category || it.category_name || 'ทั่วไป',
            quantity: parseInt(it.quantity, 10) || 1
        }));

        const cleanTotal = typeof total === 'string' ? (parseFloat(total.replace(/[^\d.-]/g, '')) || 0) : (parseFloat(total) || 0);

        const newOrder = {
            id: orderId,
            customerName: customerInfo.name || 'ลูกค้าทั่วไป',
            customerEmail: customerInfo.email || 'customer@bookcool.com',
            customerUsername: customerInfo.username || 'guest',
            items: sanitizedItems,
            total: cleanTotal,
            status: 'pending',
            slipImage: slipDataUrl || 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&q=80&w=400',
            date: dateStr,
            timestamp: now.getTime()
        };

        // ลบ order เดิมถ้ามี id ชนกันใน local
        const filtered = orders.filter(o => o.id !== orderId);
        filtered.unshift(newOrder); // เพิ่มไว้บนสุด
        this.saveOrders(filtered);
        return newOrder;
    },

    confirmOrder(orderId) {
        return this.setOrderStatus(orderId, 'approved');
    },

    setOrderStatus(orderId, status = 'approved') {
        const orders = this.getOrders();
        const target = orders.find(o => o.id === orderId);
        if (target) {
            target.status = status;
            this.saveOrders(orders);
            return { success: true, order: target };
        } else {
            // หากดึงข้อมูลสดมาจาก Supabase แต่ยังไม่มีใน local ให้บันทึกลง local
            const newEntry = {
                id: orderId,
                status: status,
                date: new Date().toLocaleString('th-TH')
            };
            orders.unshift(newEntry);
            this.saveOrders(orders);
            return { success: true, order: newEntry };
        }
    },

    deleteOrder(orderId) {
        let orders = this.getOrders();
        orders = orders.filter(o => o.id !== orderId);
        this.saveOrders(orders);
    }
};

// สั่งให้อัปเดต Navbar, ตะกร้า และซิงค์ผู้ใช้จาก Supabase ทันทีเมื่อโหลดหน้าเว็บ
function initAppAuthAndCart() {
    auth.updateNavbarUI();
    cartManager.updateCartBadges();
    auth.syncUsersFromSupabase();
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAppAuthAndCart);
} else {
    initAppAuthAndCart();
}

window.addEventListener('pageshow', () => {
    auth.updateNavbarUI();
    cartManager.updateCartBadges();
});

window.addEventListener('storage', (e) => {
    if (e.key === 'cart_items') {
        cartManager.updateCartBadges();
    }
});
