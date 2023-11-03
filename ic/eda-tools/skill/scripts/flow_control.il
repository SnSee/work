;; if
if(t then println("true"))
if(nil then else println("false"))

;; for
for(i 1 10
    println(i)
)

;; foreach
foreach(i '(1 2 3 4 5)
    println(i)
)

;; case
var = 1
name = case(var
    (0 println("is zero") "zero")
    (1 println("is one") "one")
    (t println("is other") "other")
)
println(name)

;; while
a = 1
while(a < 5
    println(a)
    a += 1
)
