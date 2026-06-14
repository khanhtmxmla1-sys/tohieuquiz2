CREATE TABLE IF NOT EXISTS teachers (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name TEXT,
    email TEXT,
    class TEXT,
    role TEXT DEFAULT 'teacher',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO teachers (id, username, password, full_name, email, class, role) 
VALUES ('admin_viethong', 'viethong', 'bbafcaf5881fc1116410e98974c5b665e3dd2ddeb4fd932132781c3b3fd22a76', 'Viết Hồng', 'viethong@thtohieu.com', 'Admin', 'admin');
