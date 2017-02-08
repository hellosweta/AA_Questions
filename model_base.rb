class ModelBase
  def self.find_by_id(id)
    modelbase = QuestionsDatabase.instance.execute(<<-SQL, id)
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
end
