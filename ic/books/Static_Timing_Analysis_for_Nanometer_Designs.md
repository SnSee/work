
# Static Timing Analysis for Nanometer Designs

## 3

### 3.7

nldm 模型中 output 延迟查找表的索引为 input_net_transition 和 total_output_net_capacitance，因此在 ndlm 模型中 output 延迟只和 input transition 及 output capacitance 有关。但实际上，output load 不仅和 capacitance 有关，还和连线电阻(**interconnect resistance**)有关。如果 interconnect resistance 较小，nldm模型可以直接用；如果考虑电阻影响，延迟计算算法需要获取output的 **effective capacitance** 来优化nldm模型。effective capacitance 是指包含电阻影响的等效电容，通过这个电容获取的延迟等效于包含电阻影响的延迟。

### 3.8 Power Dissipation Modeling

功耗分为动态功耗(active power)和静态功耗(static/standby/leakage power).

#### 3.8.1 Active Power

active power 是指 output pin 充电(output switching power)以及 input/output pin 翻转(internal switching power)造成的功耗。

## 4. Interconnect Parasitics

## 5

### 5.2 使用有效电容计算延迟

有效电容(effective capacitance): 使用nldm模型(liberty)计算延迟时并非直接使用ouput pin的load capacitance值，还要考虑加上连线电阻产生的电容。
