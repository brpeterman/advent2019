module Advent
    class Passwords
        def valid_password_count(start, stop)
            count = 0
            (start..stop+1).each do |code|
                if valid?(code) then count += 1 end
            end
            count
        end

        def valid?(code)
            has_minimal_double = false
            digits = code.to_s.split('').map(&:to_i)
            (1..digits.length-1).each do |index|
                if !has_minimal_double && digits[index] == digits[index-1] && !(code.to_s =~ /#{digits[index]}{3}/)
                    has_minimal_double = true
                end
                if digits[index] < digits[index-1]
                    return false
                end
            end
            return has_minimal_double
        end
    end
end

if __FILE__ == $0
    include Advent
    passwords = Passwords.new
    puts passwords.valid_password_count(130254, 678275)
end
