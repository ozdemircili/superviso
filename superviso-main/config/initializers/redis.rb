RedisPool = ConnectionPool.new(size: 20, timeout: 30){ Redis.connect } 
