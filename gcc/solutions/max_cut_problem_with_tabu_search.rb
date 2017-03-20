require 'Bundler/setup'
Bundler.require(:default)
require 'time'

class TabuSearch

  def initialize(node_num:, tabu_length:, max_attempt_times:)
    @map = Array.new(node_num) { Array.new(node_num, 0) }
    @current_solution = Array.new(node_num, 0).map {|i| rand > 0.5 ? 1 : 0}
    @best_solution = Array.new(node_num, 0)
    @tabu_node_turn =Array.new(node_num, 0)
    @current_f_value = self.caculate_f(@current_solution)
    @best_f_value = 0
    @attempt_times = 0

    @node_num = node_num
    @max_attempt_times = max_attempt_times
    @tabu_length = tabu_length
    @log_file = File.new("max_cut/#{tabu_length}_#{Time.now.hour}_#{Time.now.min}.txt", 'w+')

    self.log "Tabu Length: #{@tabu_length}, Max Attempt Times: #{@max_attempt_times}"
    # self.map_seed
  end

  # # 初始化网络图
  # def map_seed
  #   @map[0][1] = @map[0][4] = @map[0][6] = 1
  #   @map[1][0] = @map[1][5] = @map[1][2] = 1
  #   @map[2][1] = @map[2][3] = @map[2][4] = @map[2][6] = 1
  #   @map[3][2] = @map[3][4] = 1
  #   @map[4][3] = @map[4][2] = @map[4][0] = 1
  #   @map[5][1] = @map[5][6] = 1
  #   @map[6][5] = @map[6][2] = @map[6][0] = 1
  # end
  def light_node(arr)
    @map[arr[0] - 1][arr[1] - 1] = @map[arr[1] - 1][arr[0] - 1] = 1
  end

  def log(str)
    @log_file.puts(str)
  end

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

  # 冷冻回合减一
  def tabu_turn
    @tabu_node_turn.map! do |node|
      node > 0 ? node - 1 : 0
    end
  end

  def can_stop?
    @attempt_times > @max_attempt_times
  end

  # 一轮求解
  def turn
    puts "Turn: #{@attempt_times + 1}".colorize(:green)

    next_solutions = self.get_next_solutions
    candidate_solution = nil
    candidate_f = 0
    candidate_solution_node_index = -1

    puts "Next Solutions: #{next_solutions.to_s}"

    next_solutions.each_with_index do |solution, index|
      if !!solution
        f = self.caculate_f(solution)
        if f >= candidate_f
          candidate_solution = solution
          candidate_f = caculate_f(candidate_solution)
          candidate_solution_node_index = index
        end
      end
    end

    puts "Candidate Solutions: #{candidate_solution.to_s}"
    puts "Candidate Function Value: #{candidate_f.to_s}"
    log "Candidate Solutions: #{candidate_solution.to_s}"
    log "Candidate Function Value: #{candidate_f.to_s}"

    if candidate_f >= @best_f_value
      @best_solution = candidate_solution
      @best_f_value = candidate_f
    end

    puts "Best Solution: #{@best_solution}"
    puts "Best Function Value: #{@best_f_value}"

    @current_solution = candidate_solution
    @tabu_node_turn[candidate_solution_node_index] = @tabu_length

    puts "Tabu List: #{@tabu_node_turn.to_s}"

    @attempt_times += 1
    self.tabu_turn

    puts

    unless self.can_stop? || !candidate_solution
      self.turn
    else
      puts "Result: #{@best_f_value}"
      log "Result: #{@best_f_value}"
    end
  end

end

class TabuSearchImprove < TabuSearch

  def flip_map(node_index)
    (0..@node_num - 1).each do |i|
      @map[i][node_index] = 0 - @map[i][node_index]
    end
    @map[node_index].map! { |node| -node }
    puts "Map: #{@map.to_s}"
  end

  def caculate_f_improve(node_index)
    sum = 0
    @map[node_index].each { |node_state| sum += node_state }
    final_f = sum + @current_f_value
    puts "Function Value for #{node_index + 1}th: #{final_f}"
    final_f
  end

  def turn
    puts "Turn: #{@attempt_times + 1}".colorize(:green)

    next_solutions = self.get_next_solutions
    candidate_solution = nil
    candidate_f = 0
    candidate_solution_node_index = -1

    puts "Next Solutions: #{next_solutions.to_s}"

    next_solutions.each_with_index do |solution, index|
      if !!solution
        f = nil
        if @attempt_times < 1
          f = self.caculate_f(solution)
        else
          f = self.caculate_f_improve(index)
        end
        if f >= candidate_f
          candidate_solution = solution
          candidate_f = caculate_f(candidate_solution)
          candidate_solution_node_index = index
        end
      end
    end

    puts "Candidate Solutions: #{candidate_solution.to_s}"
    puts "Candidate Function Value: #{candidate_f.to_s}"
    log "Candidate Solutions: #{candidate_solution.to_s}"
    log "Candidate Function Value: #{candidate_f.to_s}"

    if candidate_f >= @best_f_value
      @best_solution = candidate_solution
      @best_f_value = candidate_f
    end

    puts "Best Solution: #{@best_solution}"
    puts "Best Function Value: #{@best_f_value}"

    self.flip_map(candidate_solution_node_index)
    @current_solution = candidate_solution
    @current_f_value = candidate_f

    @attempt_times += 1
    self.tabu_turn
    @tabu_node_turn[candidate_solution_node_index] = @tabu_length
    puts "Tabu List: #{@tabu_node_turn.to_s}"

    puts ""

    unless self.can_stop? || !candidate_solution
      self.turn
    else
      puts "Result: #{@best_f_value}"
      log "Result: #{@best_f_value}"
    end
  end

end

TabuSearch.new_from_file(file_path: 'max_cut_problem_with_tabu_search_data.txt', tabu_length: ARGV[0].to_i, max_attempt_times: ARGV[1].to_i).turn