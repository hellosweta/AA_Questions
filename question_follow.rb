require 'sqlite3'
require_relative 'questions'

class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    return nil if question_follow.empty?
    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
        JOIN question_follows ON users.id = question_follows.user_id

      WHERE
        question_follows.question_id = ?
    SQL
    return nil if followers.empty?
    followers.map { |follower| User.new(follower) }
  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
        JOIN question_follows ON questions.id = question_follows.question_id

      WHERE
        question_follows.user_id = ?
    SQL
    return nil if followed_questions.empty?
    followed_questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.associated_author_id
      FROM
        questions
        JOIN question_follows ON questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        count(*) DESC --study!
      LIMIT 1 OFFSET ? - 1
    SQL
    return nil if followed_questions.empty?
    followed_questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end
