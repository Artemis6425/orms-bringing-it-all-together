class Dog
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end
    attr_accessor :name, :breed, :id
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end
    def save
        sql ="INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
    def self.create(new)
        name = new[:name]
        breed = new[:breed]
        temp = Dog.new(name: name, breed: breed)
        temp.save
    end
    def self.new_from_db(new)
        id = new[0]
        name = new[1]
        breed = new[2]
        temp = Dog.new(id: id, name: name, breed: breed)
    end
    def self.find_by_id(id)
        sql ="SELECT * FROM dogs WHERE id = ?"
        id = DB[:conn].execute(sql, id)
        self.new_from_db(id[0])
    end
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            new = dog[0]
            dog = Dog.new(id: new[0], name: new[1], breed: new[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end
    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
        self.new_from_db(dog[0])
    end
    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end
end