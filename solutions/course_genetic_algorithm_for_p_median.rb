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
    @log_sheet_row += 1
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
    
    def initialize(members)
      @members = members
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
        # 0..2
        @p_num.times {
          # 第一轮：0，1，2；第二轮：3，4，5
          # 第一轮：0, 2, 4；第二轮：6, 8, 10
          index = j + i * @p_num * k
          if index > @n_num - 1 && init_j < k - 1
            init_j += 1
            j = init_j
            i = 0
            index = j + i * @p_num * k
          end
          # 如果大于所有点的个数随机生成一个
          index = rand(0..@n_num - 1) if index > @n_num - 1
          members << @n_arr[index]
          j += k
        }

        i += 1
        @populations << Solution.new(members)
      }
    }
    
    @populations
  end
  
  def start
    self.set_population_size
    self.init_population
  end
  
  def self.new_from_sheet(path)
    instance = self.new
    instance.open_data_sheet path
    instance.set_data_from_sheet
    instance
  end
end

GeneticAlgorithm.new_from_sheet("data/genetic_algorithm.xls").start