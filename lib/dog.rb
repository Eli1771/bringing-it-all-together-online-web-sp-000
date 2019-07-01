class Dog 
  attr_accessor :id, :name, :breed 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT, 
        breed TEXT 
        );
      SQL
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = <<-SQL 
      DROP TABLE IF EXISTS dogs 
      SQL
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ? 
      SQL
    row = DB[:conn].execute(sql, name)[0]
    dog = self.new(id: row[0], name: name, breed: row[2])
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = ?
      SQL
    row = DB[:conn].execute(sql, id)[0]
    dog = self.new(id: id, name: row[1], breed: row[2])
  end
  
  def update 
    sql = <<-SQL 
      UPDATE dogs 
      SET name = ?, breed = ? 
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL 
      SELECT * FROM dogs 
      WHERE name = ?
      SQL
    row = DB[:conn].execute(sql, name)[0] 
    if !row.empty? && breed == row[2]
      dog = self.new(id: row[0], name: row[1], breed: row[2])
      else 
        self.create(name: name, breed: breed)
      end 
    else 
      self.create(name: name, breed: breed)
    end
  end
  
  def save 
    sql = <<-SQL 
      INSERT INTO dogs (name, breed) 
      VALUES (?, ?)
      SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end 
  
  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end 
end 