
julia>  prog = "1+1"
"1+1"

julia> ex1 = Meta.parse(prog)
:(1 + 1)

julia> typeof(ex1)
Expr

julia> ex1.head
:call

julia> ex1.args
3-element Vector{Any}:
  :+
 1  
 1

julia> ex2 = Expr(:call, :+, 1, 1)
:(1 + 1)

julia> ex1 == ex2
true

julia> dump(ex2)
Expr
  head: Symbol call
  args: Array{Any}((3,))
    1: Symbol +
    2: Int64 1
    3: Int64 1

julia> ex3 = Meta.parse("(4+4)/2")
:((4 + 4) / 2)

julia> Meta.show_sexpr(ex3)
(:call, :/, (:call, :+, 4, 4), 2)
julia> s = :foo
:foo

julia> typeof(s)
Symbol

julia> :foo === Symbol("foo")
true

julia> Symbol("1foo")
Symbol("1foo")

julia> Symbol("func",10)
:func10

julia> Symbol(:var '_',"sym")

julia> Symbol(:var,'-',"sym")
Symbol("var-sym")

julia> ex = :(a+b*c+1)
:(a + b * c + 1)

julia> typeof(ex)
Expr

julia> ex = quote
       x = 1
       y = 2
       x+y
       end
quote
    #= REPL[20]:2 =#
    x = 1
    #= REPL[20]:3 =#
    y = 2
    #= REPL[20]:4 =#
    x + y
end

julia> typeof(x)

julia> typeof(ex)
Expr

julia> # Interpolation

julia> a = 1;

julia> ex = :($a+b)
:(1 + b)

julia> ex = :(a in $:(1,2,3)))

julia> ex = :(a in $:(1,2,3))
:(a in (1, 2, 3))

julia> args = [:x, :y, :z];

julia> :(f(1, $(args...)))
:(f(1, x, y, z))

julia> x = :(1+2);

julia> e = quote quote $x end end
quote
    #= REPL[31]:1 =#
    $(Expr(:quote, quote
    #= REPL[31]:1 =#
    $(Expr(:$, :x))
end))
end

julia> eval(e)
quote
    #= REPL[31]:1 =#
    1 + 2
end

julia> e = quote quote $$x end end
quote
    #= REPL[33]:1 =#
    $(Expr(:quote, quote
    #= REPL[33]:1 =#
    $(Expr(:$, :(1 + 2)))
end))
end

julia> eval(e)
quote
    #= REPL[33]:1 =#
    3
end

julia> e = quote quote quote $$$x end end end
quote
    #= REPL[35]:1 =#
    $(Expr(:quote, quote
    #= REPL[35]:1 =#
    $(Expr(:quote, quote
    #= REPL[35]:1 =#
    $(Expr(:$, :($(Expr(:$, :(1 + 2))))))
end))
end))
end

julia> eval(e)
quote
    #= REPL[35]:1 =#
    $(Expr(:quote, quote
    #= REPL[35]:1 =#
    $(Expr(:$, 3))
end))
end

julia> dump(Meta.parse(":(1+2)"))
Expr
  head: Symbol quote
  args: Array{Any}((1,))
    1: Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol +
        2: Int64 1
        3: Int64 2

julia> eval(Meta.quot(Expr(:$, :(1+2))))
3

julia> eval(QuotNode(Expr(:$, :(1+2))))
  
julia> eval(QuoteNode(Expr(:$, :(1+2))))
:($(Expr(:$, :(1 + 2))))

julia> dump(Meta.parse(":x"))
QuoteNode
  value: Symbol x

julia> ex1 = :(1+2)
:(1 + 2)

julia> eval(ex1)
3

julia> ex = :(a+b)
:(a + b)

julia> eval(ex)

julia> a = 1; b = 2;

julia> eval(ex)
3

julia> a = 1;

julia> ex = Expr(:call, :+, a, :b)
:(1 + b)

julia> a = 0; b = 2;

julia> eval(ex)
3

julia> function math_expr(op, op1, op2)
       expr = Expr(:call, op, op1, op2)
       return expr
       end
math_expr (generic function with 1 method)

julia> ex = math_expr(:+, 1, Expr(:call, :*, 4, 5))
:(1 + 4 * 5)

julia> eval(ex)
21

julia> # Macros

julia> macro sayhello()
       return :(println("Hello, World"))
       end
@sayhello (macro with 1 method)

julia> @sayhello()
Hello, World

julia> macro sayhello(name)
       return :(println("Hello, ", $name))
       end
@sayhello (macro with 2 methods)

julia> @sayhello(Aditya)

julia> @sayhello("Aditya")
Hello, Aditya

julia> ex = macroexpand(Main, :(@sayhello("human")))
:(Main.println("Hello, ", "human"))

julia> macro twostep(arg)
       println("I execute at parse time. The argment is: ", arg)
       return :(println("I execute at runtime, the argument is: ", $arg))
       end
@twostep (macro with 1 method)

julia> ex = macroexpand(Main, :(@twostep :(1,2,3)));
I execute at parse time. The argment is: :((1, 2, 3))

julia> typeof(ex)
Expr

julia> ex
:(Main.println("I execute at runtime, the argument is: ", $(Expr(:copyast, :($(QuoteNode(:((1, 2, 3)))))))))

julia> ecal(ex)

julia> eval(ex)
I execute at runtime, the argument is: (1, 2, 3)

julia> macro showarg(x)
       show(x)
       end
@showarg (macro with 1 method)

julia> @showarg(a)
:a
julia> @showarg(1+1)
:(1 + 1)
julia> @showarg(println("Yo!"))
:(println("Yo!"))
julia> @showarg(1)
1
julia> @showarg("Yo!")
"Yo!"
julia> @showarg("Yo! $("hello")")
:("Yo! $("hello")")
julia> macro assert(ex)
       return :( $ex ? nothing : throw(AssertionError($(string(ex))))
       end

julia> macro assert(ex)
        return :( $ex ? nothing : throw(AssertionError($(string(ex)))))
        end
@assert (macro with 1 method)

julia> @assert 1 == 1.0

julia> macro assert(ex, msgs...)
       msg_body = iseempty(msgs) ? ex : msgs[1]
       msg = string(msg_body)
       return :($ex ? nothing : throw(AssertionError($msg)))   
       end
@assert (macro with 2 methods)

julia> macro zerox()
       return esc(:(x=0))
       end
@zerox (macro with 1 method)

julia> function foo()
       x = 1
       @zerox
       return x
       end
foo (generic function with 1 method)

julia> foo()
0

julia> macro m end
@m (macro with 0 methods)

julia> macro m(args...)
       println("$(Length(args)) arguments")
       end
@m (macro with 1 method)

julia> macro m(x,y)
       println("Two arguments")
       end
@m (macro with 2 methods)

julia> @m 1 2
Two arguments

julia> macro m(::Int)
       println("An Integer")
       end
@m (macro with 3 methods)

julia> @m 2
An Integer

julia> x = 2
2

julia> @generated function foo(x)
       Core.println(x)
       return :(x*x)
       end
foo (generic function with 2 methods)

julia> x = foo(2);
Int64

julia> x
4

julia> y = foo("bar");
String

julia> y
"barbar"

julia> foo(4)
16

julia> f(x) = "original defination";

julia> g(x) = f(x);

julia> @generated gen1(x) = f(x);

julia> @generated gen2(x) = :(f(x));

julia> f(x::Int) = "defination for Int";

julia> f(x::Type{Int}) ="defination for Type{Int}";

julia> f(1)
"defination for Int"

julia> g(2)
"defination for Int"

julia> g(1)
"defination for Int"

julia> gen1(1)
"original defination"

julia> gen2(1)
"defination for Int"

julia> @generated gen1(x::Real) = f(x);

julia> gen1(1)
"defination for Type{Int}"

julia> @generated function bar(x)
       if x <: Integer
       return :(x^2)
       else
       retun :(x)
       end
       end
bar (generic function with 1 method)

julia> bar(4)
16
