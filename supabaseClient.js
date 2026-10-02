import { createClient } from '@supabase/supabase-js';

// อ่านค่า Environment Variables ตามมาตรฐาน Vite
// (หากใช้ใน Next.js ให้เปลี่ยนเป็น process.env.NEXT_PUBLIC_SUPABASE_URL)
const supabaseUrl = import.meta.env?.VITE_SUPABASE_URL || 'https://your-project-id.supabase.co';
const supabaseAnonKey = import.meta.env?.VITE_SUPABASE_ANON_KEY || 'your-anon-key-here';

if (!supabaseUrl || !supabaseAnonKey || supabaseUrl.includes('your-project-id')) {
    console.warn('⚠️ [Supabase] กรุณาตั้งค่า VITE_SUPABASE_URL และ VITE_SUPABASE_ANON_KEY ในไฟล์ .env');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true
    }
});

export default supabase;
