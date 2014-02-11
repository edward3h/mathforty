class Stats
    attr_reader :mean, :mode
    def initialize(data)
        d = data.sort
        @mean = d.inject(0){|acc, n| acc+n}.to_f / d.size

        vcounts = d.inject({}) do |acc, v|
            c = acc[v] || 0
            acc[v] = c + 1
            acc
        end

        mcount = vcounts.values.max
        mvals = vcounts.select{|k, v| v == mcount}.map{|k, v| k}
        @mode = mvals.inject(0){|acc, n| acc+n}.to_f / mvals.size

        @data = []
        d.each_with_index do |v, n|
            p = ((n.to_f - 0.5) * 100 / d.size).ceil
            @data << [v, p]
        end
    end

    def median
        percentile(50)
    end

    def percentile(p)
        if(p < @data.first.last)
            @data.first.first
        elsif(p > @data.last.last)
            @data.last.first
        else
            k = (p.to_f * @data.size / 100 + 0.5).floor
            pk = @data[k].last
            vk = @data[k].first
            vk1 = @data[k + 1].first
            vk.to_f + (vk1 - vk).to_f * (p - pk) * @data.size / 100
        end
    end
end

