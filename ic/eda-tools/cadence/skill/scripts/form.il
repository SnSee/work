;; 表单(多次调用为同一对象)

procedure(myShowForm()
    gStrFld = hiCreateStringField(
        ?name `gStrFld
        ?prompt "sample string field"
        ?defValue "default value"
        ?callback "print(\"value changed\")"
        ?editable t
    )
    gChkFld = hiCreateBooleanButton(
        ?name `gChkFld
        ?buttonText "sample check field"
        ?defValue t
        ?callback "print(\"check changed\")"
    )

    if(!boundp('gForm) || (gForm == nil) then
        gForm = hiCreateAppForm(
            ?name `gForm
            ?fields list(gStrFld gChkFld)
            ?formTitle "My first Form"
            ?callback "myFormCallback()"
            ?buttonLayout 'OKCancel
        )
    )
    hiDisplayForm(`gForm)
)

procedure(myFormCallback()
    println("my form callback")
    ; form = hiGetCurrentForm()
    form = gForm
    println(type(form))     ; formStruct
    ; 通过属性访问
    println(form->gStrFld->value)
    ; 通过函数访问
    println(hiGetCyclicValueString(form->gStrFld))

    println(form->gChkFld->value)   ; 't 或 'nil
    if(form->gChkFld->value then
        println("checked")
    else
        println("unchecked")
    )
)
