require 'sqlite3'
require_relative 'questions'

class QuestionLike
  attr_accessor :user_id, :question_id

  def self.find_by_id(id)
    question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil if question_like.empty?
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
        JOIN question_likes ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    return nil if likers.empty?
    likers.map { |liker| User.new(liker) }
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        count(*) AS COUNT
      FROM
        questions
        JOIN question_likes ON questions.id = question_likes.question_id
      WHERE
        question_likes.question_id = ?
      GROUP BY
        questions.id

    SQL
    return nil if likes.empty?
    likes.first["COUNT"]

  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
        JOIN question_likes ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?

    SQL
    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
        JOIN question_likes ON questions.id = question_likes.question_id

      GROUP BY
        questions.id
      ORDER BY
        count(*) DESC
      LIMIT ?
    SQL
    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
