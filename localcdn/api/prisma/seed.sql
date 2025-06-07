-- CREATE TABLE IF NOT EXISTS User (
--   id INT AUTO_INCREMENT PRIMARY KEY,
--   account VARCHAR(255) NOT NULL
-- );

CREATE TABLE IF NOT EXISTS Course (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  rounds INT NOT NULL
);

CREATE TABLE IF NOT EXISTS Game (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATETIME NOT NULL,
  courseId INT NOT NULL,
  userId INT NOT NULL,
  finalNote TEXT,
  finalScore INT,
  FOREIGN KEY (courseId) REFERENCES Course(id),
  FOREIGN KEY (userId)   REFERENCES User(id)
);

CREATE TABLE IF NOT EXISTS Score (
  id INT AUTO_INCREMENT PRIMARY KEY,
  gameId INT NOT NULL,
  hole INT NOT NULL,
  par VARCHAR(10) NOT NULL,
  score VARCHAR(10) NOT NULL,
  rating INT NOT NULL,
  FOREIGN KEY (gameId) REFERENCES Game(id)
);

-- Seed some example data
INSERT INTO User (account) VALUES ('alice'), ('bob');

INSERT INTO Course (name, rounds) VALUES 
  ('Front 9', 9), 
  ('Back 9', 9);

INSERT INTO Game (date, courseId, userId, finalNote, finalScore) VALUES
 ('2025-06-01 09:00:00', 1, 1, 'Great round!', 42),
 ('2025-06-02 10:00:00', 2, 2, 'Tough course', 50);

INSERT INTO Score (gameId, hole, par, score, rating) VALUES
 (1, 1, '4', '5', 3),
 (1, 2, '3', '3', 4),
 (2, 1, '4', '6', 2),
 (2, 2, '3', '4', 2);