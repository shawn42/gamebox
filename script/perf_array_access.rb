require 'benchmark'
NUM = 10_000_000
Benchmark.bm(60) do |b|
  it = [4,6]
  b.report("[]") do
    NUM.times do 
      it[0]
    end
  end
  b.report("at") do
    NUM.times do 
      it.at(0)
    end
  end
end

