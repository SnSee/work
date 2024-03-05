#!/bin/env python3
import os
import re
import sys

_MY_DIR = os.path.abspath(os.path.dirname(__file__))


class _CellVars:
    def __init__(self) -> None:
        self.cell_name = None
        self.process = None
        self.verilog_file = None
        self.spice_file = None
        self.spice_lib = None


# deploy vcs partition file
def _deploy_partition(cell_vars: _CellVars, partition_file: str, spice_wrap_file: str):
    with open(partition_file, 'w') as fp:
        fp.write('\n'.join([
            f"// bus_format _%d;",
            f"use_spice -cell {cell_vars.cell_name}_WRAPPER;",
            f"choose finesim {spice_wrap_file};",
            f""
        ]))


# deploy parameter file
# TODO: 不同cell类型设置不同参数值
def _deploy_parameter(cell_vars: _CellVars, parameter_file: str):
    with open(parameter_file, 'w') as fp:
        fp.write('\n'.join([
            "assign 3 top/STIMU_WIDTH",
            "assign 2 top/CAPTURE_WIDTH",
        ]))


def _deploy_spice(cell_vars: _CellVars, wrap_file: str):
    subckt_pat = re.compile(fr'\.SUBCKT\s+{cell_vars.cell_name}\s+(.*)', re.IGNORECASE)
    all_pins = None
    with open(cell_vars.spice_file) as fp:
        for line in fp:
            ret = subckt_pat.match(line)
            if ret:
                all_pins = ret.group(1).strip().split()
    if not all_pins:
        raise Exception(f'SUBCKT not found')
    no_pg_pins_str = ' '.join([pin for pin in all_pins if pin not in {'VDD', 'VSS', 'VNW', 'VPW'}])
    all_pins_str = ' '.join(all_pins)

    cell_name = cell_vars.cell_name
    with open(wrap_file, 'w') as wfp:
        wfp.write(f'*.lib\n')
        wfp.write(f'.lib {cell_vars.spice_lib} {cell_vars.process}\n\n')
        with open(cell_vars.spice_file) as rfp:
            wfp.write(rfp.read())
        wfp.write('\n')
        wfp.write('\n'.join([
            f'.SUBCKT {cell_name}_WRAPPER {no_pg_pins_str}',
            f'XI0 {all_pins_str} {cell_name}',
            f'',
            f'VVDD VDD VSS 0.55',
            f'VVPP VNW VSS 0.55',
            f'VVBB VPW VSS 0',
            f'VVSS VSS 0   0',
            f'',
            f'.ENDS',
            f'',
            f'.END',
            f'',
        ]))


def _deploy_verilog(cell_vars: _CellVars, wrap_file: str):
    pin_pat = re.compile(r'\s*(input|output)\s+(.*);')
    start_pat = re.compile(fr'\s*module {cell_vars.cell_name}\s*\(')
    end_pat = re.compile(fr'\s*endmodule')
    start = False
    input_pins = []
    output_pins = []
    with open(cell_vars.verilog_file) as fp:
        for line in fp:
            if start:
                if pin_pat.match(line):
                    ret = pin_pat.match(line)
                    pin_dir = ret.group(1)
                    pin_names = [pin.strip() for pin in ret.group(2).split(',')]
                    if pin_dir == 'input':
                        input_pins.extend(pin_names)
                    elif pin_dir == 'output':
                        output_pins.extend(pin_names)
                elif end_pat.match(line):
                    break
            elif start_pat.match(line):
                start = True
    all_pins = input_pins + output_pins
    wires_str = '\n    '.join([f'wire {pin};' for pin in all_pins])
    conn_str = ', '.join([f'.{pin}({pin})' for pin in all_pins])
    with open(wrap_file, 'w') as wfp:
        with open(cell_vars.verilog_file) as rfp:
            wfp.write(rfp.read())
        wfp.write('\n')
        temp = '\n'.join([
            f'',
            f'module <module_name>  #(parameter STIMU_WIDTH=1, parameter CAPTURE_WIDTH=1) (',
            f'    input[STIMU_WIDTH - 1: 0] stimu,',
            f'    output[CAPTURE_WIDTH - 1: 0] capture);',
            f'',
            f'    {wires_str}',
            f'',
            f'    assign {{ {", ".join(input_pins)} }} = stimu;',
            f'    assign  # 0.1 capture = {{ {", ".join(output_pins)} }};',
            f'    <cell_name> u_<cell_name>({conn_str});',
            f'endmodule',
            f''
        ])
        wfp.write(temp.replace('<module_name>', 'ref_model').replace('<cell_name>', cell_vars.cell_name))
        wfp.write(temp.replace('<module_name>', 'spice_duv').replace('<cell_name>', f'{cell_vars.cell_name}_WRAPPER'))


def _deploy_cmd(wrap_v: str, partition_file: str, parameter_file: str):
    script = 'run'
    top_sv = os.path.join(_MY_DIR, 'top.sv')
    eda_env = os.path.join(_MY_DIR, 'eda.env')
    with open(script, 'w') as fp:
        fp.write('\n'.join([
            f'#!/bin/csh -f',
            f'',
            f'source {eda_env}',
            f'',
            f'vcs -kdb -full64 -debug_access+all -error=TFIPC-L -LDFLAGS -lnuma +notimingcheck +nospecify \\',
            f'    -sverilog {top_sv} {wrap_v} \\',
            f'    -lca +ad={partition_file} \\',
            f'    -parameters {parameter_file} \\',
            f'    -l compile.log',
            f'',
            f'./simv -ad_runopt=noa2dopt +COMPARE -l simv.log',
            f''
        ]))
    os.chmod(script, os.stat(script).st_mode | 0o100)


def deploy():
    partition_file, parameter_file, spice_wrap_file, verilog_wrap_file = sys.argv[1:]
    cell_vars = _CellVars()
    cell_vars.cell_name = os.getenv('CELL_NAME')
    cell_vars.process = os.getenv('PROCESS')
    cell_vars.spice_file = os.getenv('SPICE_FILE')
    cell_vars.verilog_file = os.getenv('VERILOG_FILE')
    cell_vars.spice_lib = os.getenv('SPICE_LIB')
    _deploy_partition(cell_vars, partition_file, spice_wrap_file)
    _deploy_parameter(cell_vars, parameter_file)
    _deploy_spice(cell_vars, spice_wrap_file)
    _deploy_verilog(cell_vars, verilog_wrap_file)
    _deploy_cmd(verilog_wrap_file, partition_file, parameter_file)


if __name__ == '__main__':
    deploy()
