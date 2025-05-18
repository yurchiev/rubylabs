require 'yaml'
require 'json'

class ExpenseManager
  FILE_JSON = 'storage/expenses.json'
  FILE_YAML = 'storage/expenses.yaml'

  def initialize
    @expenses = {}
  end

  def run
    add_expense("Покупка продуктів", 450, ["Їжа", "Домашнє"], ["Готівка", "Карта"])
    add_expense("Абонемент у спортзал", 800, ["Здоров'я"], ["Карта"])
    add_expense("Книга", 200, ["Освіта", "Дозвілля"], ["Готівка"])

    list_expenses

    edit_expense("Книга", 250, ["Освіта"], ["Карта"])

    search_expense("спорт")

    delete_expense("Абонемент у спортзал")

    save_to_json
    save_to_yaml

    @expenses = {}
    load_from_json
    load_from_yaml

    list_expenses
  end

  def list_expenses
    if @expenses.empty?
      puts "Витрати відсутні."
    else
      puts "\nСписок витрат:"
      @expenses.each_with_index do |(name, data), index|
        puts "#{index + 1}. #{name}: #{data[:amount]} грн | Категорії: #{data[:categories].join(', ')} | Оплата: #{data[:payment_methods].join(', ')}"
      end
    end
  end

  def add_expense(name, amount, categories, payment_methods)
    if @expenses.key?(name)
      puts "Витрата вже існує. Використайте редагування."
    else
      @expenses[name] = {
        amount: amount,
        categories: categories,
        payment_methods: payment_methods
      }
      puts "Витрату '#{name}' додано."
    end
  end

  def edit_expense(name, new_amount, new_categories, new_payment_methods)
    if @expenses.key?(name)
      @expenses[name] = {
        amount: new_amount,
        categories: new_categories,
        payment_methods: new_payment_methods
      }
      puts "Витрату '#{name}' оновлено."
    else
      puts "Витрату не знайдено."
    end
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
      puts "Витрати не знайдені."
    else
      puts "Знайдені витрати:"
      results.each_with_index do |(name, data), index|
        puts "#{index + 1}. #{name}: #{data[:amount]} грн | Категорії: #{data[:categories].join(', ')} | Оплата: #{data[:payment_methods].join(', ')}"
      end
    end
  end

  def save_to_json
    File.write(FILE_JSON, JSON.pretty_generate(@expenses))
    puts "Витрати збережено у JSON."
  end

  def save_to_yaml
    File.write(FILE_YAML, @expenses.to_yaml)
    puts "Витрати збережено у YAML."
  end

  def load_from_json
    if File.exist?(FILE_JSON)
      raw = JSON.parse(File.read(FILE_JSON))
      @expenses = raw.transform_values do |data|
        {
          amount: data["amount"],
          categories: data["categories"],
          payment_methods: data["payment_methods"]
        }
      end
      puts "Витрати завантажено з JSON."
    else
      puts "Файл JSON не знайдено."
    end
  end

  def load_from_yaml
    if File.exist?(FILE_YAML)
      @expenses = YAML.load_file(FILE_YAML)
      puts "Витрати завантажено з YAML."
    else
      puts "Файл YAML не знайдено."
    end
  end
end

ExpenseManager.new.run
