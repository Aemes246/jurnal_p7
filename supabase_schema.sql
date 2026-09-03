-- ==============================================================================
-- SUPABASE DATABASE SCHEMA: JURNAL 7 KEBIASAAN ANAK INDONESIA HEBAT (SMKN 7 SAMARINDA)
-- ==============================================================================

-- 1. Create Profiles Table (Biodata Siswa "Ayo Berkenalan!")
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    role TEXT DEFAULT 'siswa',
    religion TEXT DEFAULT 'Islam',
    address TEXT,
    hobby TEXT,
    ambition TEXT,
    favorite_sport TEXT,
    favorite_food TEXT,
    favorite_subject TEXT,
    uniqueness TEXT,
    homeroom_teacher TEXT,
    homeroom_teacher_signature TEXT,
    total_streak INT DEFAULT 0,
    total_points INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Habits Table (7 Kebiasaan Baik SMKN 7 Samarinda)
CREATE TABLE IF NOT EXISTS public.habits (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    points INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed 7 Fixed Habits
INSERT INTO public.habits (id, title, description, category, icon_name, points) VALUES
('h1', '1. Bangun Pagi', 'Bangun di pagi hari dengan segar, merapikan tempat tidur, dan siap beraktivitas.', 'kesehatan', 'sun', 10),
('h2', '2. Beribadah', 'Melaksanakan ibadah tepat waktu sesuai ajaran agama dan kepercayaan.', 'ibadah', 'mosque', 10),
('h3', '3. Berolahraga', 'Melakukan senam/peregangan atau olahraga fisik minimal 15-30 menit.', 'kesehatan', 'run', 10),
('h4', '4. Makan Sehat dan Bergizi', 'Mengkonsumsi makanan 4 sehat 5 sempurna dan banyak minum air putih.', 'kesehatan', 'food', 10),
('h5', '5. Gemar Belajar', 'Membaca buku, mengulang materi sekolah, atau membaca Al-Qur''an/kitab suci.', 'belajar', 'book', 10),
('h6', '6. Bermasyarakat', 'Bergotong-royong, membantu orang tua/teman, dan bersosialisasi dengan santun.', 'kedisiplinan', 'people', 10),
('h7', '7. Tidur Cepat', 'Istirahat dan tidur tepat waktu (maksimal pukul 21.30/22.00 WITA).', 'kesehatan', 'bed', 10)
ON CONFLICT (id) DO NOTHING;

-- 3. Create Habit Logs Table (Form Bukti & Penjelasan Foto Kegiatan)
CREATE TABLE IF NOT EXISTS public.habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id TEXT REFERENCES public.habits(id) ON DELETE CASCADE,
    habit_title TEXT NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_completed BOOLEAN DEFAULT TRUE,
    detail_type TEXT,
    note TEXT,
    photo_url TEXT,
    religion TEXT,
    earned_points INT DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Allow public read on profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Allow users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow public read on habits" ON public.habits FOR SELECT USING (true);

CREATE POLICY "Allow users read own habit logs" ON public.habit_logs FOR SELECT USING (true);
CREATE POLICY "Allow users insert habit logs" ON public.habit_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
