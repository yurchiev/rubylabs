require 'yaml'
require 'json'

class ExpenseManager
  FILE_JSON = 'storage/expenses.json'
  FILE_YAML = 'storage/expenses.yaml'

  def initialize
    @expenses = {}
  end

  def run
    loop do
      puts "\nМеню:"
      puts "1. Додати витрату"
      puts "2. Редагувати витрату"
      puts "3. Видалити витрату"
      puts "4. Пошук витрати"
      puts "5. Показати всі витрати"
      puts "6. Зберегти у JSON"
      puts "7. Зберегти у YAML"
      puts "8. Завантажити з JSON"
      puts "9. Завантажити з YAML"
      puts "0. Вийти"
      print "Оберіть дію: "
      choice = gets.chomp

      case choice
      when "1"
        add_expense_prompt
      when "2"
        edit_expense_prompt
      when "3"
        delete_expense_prompt
      when "4"
        search_expense_prompt
      when "5"
        list_expenses
      when "6"
        save_to_json
      when "7"
        save_to_yaml
      when "8"
        load_from_json
      when "9"
        load_from_yaml
      when "0"
        puts "До побачення!"
        break
      else
        puts "Невірний вибір. Спробуйте ще раз."
      end
    end
  end

  def add_expense_prompt
    print "Назва витрати: "
    name = gets.chomp

    if @expenses.key?(name)
      puts "Витрата з такою назвою вже існує."
      return
    end

    print "Сума (грн): "
    amount = gets.chomp.to_f

    print "Категорії (через кому): "
    categories = gets.chomp.split(',').map(&:strip)

    print "Способи оплати (через кому): "
    payment_methods = gets.chomp.split(',').map(&:strip)

    add_expense(name, amount, categories, payment_methods)
  end

  def edit_expense_prompt
    print "Назва витрати для редагування: "
    name = gets.chomp

    unless @expenses.key?(name)
      puts "Витрату не знайдено."
      return
    end

    print "Нова сума (грн): "
    amount = gets.chomp.to_f

    print "Нові категорії (через кому): "
    categories = gets.chomp.split(',').map(&:strip)

    print "Нові способи оплати (через кому): "
    payment_methods = gets.chomp.split(',').map(&:strip)

    edit_expense(name, amount, categories, payment_methods)
  end

  def delete_expense_prompt
    print "Назва витрати для видалення: "
    name = gets.chomp
    delete_expense(name)
  end

  def search_expense_prompt
    print "Введіть пошуковий запит: "
    query = gets.chomp
    search_expense(query)
  end

  def add_expense(name, amount, categories, payment_methods)
    @expenses[name] = {
      amount: amount,
      categories: categories,
      payment_methods: payment_methods
    }
    puts "Витрату '#{name}' додано."
  end

  def edit_expense(name, new_amount, new_categories, new_payment_methods)
    @expenses[name] = {
      amount: new_amount,
      categories: new_categories,
      payment_methods: new_payment_methods
    }
    puts "Витрату '#{name}' оновлено."
  end

  def delete_expense(name)
    if @expenses.delete(name)
      puts "Витрату '#{name}' видалено."
    else
      puts "Витрату не знайдено."
    end
  end

  def search_expense(query)
    results = @expenses.select { |name, _| name.downcase.include?(query.downcase) }
    if results.empty?
      puts "Нічого не знайдено."
    else
      results.each_with_index do |(name, data), index|
        puts "#{index + 1}. #{name}: #{data[:amount]} грн | Категорії: #{data[:categories].join(', ')} | Оплата: #{data[:payment_methods].join(', ')}"
      end
    end
  end

  def list_expenses
    if @expenses.empty?
      puts "Список витрат порожній."
    else
      puts "\nСписок витрат:"
      @expenses.each_with_index do |(name, data), index|
        puts "#{index + 1}. #{name}: #{data[:amount]} грн | Категорії: #{data[:categories].join(', ')} | Оплата: #{data[:payment_methods].join(', ')}"
      end
    end
  end

  def save_to_json
    File.write(FILE_JSON, JSON.pretty_generate(@expenses))
    puts "Збережено у JSON."
  end

  def save_to_yaml
    File.write(FILE_YAML, @expenses.to_yaml)
    puts "Збережено у YAML."
  end

  def load_from_json
    print "Введіть шлях до JSON-файлу (наприклад, storage/expenses.json): "
    path = gets.chomp.strip

    if File.exist?(path) && File.size?(path)
      begin
        raw = JSON.parse(File.read(path))
        @expenses = raw.transform_values do |data|
          {
            amount: data["amount"],
            categories: data["categories"],
            payment_methods: data["payment_methods"]
          }
        end
        puts "Дані успішно завантажено з JSON."
      rescue JSON::ParserError => e
        puts "Помилка розбору JSON: #{e.message}"
      end
    else
      puts "Файл не знайдено або він порожній."
    end
  end

  def load_from_yaml
    print "Введіть шлях до YAML-файлу (наприклад, storage/expenses.yaml): "
    path = gets.chomp.strip

    if File.exist?(path) && File.size?(path)
      begin
        @expenses = YAML.load_file(path)
        puts "Дані успішно завантажено з YAML."
      rescue Psych::SyntaxError => e
        puts "Помилка розбору YAML: #{e.message}"
      end
    else
      puts "Файл не знайдено або він порожній."
    end
  end


  ExpenseManager.new.run
end
