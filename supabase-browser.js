/**
 * supabase-browser.js
 * สำหรับใช้งานบนเว็บ bookcool แบบ Client-Side (Vanilla JS / HTML)
 * รองรับการโหลดผ่าน CDN: <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
 */

(function (window) {
    // 1. กำหนดค่าเริ่มต้น หรือดึงจาก localStorage หากผู้ใช้เคยตั้งค่าไว้
    const defaultUrl = 'https://cowzufrrwntajvhiqajg.supabase.co';
    const defaultKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvd3p1ZnJyd250YWp2aGlxYWpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4NjIwMDksImV4cCI6MjEwNjQzODAwOX0.9oVNjcWkNNfyhOO8cPKYSccQCU2kRV6z8L1ZX0Px0gs';

    const savedConfig = JSON.parse(localStorage.getItem('bookcool_supabase_config') || '{}');
    const SUPABASE_URL = savedConfig.url || window.ENV_SUPABASE_URL || defaultUrl;
    const SUPABASE_ANON_KEY = savedConfig.key || window.ENV_SUPABASE_KEY || defaultKey;

    let client = null;

    // ตรวจสอบว่ามี Supabase CDN หรือไม่
    if (window.supabase && typeof window.supabase.createClient === 'function') {
        client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
            auth: {
                persistSession: true,
                autoRefreshToken: true
            }
        });
    }

    // ฟังก์ชันตั้งค่า URL & Key ใหม่ (บันทึกลง LocalStorage สำหรับทดสอบบนเว็บได้ทันที)
    function configure(url, key) {
        if (!url || !key) return false;
        localStorage.setItem('bookcool_supabase_config', JSON.stringify({ url, key }));
        if (window.supabase && typeof window.supabase.createClient === 'function') {
            client = window.supabase.createClient(url, key);
        }
        return true;
    }

    // Helper functions สำหรับเชื่อมต่อ 8 ตารางของ bookcool
    const db = {
        get client() {
            if (!client && window.supabase && typeof window.supabase.createClient === 'function') {
                const cfg = JSON.parse(localStorage.getItem('bookcool_supabase_config') || '{}');
                client = window.supabase.createClient(cfg.url || defaultUrl, cfg.key || defaultKey);
            }
            return client;
        },

        configure,

        // ฟังก์ชัน Realtime: แจ้งเตือนเมื่อตารางใน Supabase มีการแก้ไข/เพิ่ม/ลบ
        subscribeToTable(tableName, onChange) {
            if (!this.client) return null;
            try {
                const channel = this.client
                    .channel(`realtime_${tableName}_${Date.now()}`)
                    .on(
                        'postgres_changes',
                        { event: '*', schema: 'public', table: tableName },
                        payload => {
                            console.log(`⚡ [Supabase Realtime] มีการอัปเดตในตาราง "${tableName}":`, payload);
                            if (typeof onChange === 'function') onChange(payload);
                        }
                    )
                    .subscribe();
                return channel;
            } catch (err) {
                console.warn('Realtime subscription error:', err);
                return null;
            }
        },

        // 1. ดึงข้อมูลหนังสือทั้งหมด พร้อมชื่อหมวดหมู่
        async getBooks({ categoryId = null, searchQuery = '', sort = 'latest' } = {}) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้ติดตั้งหรือเชื่อมต่อ');
            
            let query = this.client
                .from('ebooks')
                .select(`
                    *,
                    categories (
                        category_id,
                        category_name
                    )
                `);

            if (categoryId && categoryId !== 'all') {
                query = query.eq('category_id', categoryId);
            }

            if (searchQuery.trim()) {
                query = query.or(`title.ilike.%${searchQuery}%,author_name.ilike.%${searchQuery}%`);
            }

            if (sort === 'price-low') {
                query = query.order('price', { ascending: true });
            } else if (sort === 'price-high') {
                query = query.order('price', { ascending: false });
            } else {
                query = query.order('ebook_id', { ascending: false });
            }

            const { data, error } = await query;
            if (error) throw error;
            return data;
        },

        // 2. ดึงรายละเอียดหนังสือตาม ID
        async getBookById(id) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('ebooks')
                .select('*, categories(*)')
                .eq('ebook_id', id)
                .single();
            if (error) throw error;
            return data;
        },

        // 3. ดึงหมวดหมู่ทั้งหมด
        async getCategories() {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('categories')
                .select('*')
                .order('category_id', { ascending: true });
            if (error) throw error;
            return data;
        },

        // 3.1 เพิ่มหนังสือเล่มใหม่ลงใน Supabase (ตาราง ebooks)
        async addBook({ title, author, price, categoryName, description = '', coverImage = '', downloadUrl = '#' }) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            
            // หา category_id ที่ตรงกับชื่อหมวดหมู่
            let categoryId = null;
            try {
                const cats = await this.getCategories();
                if (Array.isArray(cats)) {
                    const found = cats.find(c => c.category_name.trim() === (categoryName || '').trim() || (categoryName || '').includes(c.category_name));
                    if (found) categoryId = found.category_id;
                }
            } catch (catErr) {
                console.warn('Cannot map category_id:', catErr);
            }

            const { data, error } = await this.client
                .from('ebooks')
                .insert([{
                    title: title.trim(),
                    author_name: author.trim(),
                    price: parseFloat(price) || 0,
                    category_id: categoryId,
                    category_name: categoryName || 'ทั่วไป',
                    description: description || '',
                    cover_image: coverImage || 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&q=80&w=400',
                    download_url: downloadUrl || '#',
                    is_published: true
                }])
                .select()
                .single();

            if (error) throw error;
            return data;
        },

        // 3.2 แก้ไขข้อมูลหนังสือใน Supabase
        async updateBook(ebookId, { title, author, price, categoryName, description = '', coverImage = '' }) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            
            let categoryId = null;
            try {
                const cats = await this.getCategories();
                if (Array.isArray(cats)) {
                    const found = cats.find(c => c.category_name.trim() === (categoryName || '').trim() || (categoryName || '').includes(c.category_name));
                    if (found) categoryId = found.category_id;
                }
            } catch (e) {}

            const updatePayload = {
                title: title.trim(),
                author_name: author.trim(),
                price: parseFloat(price) || 0,
                category_name: categoryName || 'ทั่วไป',
                description: description || '',
                updated_at: new Date().toISOString()
            };
            if (categoryId) updatePayload.category_id = categoryId;
            if (coverImage) updatePayload.cover_image = coverImage;

            const { data, error } = await this.client
                .from('ebooks')
                .update(updatePayload)
                .eq('ebook_id', ebookId)
                .select()
                .single();

            if (error) throw error;
            return data;
        },

        // 3.3 ลบหนังสือออกจาก Supabase
        async deleteBook(ebookId) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { error } = await this.client
                .from('ebooks')
                .delete()
                .eq('ebook_id', ebookId);
            if (error) throw error;
            return true;
        },

        // 4. สร้างคำสั่งซื้อใหม่ (บันทึกลง orders และ order_items)
        async createOrder({ orderId, userId, customerName, customerEmail, totalAmount, slipUrl = '', items = [] }) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');

            // บันทึกลงตาราง orders
            const { data: orderData, error: orderError } = await this.client
                .from('orders')
                .insert([{
                    order_id: orderId,
                    user_id: userId || null,
                    customer_name: customerName,
                    customer_email: customerEmail,
                    total_amount: totalAmount,
                    status: 'pending',
                    slip_url: slipUrl,
                    order_date: new Date().toISOString()
                }])
                .select()
                .single();

            if (orderError) throw orderError;

            // บันทึกรายการย่อยลงตาราง order_items
            if (items && items.length > 0) {
                const orderItems = items.map(item => ({
                    order_id: orderId,
                    ebook_id: item.id || item.ebook_id,
                    book_title: item.title,
                    price: item.price,
                    quantity: item.quantity || 1
                }));

                const { error: itemsError } = await this.client
                    .from('order_items')
                    .insert(orderItems);

                if (itemsError) throw itemsError;
            }

            return orderData;
        },

        // 5. ดึงรายการคำสั่งซื้อ (สำหรับแอดมินหรือผู้ใช้)
        async getOrders(userId = null) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            let query = this.client
                .from('orders')
                .select('*, order_items(*)')
                .order('created_at', { ascending: false });

            if (userId) {
                query = query.eq('user_id', userId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data;
        },

        // 6. อนุมัติคำสั่งซื้อและปลดล็อกหนังสือเข้า user_library
        async approveOrder(orderId) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');

            // อัปเดตสถานะ orders เป็น approved
            const { data: order, error: updateError } = await this.client
                .from('orders')
                .update({ status: 'approved' })
                .eq('order_id', orderId)
                .select('*, order_items(*)')
                .single();

            if (updateError) throw updateError;

            // เพิ่มหนังสือลงใน user_library
            if (order && order.user_id && order.order_items) {
                const libraryEntries = order.order_items.map(item => ({
                    user_id: order.user_id,
                    ebook_id: item.ebook_id,
                    order_id: orderId,
                    access_granted_at: new Date().toISOString()
                }));

                await this.client
                    .from('user_library')
                    .upsert(libraryEntries, { onConflict: 'user_id,ebook_id' });
            }

            return order;
        },

        // 7. ดึงหนังสือในคลังของผู้ใช้ (my-books)
        async getUserLibrary(userId) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('user_library')
                .select(`
                    library_id,
                    access_granted_at,
                    ebooks (
                        ebook_id,
                        title,
                        author_name,
                        cover_image,
                        download_url,
                        description
                    )
                `)
                .eq('user_id', userId);

            if (error) throw error;
            return data;
        },

        // 8. ดึงรีวิวของหนังสือ
        async getBookReviews(ebookId) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('book_reviews')
                .select('*, profiles(username, full_name, avatar_url)')
                .eq('ebook_id', ebookId)
                .order('created_at', { ascending: false });

            if (error) throw error;
            return data;
        },

        // 9. เพิ่มรีวิว
        async addReview({ ebookId, userId, rating, comment }) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('book_reviews')
                .insert([{
                    ebook_id: ebookId,
                    user_id: userId,
                    rating,
                    comment
                }])
                .select();

            if (error) throw error;
            return data;
        },

        // 10. ดึงรายการสินค้าในตะกร้าจาก Supabase (cart_items)
        async getCartItems(username = 'user') {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('cart_items')
                .select('*')
                .eq('username', username)
                .order('cart_item_id', { ascending: false });

            if (error) throw error;
            return data;
        },

        // 11. เพิ่มสินค้าลงตะกร้าใน Supabase
        async addToCartDb({ username = 'user', ebookId, bookTitle, price, quantity = 1 }) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('cart_items')
                .insert([{
                    username,
                    ebook_id: ebookId,
                    book_title: bookTitle,
                    price,
                    quantity
                }])
                .select();

            if (error) throw error;
            return data;
        },

        // 12. ล้างตะกร้าใน Supabase
        async clearCartDb(username = 'user') {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('cart_items')
                .delete()
                .eq('username', username);

            if (error) throw error;
            return data;
        },

        // 13. ดึงรายชื่อผู้ใช้จากตาราง users
        async getUsers() {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('users')
                .select('user_id, username, name, email, role, avatar');

            if (error) throw error;
            return data;
        },

        // 14. เพิ่มผู้ใช้ใหม่ลงในตาราง users
        async createUser(userData) {
            if (!this.client) throw new Error('Supabase client ยังไม่ได้เชื่อมต่อ');
            const { data, error } = await this.client
                .from('users')
                .insert([userData])
                .select();

            if (error) throw error;
            return data && data[0] ? data[0] : null;
        }
    };

    window.bookcoolDb = db;
})(window);
