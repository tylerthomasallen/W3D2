PRAGMA foreign_keys = ON;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (parent_id) REFERENCES replies(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Barack', 'Obama'), ('Harry', 'Potter'),("Ned", "Ruggeri"), ("Kush", "Patel"), ("Earl", "Cat");
  
INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Help', 'What do I do with all this free time?', (SELECT id FROM users WHERE fname = 'Barack' AND lname = 'Obama')),
  ('Lost', 'Harry Potter ended over ten years ago, what now?', (SELECT id FROM users WHERE fname = 'Harry' AND lname = 'Potter'));
  
INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Barack' AND lname = 'Obama'), (SELECT id FROM questions WHERE title = 'Lost')),
  ((SELECT id FROM users WHERE fname = 'Harry' AND lname = 'Potter'), (SELECT id FROM questions WHERE title = 'Help'));

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = 'Help'), null, (SELECT id FROM users WHERE fname = 'Harry'), 'Hello Barack, I''m sad too. I hope that conforts you.'),
  ((SELECT id FROM questions WHERE title = 'Lost'), null, (SELECT id FROM users WHERE fname = 'Barack'), 'Hello Harry, get into politics!');
  
INSERT INTO 
  question_likes (user_id,question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Barack' AND lname = 'Obama'), (SELECT id FROM questions WHERE title = 'Lost')),
  ((SELECT id FROM users WHERE fname = 'Harry' AND lname = 'Potter'), (SELECT id FROM questions WHERE title = 'Help'));
  
  INSERT INTO
    questions (title, body, user_id)
  SELECT
    "Ned Question", "NED NED NED", 1
  FROM
    users
  WHERE
    users.fname = "Ned" AND users.lname = "Ruggeri";

  INSERT INTO
    questions (title, body, user_id)
  SELECT
    "Kush Question", "KUSH KUSH KUSH", users.id
  FROM
    users
  WHERE
    users.fname = "Kush" AND users.lname = "Patel";

  INSERT INTO
    questions (title, body, user_id)
  SELECT
    "Earl Question", "MEOW MEOW MEOW", users.id
  FROM
    users
  WHERE
    users.fname = "Earl" AND users.lname = "Cat";
    
  INSERT INTO
    question_follows (user_id, question_id)
  VALUES
    ((SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
    (SELECT id FROM questions WHERE title = "Earl Question")),

    ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
    (SELECT id FROM questions WHERE title = "Earl Question")
  );
  
INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  NULL,
  (SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  "Did you say NOW NOW NOW?"
);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"),
  (SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  "I think he said MEOW MEOW MEOW."
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question"),
  (SELECT id FROM users WHERE fname = "Barack" AND lname = "Obama"),
  (SELECT id FROM questions WHERE title = "Earl Question")
  
);
