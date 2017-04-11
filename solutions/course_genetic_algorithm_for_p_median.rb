require 'Bundler/setup'
Bundler.require(:default)

require 'time'

# 计算方法
module CaculateMethods
  # 计算阶乘
  def fact(n)
    (1..n).reduce(:*)
  end

  # 计算组合数，n 为大者
  def combination(n, p)
    fact(n) / fact(p) / fact(n - p)
  end
end

# 操纵 excel 表组件
module SpreadSheetModule
  def create_log_sheet(path, *col_headers)
    @log_excel = Spreadsheet::Workbook.new
    @log_sheet = @log_excel.create_worksheet
    @log_sheet.row(0).push *col_headers
    @log_sheet_path = path
    @log_sheet_row = 1
  end

  def log_to_sheet(*cols)
    @log_sheet.row(@log_sheet_row).push cols
  end
  
  def save_log_sheet
    @log_excel.write "#{@log_sheet_path}.xls"
  end
  
  def open_data_sheet(path)
    @data_excel = Spreadsheet.open path
    @data_sheet = @data_excel.worksheet 0
    @data_sheet_row = 0
  end
end

# 遗传算法
class GeneticAlgorithm
  include CaculateMethods
  include SpreadSheetModule
  
  # 需求点类
  class Point
    attr_accessor :id, :x, :y, :weight
    
    def initialize(id, x, y, weight)
      @id = id
      @x = x
      @y = y
      @weight = weight
    end
  end
  
  # 解类
  class Solution
    attr_accessor :members, :fitness
    
    def initialize(members, points)
      @members = members
      self.caculate_fitness points
    end
    
    def caculate_fitness(points)
      sum = 0
      
      # 获取解之外的点
      other_points = points.select { |point|
        !(members.include? point)
      }
      
      for i in (0..other_points.size - 1)
        # assign_point = members[0]
        min_dis =  self.caculate_distance(other_points[i], members[0])
        
        # 计算该点被分配的点
        for j in (1..members.size - 1)
          new_dis = self.caculate_distance(other_points[i], members[j])
          if new_dis < min_dis
            min_dis = new_dis
            # assign_point = members[j]
          end
        end
        
        sum += min_dis * other_points[i].weight
      end
      
      @fitness = sum
    end
    
    def caculate_distance(point1, point2)
      ((point1.x - point2.x)**2 + (point1.y - point2.y)**2)**0.5
    end
  end
  
  def initialize
    self.create_log_sheet "genetic_algorithm/#{Time.now.hour}_#{Time.now.min}", "Iterator", "Merge", "Draft", "Candidate", "FitNess", "Replace", "Comment"
    self.save_log_sheet
  end
  
  def set_data_from_sheet
    @n_num = @data_sheet.row(@data_sheet_row)[0].to_i
    @p_num = @data_sheet.row(@data_sheet_row)[1].to_i
    @data_sheet_row += 1
    @n_arr = []
    @n_num.times {
      @n_arr << Point.new(@data_sheet_row, @data_sheet.row(@data_sheet_row)[0], @data_sheet.row(@data_sheet_row)[1], @data_sheet.row(@data_sheet_row)[2])
      @data_sheet_row += 1
    }
  end
  
  # 计算群体数量并保存
  def set_population_size
    s = self.combination @n_num, @p_num
    @d_num = (@n_num / @p_num).ceil
    @pop_size_k = (@n_num / 100 * Math.log(s) / @d_num).ceil
    @pop_size_k = 2 if @pop_size_k < 2
    @population_size = @pop_size_k * @d_num
  end
  
  # 初始化群体，需要计算过群体数量
  def init_population
    @populations = []
    # n = 12, p = 3
    # 1..2
    (1..@pop_size_k).each { |k|
      i = 0
      init_j = 0
      # 1..4
      @d_num.times {
        members = []
        
        j = init_j

        # 如果已经超出下标且应该进行第二轮
        if j + i * @p_num * k > @n_num - 1 && init_j < k - 1
          init_j += 1
          j = init_j
          i = 0
        end
        
        # 0..2
        @p_num.times {
          # 第一轮：0，1，2；第二轮：3，4，5
          # 第一轮：0, 2, 4；第二轮：6, 8, 10
          index = j + i * @p_num * k
          # 如果大于所有点的个数随机生成一个
          index = rand(0..@n_num - 1) if index > @n_num - 1
          members << @n_arr[index]
          j += k
        }

        i += 1

        @populations << Solution.new(members, @n_arr)
      }
    }
    
    @populations
  end
  
  def get_rand_parent_index
    rand(@population_size)
  end
  
  def generation_operator
    parent_1_index = self.get_rand_parent_index
    parent_2_index = self.get_rand_parent_index

    parent_1 = @populations[parent_1_index].members
    parent_2 = @populations[parent_2_index].members
    
    # Merge
    self.log_to_sheet "#{parent_1_index} and #{parent_2_index}"
    
    common = []
    uncommon = []
    parent_1.each { |point|
      if parent_2.include?(point)
        common << point
      else
        uncommon << point
      end
    }
    parent_2.each { |point|
      uncommon << point unless common.include?(point)
    }
    
    draft = [common, uncommon].flatten
    
    # Draft
    self.log_to_sheet draft

    while draft.size > @p_num
      ori_fitness = Solution.new(draft, @n_arr).fitness
      min_point = uncommon[0]
      min_increace =  Solution.new(draft.reject { |p| p == min_point }, @n_arr).fitness - ori_fitness
      uncommon.each_with_index { |un_point, index|
        new_increace = Solution.new(draft.reject { |p| p == un_point }, @n_arr).fitness - ori_fitness
        if new_increace < min_increace
          min_increace = new_increace
          min_point = un_point
        end
      }
      uncommon.delete_if { |point| point == min_point}
      draft.delete_if { |point| point == min_point}
    end

    # Candidate
    self.log_to_sheet draft

    candidate = Solution.new(draft, @n_arr)
    
    # Fitness
    self.log_to_sheet candidate.fitness

    puts candidate
    puts candidate.fitness

    @candidate = candidate
  end
  
  def replacement_operator
    max_fitness_solution = @populations.max { |a, b| a.fitness <=> b.fitness}
    @best_fitness_solution = @populations.min { |a, b| a.fitness <=> b.fitness}
    
    # 如果大于最坏的函数值，抛弃
    return if @candidate.fitness > max_fitness_solution.fitness
    # 如果与群体中某个解一致，抛弃
    return if @populations.index{ |solution|
      flag = true
      (0..@p_num - 1).each { |i|
        flag = false if solution.members[i] != @candidate.members[i]
      }
      flag
    }
    
    max_fitness_index = @populations.index max_fitness_solution
    @populations[max_fitness_index] = @candidate
  end
  
  def turn
    self.log_to_sheet @iter
    self.generation_operator
    self.replacement_operator
    save_log_sheet
    
    puts @best_fitness_solution.fitness
    
    unless @populations.min { |a, b| a.fitness <=> b.fitness}.fitness == @best_fitness_solution.fitness
      @max_iter = 0
    end
    @log_sheet_row += 1
    @iter += 1
    @max_iter += 1
  end
  
  def start
    self.set_population_size
    self.init_population
    @iter = 1
    @max_iter = 1
  
    while @max_iter < (@n_num * @p_num**0.5).ceil
      self.turn
    end
  end
  
  def self.new_from_sheet(path)
    instance = self.new
    instance.open_data_sheet path
    instance.set_data_from_sheet
    instance
  end
end

GeneticAlgorithm.new_from_sheet("data/genetic_algorithm.xls").start