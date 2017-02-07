require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions

    questions = Question.find_by_author_id(@id)
    return nil if questions.empty?
    questions
  end

  def authored_replies
    replies = Reply.find_by_user_id(@id)
    return nil if replies.empty?
    replies
  end
end

class Question
  attr_accessor :title, :body, :associated_author_id

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    return nil if question.empty?
    Question.new(question.first)
  end

  def self.find_by_author_id(associated_author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, associated_author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        associated_author_id = ?
    SQL
    return nil if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @associated_author_id = options['associated_author_id']
  end

  def author
    author = User.find_by_id(@associated_author_id)
    return nil if author.nil?
    author
  end

  def replies
    replies = Reply.find_by_question_id(@id)
    return nil if replies.empty?
    replies
  end
end

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
  # 
  # def self.followers_for_question_id(question_id)
  #
  # end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end

class Reply
  attr_accessor :id, :subject_question_id, :parent_reply_id, :user_id, :body

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(subject_question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, subject_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
    SQL
    return nil if replies.empty?
    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    user = User.find_by_id(@user_id)
    return nil if user.nil?
    user
  end

  def question
    question = Question.find_by_id(@subject_question_id)
    return nil if question.nil?
    question
  end

  def parent_reply
    reply = Reply.find_by_id(@parent_reply_id)
    return nil if reply.nil?
    reply
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id, @subject_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ? AND subject_question_id = ?
    SQL
    return nil if reply.empty?
    Reply.new(reply.first)
  end
end

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

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
