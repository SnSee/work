;; custom_menu.il

procedure(myItemCb()
    println("Menu item callback")
)

procedure(myCreateLayoutPulldownMenu()
  if((!boundp('myLayoutPulldownMenu) || myLayoutPulldownMenu == nil) then
    println("create menu")
    myLayoutPulldownMenu = hiCreatePulldownMenu(
      'myLayoutPulldownMenu
      "MenuName"
      list(
        hiCreateMenuItem(
          ?name 'Item1
          ?itemText "Item1"
          ?callback "myItemCb()"
        )
        hiCreateMenuItem(
          ?name 'Item2
          ?itemText "Item2"
          ?callback "myItemCb()"
        )
      )
    )
  )
  ; return menu
  myLayoutPulldownMenu
)

procedure(myPostInstallTrigger(args)
  hiInsertBannerMenu(
    args->window
    myCreateLayoutPulldownMenu()
    length(hiGetBannerMenus(args->window))
  )
)

;; Triggers for adding it to layout and VXL window
deRegUserTriggers("maskLayout" nil nil 'myPostInstallTrigger)
deRegUserTriggers("maskLayoutXL" nil nil 'myPostInstallTrigger)

;; Triggers for adding it to schematic window
deRegUserTriggers("schematic" nil nil 'myPostInstallTrigger)

;; Trigger for adding it to schematic window in case of VXL mode
;; deRegUserTriggers( "schSynthesisXL" nil nil 'myPostInstallTrigger)
