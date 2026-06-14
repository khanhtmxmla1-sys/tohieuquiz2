-- Complete D1 Schema Initialization

-- ============================================
-- CORE TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS quizzes (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    created_by TEXT,
    questions TEXT,
    time_limit INTEGER DEFAULT 0,
    passing_score REAL DEFAULT 50,
    is_published INTEGER DEFAULT 0,
    created_at TEXT,
    updated_at TEXT
);

CREATE TABLE IF NOT EXISTS questions (
    id TEXT PRIMARY KEY,
    quiz_id TEXT NOT NULL,
    type TEXT DEFAULT 'multiple_choice',
    question TEXT NOT NULL,
    options TEXT, -- JSON array
    correct_answer TEXT,
    explanation TEXT,
    items TEXT, -- For matching questions
    text_field TEXT, -- For fill-in-the-blank
    blanks TEXT, -- JSON array
    distractors TEXT,
    sentence TEXT,
    words TEXT, -- JSON array
    correct_word_indexes TEXT, -- JSON array
    image TEXT,
    tags TEXT, -- For filtering/practice
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

CREATE TABLE IF NOT EXISTS results (
    id TEXT PRIMARY KEY,
    student_name TEXT NOT NULL,
    class_name TEXT,
    quiz_id TEXT NOT NULL,
    quiz_title TEXT,
    score REAL,
    correct_count INTEGER,
    total_questions INTEGER,
    time_taken INTEGER,
    answers TEXT, -- JSON object
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

CREATE TABLE IF NOT EXISTS announcements (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    author TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS classroom_assignments (
    id TEXT PRIMARY KEY,
    teacher_username TEXT NOT NULL,
    quiz_id TEXT NOT NULL,
    class_name TEXT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date TIMESTAMP,
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
    FOREIGN KEY (teacher_username) REFERENCES teachers(username)
);

CREATE TABLE IF NOT EXISTS classroom_students (
    id TEXT PRIMARY KEY,
    class_name TEXT NOT NULL,
    student_name TEXT NOT NULL,
    student_id TEXT,
    UNIQUE(class_name, student_name)
);

-- ============================================
-- GAME LOOP TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS student_game_profiles (
    username TEXT PRIMARY KEY,
    daily_streak INTEGER DEFAULT 0,
    last_mission_completion_date TEXT,
    hint_tokens INTEGER DEFAULT 5,
    streak_shields INTEGER DEFAULT 2,
    collection_json TEXT, -- JSON for pet/character collection
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS student_daily_progress (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    progress_date TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(username, progress_date),
    FOREIGN KEY (username) REFERENCES student_game_profiles(username)
);

CREATE TABLE IF NOT EXISTS student_weekly_progress (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    week_key TEXT NOT NULL,
    quest_id TEXT NOT NULL,
    progress INTEGER DEFAULT 0,
    target INTEGER DEFAULT 0,
    claimed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(username, week_key, quest_id),
    FOREIGN KEY (username) REFERENCES student_game_profiles(username)
);

CREATE TABLE IF NOT EXISTS student_achievement_unlocks (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    achievement_code TEXT NOT NULL,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(username, achievement_code),
    FOREIGN KEY (username) REFERENCES student_game_profiles(username)
);

CREATE TABLE IF NOT EXISTS student_reward_events (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    event_type TEXT,
    reward_points INTEGER DEFAULT 0,
    details TEXT, -- JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES student_game_profiles(username)
);

CREATE TABLE IF NOT EXISTS student_game_activity_events (
    id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    activity_type TEXT,
    activity_details TEXT, -- JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES student_game_profiles(username)
);

-- ============================================
-- LIVE EXAM TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS live_exams (
    id TEXT PRIMARY KEY,
    teacher_username TEXT NOT NULL,
    quiz_id TEXT NOT NULL,
    room_code TEXT UNIQUE,
    question_display_mode TEXT DEFAULT 'one_by_one',
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    FOREIGN KEY (teacher_username) REFERENCES teachers(username),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
);

CREATE TABLE IF NOT EXISTS live_exam_participants (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    current_question_index INTEGER DEFAULT 0,
    status TEXT DEFAULT 'connected',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES live_exams(id)
);

CREATE TABLE IF NOT EXISTS live_exam_answers (
    id TEXT PRIMARY KEY,
    exam_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    question_index INTEGER,
    answer TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES live_exams(id)
);

-- ============================================
-- UTILITY TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS system_settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS teacher_ai_daily_usage (
    id TEXT PRIMARY KEY,
    teacher_username TEXT NOT NULL,
    usage_date TEXT NOT NULL,
    generation_count INTEGER DEFAULT 0,
    UNIQUE(teacher_username, usage_date),
    FOREIGN KEY (teacher_username) REFERENCES teachers(username)
);

CREATE TABLE IF NOT EXISTS attendance_claims (
    id TEXT PRIMARY KEY,
    student_name TEXT NOT NULL,
    claim_date TEXT NOT NULL,
    points_earned INTEGER DEFAULT 5,
    UNIQUE(student_name, claim_date),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rag_documents (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rag_chunks (
    id TEXT PRIMARY KEY,
    doc_id TEXT NOT NULL,
    chunk_text TEXT NOT NULL,
    chunk_index INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (doc_id) REFERENCES rag_documents(id)
);

CREATE TABLE IF NOT EXISTS rag_query_logs (
    id TEXT PRIMARY KEY,
    query TEXT,
    result_doc_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_questions_quiz_id ON questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_results_student ON results(student_name);
CREATE INDEX IF NOT EXISTS idx_results_quiz ON results(quiz_id);
CREATE INDEX IF NOT EXISTS idx_results_submitted ON results(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_classroom_students_class ON classroom_students(class_name);
CREATE INDEX IF NOT EXISTS idx_game_profiles_username ON student_game_profiles(username);
CREATE INDEX IF NOT EXISTS idx_daily_progress_date ON student_daily_progress(progress_date);
CREATE INDEX IF NOT EXISTS idx_live_exams_active ON live_exams(is_active);
CREATE INDEX IF NOT EXISTS idx_live_exam_participants_exam ON live_exam_participants(exam_id);
CREATE INDEX IF NOT EXISTS idx_questions_tags ON questions(tags);
