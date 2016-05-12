require 'mathn.rb'

#сама функция f(x)
def f(x)
	x**2 - Math::log10(x + 2)
end

#производная f(x)
def df(x)
	2*x - 1/(x + 2)/Math::log(10)
end

$a = 0.5
$b = 1.0
x1 = 0.53
x2 = 0.52
x3 = 0.97
x4 = 0.73
$h = ($b - $a)/10

#Табличные значения
$xi = Array.new(11){|i| $a + $h * i}
$fi = Array.new(11){|i| f($xi[i])}
$dfi = Array.new(11){|i| df($xi[i])}

class Spline
	#конструктор
	def initialize(xi, fi, dy0, dyn, h)
		n = xi.length
		@xi = xi
		@y = fi
		@a = Array.new(n) {0}
		@b = Array.new(n) {0}
		@m = Array.new(n) {0}

		temp = Array.new(n-2) { |i| 3*(@y[i+2] - @y[i])/h }
		temp[0] -= dy0
		temp[n-3] -= dyn
		
		@m = pr(Array.new(n-2){1}, Array.new(n-2){4}, Array.new(n-2){1}, temp)
		@m.push(dyn)
		@m.unshift(dy0)

		for i in (0...n-1)
			@a[i] = 6/h*((@y[i+1] - @y[i])/h - (@m[i+1] + 2*@m[i])/3)
			@b[i] = 12/(h**2)*((@m[i+1] + @m[i])/2 - (@y[i+1] - @y[i])/h)
		end
	end
	
	#метод прогонки
	def pr(a, b, c, f)
		n = f.length
		a[0] = 0;
		c[n - 1] = 0;
		u = Array.new(f.length)
		alf = Array.new(f.length)
		bet = Array.new(f.length)
		alf[0] = -c[0]/b[0]
		bet[0] = f[0]/b[0]
		for i in (0...n-1)
			alf[i+1] = -c[i]/(alf[i]*a[i] + b[i])
			bet[i+1] = (f[i] - bet[i]*a[i])/(alf[i]*a[i] + b[i])
		end
		u[n-1] =(f[n-1] - bet[n-1]*a[n-1])/(b[n-1] + alf[n-1]*a[n-1])
		for i in (0...n-1).to_a.reverse
			u[i] = alf[i+1]*u[i+1] + bet[i+1]
		end
		return u
	end

	#Получение значения
	def get_value(x)
		n = @xi.length
		k = -1
		for i in (0...n-1)
			if (x >= @xi[i] and x <= @xi[i + 1])
				k = i
			end
		end
		@y[k] + @m[k]*(x - @xi[k]) + @a[k]*((x - @xi[k])**2)/2 + @b[k]*((x - @xi[k])**3)/6
	end

end;

s = Spline.new $xi, $fi, $dfi.first, $dfi.last, $h

puts "S: #{s.get_value(x1)}"
puts "f: #{f(x1)}"
puts "R: #{f(x1) - s.get_value(x1)}\n\n"
puts "S: #{s.get_value(x2)}"
puts "f: #{f(x2)}"
puts "R: #{f(x2) - s.get_value(x2)}\n\n"
puts "S: #{s.get_value(x3)}"
puts "f: #{f(x3)}"
puts "R: #{f(x3) - s.get_value(x3)}\n\n"
puts "S: #{s.get_value(x4)}"
puts "f: #{f(x4)}"
puts "R: #{f(x4) - s.get_value(x4)}\n\n"
