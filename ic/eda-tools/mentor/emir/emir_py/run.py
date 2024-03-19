import argparse
import logging
import os.path
from logHandler import LogHandler

from emirFlow import EmirMgr, LN08LPP, LN04LPP

_DEMO_PATH = '/teamwork/dept/aip/CAD/scripts/demo/emir'
_CALIBRE_HOME = '/eda-tools/mentor/calibre202104/aoj_cal_2021.4_25.11'
_SIM_TOOL = '/eda-tools/cadence/SPECTRE191/bin/spectre'


def parse_args():
    parser = argparse.ArgumentParser(
        prog='emir',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='emir flow',
        epilog=f'demo: {_DEMO_PATH}'
    )

    parser.add_argument('-c', '--config', required=True, help='specify config file')
    parser.add_argument('-p', '--process', required=True, choices=[LN08LPP, LN04LPP],
                        help=f'specify process, choices: {LN08LPP}, {LN04LPP}')
    parser.add_argument('-w', '--workspace', default='./workspace',
                        help='specify workspace directory, default: ./workspace')
    parser.add_argument('-r', '--report_dir', default='./reports',
                        help='specify report directory, default: ./reports')
    parser.add_argument('-q', '--queue', default='normal', help='specify lsf queue, default: normal')
    parser.add_argument('-mj', '--max_jobs', type=int, default='1000',
                        help='specify max running lsf jobs, default: 1000')
    parser.add_argument('-ch', '--calibre_home', default=_CALIBRE_HOME,
                        help=f'specify calibre home, default: {_CALIBRE_HOME}')
    parser.add_argument('-s', '--spectre', default=_SIM_TOOL, help=f'specify spectre path, default: {_SIM_TOOL}')

    return parser.parse_args()


def _setLog():
    logging.getLogger('lsf').setLevel(logging.WARNING)
    logging.getLogger().setLevel(logging.INFO)
    logging.getLogger().addHandler(LogHandler())


def main():
    args = parse_args()
    _setLog()
    config = args.config
    process = args.process
    workspace = args.workspace
    reportDir = args.report_dir
    queue = args.queue
    mj = args.max_jobs
    calibreHome = args.calibre_home
    spectre = args.spectre
    if not os.path.exists(calibreHome):
        raise Exception(f'Invalid calibre home: {calibreHome}, path does not exist')
    if not os.path.exists(spectre):
        raise Exception(f'Invalid spectre: {spectre}, path does not exist')
    EmirMgr(calibreHome, spectre, config, workspace, process, reportDir).run(queue, mj)
