require 'yaml'
require 'json'

class Expense
  attr_accessor :name, :amount, :categories, :payment_methods

  def initialize(name, amount, categories, payment_methods)
    @name = name.strip
    @amount = amount.to_f
    @categories = categories.map(&:strip)
    @payment_methods = payment_methods.map(&:strip)
  end

  def to_h
    {
      amount: amount,
      categories: categories,
      payment_methods: payment_methods
    }
  end
end

class ExpenseManager
  FILE_JSON = 'storage/expenses.json'
  FILE_YAML = 'storage/expenses.yaml'

  def initialize
    @expenses = {}
  end

  def run
    loop do
      puts "\n--- Менеджер витрат ---"
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
      print "Ваш вибір: "

      case gets.chomp
      when "1" then add_expense
      when "2" then edit_expense
      when "3" then delete_expense
      when "4" then search_expense
      when "5" then list_expenses
      when "6" then save_to_json
      when "7" then save_to_yaml
      when "8" then load_from_json
      when "9" then load_from_yaml
      when "0" then puts "До побачення!"; break
      else puts "Невірний вибір. Спробуйте ще раз."
      end
    end
  end

  def add_expense
    print "Назва витрати: "
    name = gets.strip
    if @expenses.key?(name)
      puts "Витрата з такою назвою вже існує."
      return
    end

    print "Сума (грн): "
    amount = gets.strip

    print "Категорії (через кому): "
    categories = gets.strip.split(',')

    print "Способи оплати (через кому): "
    payments = gets.strip.split(',')

    expense = Expense.new(name, amount, categories, payments)
    @expenses[name] = expense
    puts "Витрату '#{name}' додано."
  end

  def edit_expense
    print "Назва витрати для редагування: "
    name = gets.strip

    unless @expenses.key?(name)
      puts "Витрату не знайдено."
      return
    end

    print "Нова сума (грн): "
    amount = gets.strip

    print "Нові категорії (через кому): "
    categories = gets.strip.split(',')

    print "Нові способи оплати (через кому): "
    payments = gets.strip.split(',')

    @expenses[name] = Expense.new(name, amount, categories, payments)
    puts "Витрату '#{name}' оновлено."
  end

  def delete_expense
    print "Назва витрати для видалення: "
    name = gets.strip
    if @expenses.delete(name)
      puts "Витрату '#{name}' видалено."
    else
      puts "Витрату не знайдено."
    end
  end

  def search_expense
    print "Введіть пошуковий запит: "
    query = gets.strip.downcase
    results = @expenses.select { |name, _| name.downcase.include?(query) }

    if results.empty?
      puts "Нічого не знайдено."
    else
      results.each_with_index do |(name, exp), index|
        puts "#{index + 1}. #{name}: #{exp.amount} грн | Категорії: #{exp.categories.join(', ')} | Оплата: #{exp.payment_methods.join(', ')}"
      end
    end
  end

  def list_expenses
    if @expenses.empty?
      puts "Список витрат порожній."
    else
      puts "\nСписок витрат:"
      @expenses.each_with_index do |(name, exp), index|
        puts "#{index + 1}. #{name}: #{exp.amount} грн | Категорії: #{exp.categories.join(', ')} | Оплата: #{exp.payment_methods.join(', ')}"
      end
    end
  end

  def save_to_json
    data = @expenses.transform_values(&:to_h)
    File.write(FILE_JSON, JSON.pretty_generate(data))
    puts "Збережено у JSON."
  end

  def save_to_yaml
    data = @expenses.transform_values(&:to_h)
    File.write(FILE_YAML, data.to_yaml)
    puts "Збережено у YAML."
  end

  def load_from_json
    if File.exist?(FILE_JSON)
      raw = JSON.parse(File.read(FILE_JSON))
      @expenses = raw.transform_keys(&:to_s).transform_values do |data|
        Expense.new(
          "", data["amount"], data["categories"], data["payment_methods"]
        ).tap { |e| e.name = data["name"] || "" }
      end
      puts "Дані завантажено з JSON."
    else
      puts "Файл JSON не знайдено."
    end
  end

  def load_from_yaml
    if File.exist?(FILE_YAML)
      raw = YAML.load_file(FILE_YAML)
      @expenses = raw.transform_keys(&:to_s).transform_values do |data|
        Expense.new(
          "", data["amount"], data["categories"], data["payment_methods"]
        ).tap { |e| e.name = data["name"] || "" }
      end
      puts "Дані завантажено з YAML."
    else
      puts "Файл YAML не знайдено."
    end
  end
end

ExpenseManager.new.run
