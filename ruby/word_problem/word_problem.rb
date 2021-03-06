require 'pry'
class WordProblem

  attr_reader :phrase_elements, :numbers, :operators, :pemdas

  def initialize(content, precedence = false)
    @phrase_elements = split(content)
    @numbers = select_numbers(content)
    @operators = select_operators
    @pemdas = precedence
    valid_phrase_elements?
  end

  def answer
    pemdas? ? pemdas_calculator : literal_calculator(numbers)
  end

  private

  def pemdas?
    pemdas && (multiplied? || divided?)
  end

  def multiplied?
    phrase_elements.include?('multiplied')
  end

  def divided?
    phrase_elements.include?('divided')
  end

  def pemdas_calculator
    compact_phrase_elements if operand_indices.length != 0
    set_numbers
    set_operators
    @numbers = @numbers.collect {|n| n.to_i}
    if operators.any? {|o| o == 'divided' || o == 'multiplied'}
      pemdas_calculator
    else
      literal_calculator(numbers)
    end
  end

  def set_numbers
    @numbers = phrase_elements.join(' ').scan(/-?\d*/).delete_if(&:empty?)
  end

  def set_operators
    @operators = phrase_elements - @numbers
  end

  def compact_phrase_elements
    index = operand_indices.first
    operand = operand(phrase_elements[index])
    subtotal = phrase_elements[index - 1].to_i.send(operand, phrase_elements[index+1].to_i)
    phrase_elements[(index - 1)...(index + 2)] = subtotal.to_s
  end

  def operand_indices
    phrase_elements.each_with_object([]) do |value, indices|
      if value == 'divided' || value == 'multiplied'
        indices << phrase_elements.index(value)
      end
    end
  end

  def literal_calculator(values)
    (values.size-1).times do |n|
      values[n+1] = subtotal(n)
    end
    values.last
  end

  def valid_phrase_elements?
    unless phrase_elements.any? {|p| conversion.keys.include? p}
      raise ArgumentError
    end
  end

  def subtotal(n)
    numbers[n].to_i.send(operand(operators[n]), numbers[n+1].to_i)
  end

  def operand(n)
    conversion[n]
  end

  def conversion
    {
      'plus' => :+,
      'minus' => :-,
      'multiplied' => :*,
      'divided' => :/
    }
  end

  def select_numbers(content)
    content.scan(/-?\d*/).delete_if(&:empty?)
  end

  def select_operators
    phrase_elements - numbers
  end

  def split(content)
    content.gsub('?', '').split(' ')[2..-1] - ['by']
  end

end
