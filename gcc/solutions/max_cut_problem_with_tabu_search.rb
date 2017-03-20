require 'Bundler/setup'
Bundler.require(:default)
require 'time'

Spreadsheet.client_encoding = 'UTF-8'

class TabuSearch

  def initialize(node_num:, tabu_length:, max_attempt_times:)
    @map = Array.new(node_num) { Array.new(node_num, 0) } # 二维图
    @current_solution = Array.new(node_num, 0).map {|i| rand > 0.5 ? 1 : 0} # 随机分配初始解
    @current_f_value = self.caculate_f(@current_solution)

    @tabu_node_turn =Array.new(node_num, 0) # 禁忌表

    @best_solution = Array.new(node_num, 0)
    @best_f_value = 0
    @attempt_times = 0

    @node_num = node_num
    @max_attempt_times = max_attempt_times
    @tabu_length = tabu_length

    @log_file = File.new("max_cut/#{tabu_length}_#{Time.now.hour}_#{Time.now.min}.txt", 'w+')

    self.create_table

    log "Tabu Length: #{@tabu_length}, Max Attempt Times: #{@max_attempt_times}"
  end

  def create_table
    @log_excel = Spreadsheet::Workbook.new
    @log_sheet = @log_excel.create_worksheet
    @log_sheet.row(0).push("Funtion Value", "Solution", "Best Function Value", "Best Solution")
  end

  def log_to_table
    @log_sheet.row(@attempt_times + 1).push(@current_f_value, @current_solution.to_s, @best_f_value, @best_solution.to_s)
  end

  def light_node(arr)
    @map[arr[0] - 1][arr[1] - 1] = @map[arr[1] - 1][arr[0] - 1] = 1
  end

  def log(str)
    @log_file.puts(str)
  end

  # 获取邻域解
  def get_next_solutions
    puts "Get next solution for #{@attempt_times + 1} times."
    @current_solution.map.with_index do |node, index|
      unless @tabu_node_turn[index] > 0
        next_solution = @current_solution.clone.fill(node == 1 ? 0 : 1, index, 1)
        next_solution
      end
    end
  end

  # 计算函数值
  def caculate_f(solution)
    if !!solution
      side_1 = []
      side_2 = []
      f = 0

      solution.each.with_index do |node, index|
        if node == 1
          side_1 << index
        else
          side_2 << index
        end
      end

      side_1.each do |node_index_1|
        side_2.each do |node_index_2|
          if @map[node_index_1][node_index_2] != 0
            f += 1
          end
        end
      end

      f
    else
      0
    end
  end

  def caculate_f_improve(solution)
    self.caculate_f(solution)
  end

  # 冷冻回合减一
  def tabu_turn
    @tabu_node_turn.map! do |node|
      node > 0 ? node - 1 : 0
    end
  end

  def can_stop?
    (@best_f_value > 516 && @attempt_times > 1000) || @attempt_times > @max_attempt_times
  end

  def print_candidate_solution
    puts "Candidate Solutions: #{@current_solution.to_s}"
    puts "Candidate Function Value: #{@current_f_value.to_s}"
    log "Candidate Solutions: #{@current_solution.to_s}"
    log "Candidate Function Value: #{@current_f_value.to_s}"
  end

  def print_best_solution
    puts "Best Solution: #{@best_solution}"
    puts "Best Function Value: #{@best_f_value}"

    self.log_to_table
  end

  # 一轮求解
  def turn
    begin
      puts "Turn: #{@attempt_times + 1}".colorize(:green)

      next_solutions = self.get_next_solutions
      candidate_solution = nil
      candidate_f = 0
      candidate_solution_node_index = -1

      puts "Next Solutions: #{next_solutions.to_s}"

      next_solutions.each_with_index do |solution, index|
        if !!solution
          f = self.caculate_f_improve(solution)
          if f >= candidate_f
            candidate_solution = solution
            candidate_f = f
            candidate_solution_node_index = index
          end
        end
      end

      @current_solution = candidate_solution
      @current_f_value = candidate_f

      self.print_candidate_solution

      if candidate_f >= @best_f_value
        @best_solution = candidate_solution
        @best_f_value = candidate_f
      end

      self.print_best_solution

      @tabu_node_turn[candidate_solution_node_index] = @tabu_length

      @attempt_times += 1
      self.tabu_turn

      unless self.can_stop? || !candidate_solution
        self.turn
      else
        puts "Result: "
        self.print_best_solution
        @log_excel.write "./max_cut/#{@tabu_length}_#{Time.now.hour}_#{Time.now.min}_#{@best_f_value}.xls"
      end
    rescue => e
      @log_excel.write "./max_cut/#{@tabu_length}_#{Time.now.hour}_#{Time.now.min}_#{@best_f_value}.xls"
    end

  end

  # 从文件初始化实例
  def self.new_from_file(file_path:, tabu_length:, max_attempt_times:)
    file = File.open(file_path)
    basic_data = IO.readlines(file)[0].split(' ')
    tabu_search = self.new(node_num: basic_data[1].to_i, tabu_length: tabu_length, max_attempt_times: max_attempt_times)
    IO.foreach(file) do|line|
      node_arr = line.split(' ')
      case node_arr[0]
        when 'e'
          tabu_search.light_node([node_arr[1].to_i, node_arr[2].to_i])
      end
    end
    tabu_search
  end

end

class TabuSearchImprove < TabuSearch

  def caculate_f_improve(solution)
    sum = 0
    @map[node_index].each { |node_state| sum += node_state }
    final_f = sum + @current_f_value
    puts "Function Value for #{node_index + 1}th: #{final_f}"
    final_f
  end

end

ARGV[0] ||= 5
ARGV[1] ||= 10

TabuSearch.new_from_file(file_path: 'max_cut_problem_with_tabu_search_data.txt', tabu_length: ARGV[0].to_i, max_attempt_times: ARGV[1].to_i).turn