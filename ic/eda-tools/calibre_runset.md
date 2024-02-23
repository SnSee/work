
# calibre runset

## calibre DRC rule 语法

### layers 交互语法

```tcl
new_layer = layer1 INTERACT layer2              # 交集
new_layer = layer1 NOT layer2 [layer3, ...]     # 
new_layer = OR layer1 layer2 [layer3, ...]      # 并集
new_layer = layer1 NOT INTERACT layer2
new_layer = CONNECT layer1 layer2 BY layer3
```
