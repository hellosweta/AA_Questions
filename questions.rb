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

class Question
  attr_accessor :id, :title, :body, :associated_author_id

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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
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

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def save

    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @associated_author_id)
        INSERT INTO
          questions (title, body, associated_author_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @associated_author_id, @id)
        UPDATE
          questions
        SET
          title = ?, body = ?, associated_author_id = ?
        WHERE
          id = ?
      SQL
    end

  end

end
