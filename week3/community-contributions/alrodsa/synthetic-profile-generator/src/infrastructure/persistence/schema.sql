CREATE TABLE IF NOT EXISTS profiles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    country TEXT NOT NULL,
    city TEXT NOT NULL,
    occupation TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    bio TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS interests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS profile_interests (
    profile_id INTEGER NOT NULL,
    interest_id INTEGER NOT NULL,
    PRIMARY KEY (profile_id, interest_id),
    FOREIGN KEY (profile_id) REFERENCES profiles(id),
    FOREIGN KEY (interest_id) REFERENCES interests(id)
);
