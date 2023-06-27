
# lc

liberty 转换成 db

```csh
#!/bin/csh
lc_shell << EOF
source <tcl>
EOF
```

```tcl
read_lib <lib>
write_lib -format db -o <output.db> [get_object_name [get_libs]]
```
