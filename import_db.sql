DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  associated_author_id INTEGER NOT NULL,

  FOREIGN KEY (associated_author_id) REFERENCES users(id)
);

DROP TABLE if exists question_follows;
--Join Table

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id), --self referential
  FOREIGN KEY (user_id) REFERENCES users(id)

);
DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Arthur', 'Miller'),
  ('Belle', 'Childs'),
  ('Bill', 'Nye'),
  ('Bernie', 'Sanders'),
  ('Miss', 'Frizzle');

INSERT INTO
  questions (title, body, associated_author_id)
VALUES
  ('Arf?', 'What should I chew?', (SELECT id FROM users WHERE fname = 'Belle')),
  ('What should we do now?', 'To bring down the establishment??', (SELECT id FROM users WHERE fname = 'Bernie')),
  ('Snot', 'Why is it green? Seatbelts everyone!', (SELECT id FROM users WHERE lname = 'Frizzle'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  (1,1),
  (1,2),
  (2,1),
  (3,3),
  (3,4),
  (3,5);

INSERT INTO
  replies (subject_question_id, parent_reply_id, user_id, body)
VALUES
  (1, NULL,(SELECT id FROM users WHERE fname = 'Bernie'), 'Wall Street!'),

  (1, 1,(SELECT id FROM users WHERE fname = 'Bill'), 'Knowledge!'),

  (2, NULL, (SELECT id FROM users WHERE fname = 'Miss'), 'Organize science teachers to join the resistence! #AltNPS'),

  (2, 3, (SELECT id FROM users WHERE fname = 'Belle'), 'Woof!'),

  (3, NULL, (SELECT id FROM users WHERE fname = 'Bill'), 'I''m in!');


INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1,1),
  (1,2),
  (2,1),
  (3,3),
  (4,3),
  (5,2);
