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

;; case
a = 1
case(a
    (0 println("is 0"))
    (1 println("is 1"))
    (2 println("is 2"))
    (t println("other"))
)

;; cond: 回调函数为真则执行后面的代码
a = 1
cond(
    ((null a) (println "is null"))
    ((numberp a) (println "is number"))
    ((stringp a) (println "is string"))
    (t (println "unknown type"))
)

;; return
procedure(return_test()
    println("before prog")          ; 执行
    ret = prog(()
        println("before return")    ; 执行
        return(1)                   ; 退出 prog
        println("after return")     ; 不执行
    )
    println("after prog")           ; 执行
    ret                             ; 返回 ret
)
