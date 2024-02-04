CREATE TABLE IF NOT EXISTS member (
    id              INTEGER NOT NULL PRIMARY KEY,
    login_id        VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    password_salt   VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS whitelist (
    id              INTEGER NOT NULL PRIMARY KEY,
    member_id       INTEGER NOT NULL,
    ip_address      VARCHAR(255) NOT NULL,
    last_update     DATETIME NOT NULL
);