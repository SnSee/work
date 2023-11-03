procedure(myOpenWindow()
    println("my open window")
    hiOpenWindow(
        ?bBox list(0:0 300:300)
        ?type "graphics"
        ?menus list(hiOpenMenu 'hiDMMenu)
        ?labels '("label 1" "label 2")
        ?scroll t
    )
)
