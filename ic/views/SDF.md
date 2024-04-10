
# SDF

[介绍](https://zhuanlan.zhihu.com/p/343563054)

[sdf_back_annatation-demo](../eda-tools/synopsys/vcs/sdf_test/README.md)

## Liberty manual

The sdf_cond attribute must be logically equivalent to the when attribute for the same timing
arc. If the two Boolean expressions are not equivalent, back-annotation is not performed
properly.
The sdf_cond expressions must be syntax-compliant with SDF 2.1. If the expressions do
not meet this standard, errors are generated later in the flow during the generation and
reuse of the SDF files.
For simple delay paths, such as IOPATH, you can use the Boolean operators, such as &&
and ||, with the sdf_cond attribute. However, Verilog timing check statements, including
setup, hold, recovery, and removal do not support Boolean operators.

sdf_cond属性在逻辑上必须与相同时序的when属性等效。如果两个布尔表达式不等效，那么 back-annotation 将无法正确执行。
sdf_cond表达式必须符合SDF 2.1的语法规范。如果表达式不符合此标准，则在生成和重用SDF文件的过程中会生成错误。
对于简单的延迟路径（如IOPATH），您可以在sdf_cond属性中使用布尔运算符（例如&&和||）。然而，Verilog的时序检查语句，包括setup、hold、recovery和removal，不支持布尔运算符。

## SDF3.0 manual

An optional symbolic name can now appear after the COND keyword (and
the new SCOND and CCOND keywords) to stand in for the state or condition
expression to assist annotators that operate by matching named placeholders.

现在，可以在COND关键字（以及新的SCOND和CCOND关键字）之后出现一个可选的符号名称，用于代表状态或条件表达式，以帮助通过匹配命名占位符进行注释的工具。

Annotators may operate by mapping constructs in the SDF file into
symbolic names, locating placeholders with those names in the models and
applying values from the SDF file to the variables associated with those
placeholders. (An example of this is the annotator for VITAL models in a
VHDL simulator.) To ease the problem of mapping a conditional_port_expr
construct (or the timing_check_condition construct in timing checks, later)
into symbolic names, these can optionally be preceded by a QSTRING.
Clearly, for a tool that uses a name mapping annotation scheme, models
must be constructed so as to contain the correct placeholders. Therefore,
the mapping algorithm of the tool’s annotator must be clearly documented
and available to users. The description of the mapping must include the
way in which the QSTRING is used in constructing the name. For example,
it may be appended to a name constructed from other information in the
SDF file such as the type of construct, port names, etc. The description
should also explain what will happen if the QSTRING is absent in a
conditional construct and what will happen in certain timing checks where
two QSTRINGs are possible.
The intent of SDF is that the QSTRING should stand in place of the
conditional_port_expr or timing_check_condition in constructing unique
placeholder names for each state or condition in which a timing property
might have a different annotated value.

注释工具可以通过将SDF文件中的结构映射到符号名称，定位包含这些名称的模型中的占位符，并将SDF文件中与这些占位符相关联的变量的值应用于其上，从而进行操作（例如，在VHDL模拟器中用于VITAL模型的注释器）。为了简化将conditional_port_expr结构（或稍后的timing_check_condition结构中的时序检查）映射到符号名称，这些结构可以选择在前面加上一个QSTRING。显然，对于使用名称映射注释方案的工具，必须构建包含正确占位符的模型。因此，工具注释器的映射算法必须得到清晰记录并提供给用户。映射的描述必须包括QSTRING在构造名称中的使用方式。例如，它可以附加到从SDF文件中的其他信息（如结构类型、端口名称等）构造的名称上。该描述还应解释在条件结构中缺少QSTRING时会发生什么，以及在某些时序检查中可能存在两个QSTRING的情况下会发生什么。SDF的目的是，QSTRING应该代替conditional_port_expr或timing_check_condition，为每个状态或条件构造唯一的占位符名称，以表示时序属性在不同的状态或条件下可能具有不同的注释值。
