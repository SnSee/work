import os.path
import logging
import shutil
import re

from jinja2 import Template
from lsfManager import LsfManager, Job, CheckPostStatus

_CELL = 'CELL'
_LAYOUT = 'LAYOUT'
_SOURCE = 'SOURCE'
_POST = 'POST'
_NET = 'NET'

LN08LPP = 'ln08lpp'
LN04LPP = 'ln04lpp'


def _getEtc(file: str) -> str:
    thisDir = os.path.dirname(__file__)
    etcDir = os.path.join(thisDir, 'etc')
    return os.path.join(etcDir, file)


class _EmirItem:
    def __init__(self, cell: str, layout: str, source: str, post: str, net: str):
        self.mCell = cell
        self.mLayout = layout
        self.mSource = source
        self.mPost = post
        self.mNet = net


class _Process:
    def __init__(self, name: str):
        self.mName = name
        self.mSvrf = ''
        self.mTech = ''
        self.mLayermap = ''

    def setSvrf(self, svrf: str):
        self.mSvrf = svrf

    def setTech(self, tech: str):
        self.mTech = tech

    def setLayermap(self, layermap: str):
        self.mLayermap = layermap


class _EmirFlow:
    def __init__(self, runDir: str, reportDir: str, item: _EmirItem, process: _Process, calibreHome: str, spectre: str):
        self._mRunDir = runDir
        self._mReportDir = reportDir
        self._mItem = item
        self._mProcess = process
        self._mCalibreHome = calibreHome
        self._mSpectre = spectre
        self._mLvsReport = os.path.join(runDir, 'lvs.report')

    @classmethod
    def _writeTemplate(cls, out: str, tf: str, var: dict[str, str]):
        tf = _getEtc(tf)
        with open(tf) as fp:
            template = Template(fp.read())
        content = template.render(var)
        with open(out, 'w') as fp:
            fp.write(content)

    def _makeEmirConf(self):
        confFile = os.path.join(self._mRunDir, 'emir.conf')
        varDict = {
            'tech_file': self._mProcess.mTech,
            'layermap_file': self._mProcess.mLayermap,
            'nets': self._mItem.mNet,
        }
        self._writeTemplate(confFile, 'emir.conf', varDict)

    def _makeXactTemplate(self) -> str:
        varDict = {
            'layout': self._mItem.mLayout,
            'source': self._mItem.mSource,
            'cell': self._mItem.mCell,
            'lvs_report': self._mLvsReport,
            'svrf': self._mProcess.mSvrf,
        }
        tf = '_template_xact.svrf_'
        out = os.path.join(self._mRunDir, tf)
        self._writeTemplate(out, tf, varDict)
        return tf

    def _makeSp(self):
        with open(self._mItem.mPost) as fp:
            lines = fp.readlines()
        newSp = os.path.join(self._mRunDir, f'{self._mItem.mCell}_post.sp')
        with open(newSp, 'w') as fp:
            inserted = False
            for line in lines:
                if not inserted and line.startswith('.option'):
                    fp.write(f'simulator lang=spectre\n')
                    fp.write(f'dspf_include "{self._mItem.mCell}.dspf"\n')
                    fp.write(f'simulator lang=spice\n')
                    fp.write('\n')
                    inserted = True
                fp.write(line)

    def makeEnv(self) -> str:
        sourceFile = _getEtc(f'sourceme_xact.{self._mProcess.mName}')
        assert os.path.exists(sourceFile), sourceFile

        xactFile = self._makeXactTemplate()
        self._makeEmirConf()
        self._makeSp()

        varMap = {
            'sourceme': sourceFile,
            'MGC_HOME': self._mCalibreHome,
            'cell': self._mItem.mCell,
            'xact': xactFile,
            'spectre': self._mSpectre,
        }
        runSp = os.path.join(self._mRunDir, f'run_{self._mItem.mCell}.csh')
        self._writeTemplate(runSp, 'run.csh', varMap)
        os.system(f'chmod +x {runSp}')
        return runSp

    def _checkLvsLog(self):
        if not os.path.exists(self._mLvsReport):
            logging.error(f'LVS report not found: {self._mLvsReport}')
            return
        pat = re.compile(r'#\s*(IN)?CORRECT\s*#')
        with open(self._mLvsReport) as fp:
            for line in fp:
                if pat.search(line):
                    if 'INCORRECT' in line:
                        logging.error(f'LVS incorrect, check {self._mLvsReport}')
                    break

    def _checkEmir(self):
        emirDir = os.path.join(self._mRunDir, f'{self._mItem.mCell}_post.raw')
        emRpt = os.path.join(emirDir, f'{self._mItem.mCell}_post.emirtap.rpt_em')
        irRpt = os.path.join(emirDir, f'{self._mItem.mCell}_post.emirtap.rpt_ir')
        if not os.path.exists(emRpt):
            logging.error(f"Failed to generate em report: {emRpt}")
        else:
            shutil.copy2(emRpt, self._mReportDir)
        if not os.path.exists(irRpt):
            logging.error(f"Failed to generate ir report: {irRpt}")
        else:
            shutil.copy2(irRpt, self._mReportDir)

    def checkLog(self):
        self._checkLvsLog()
        self._checkEmir()


class _ConfigParser:
    def __init__(self, configFile: str, process: str):
        self._mConfigFile = configFile
        self._mItems: dict[str, _EmirItem] = {}
        self._mLine = 0
        self._mProcess = self._parseProcess(process)
        self._parse()

    @staticmethod
    def _parseProcess(process: str) -> _Process:
        settings = {}
        with open(_getEtc('process.cfg')) as fp:
            curProcess = None
            i = 0
            for line in fp:
                i += 1
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                parts = [p.strip() for p in line.split(':')]
                if len(parts) != 2:
                    raise Exception(f'process config format error, line {i}')
                key, val = parts
                if key == 'process':
                    curProcess = _Process(val)
                    settings[val] = curProcess
                elif key == 'svrf_template':
                    curProcess.setSvrf(val)
                elif key == 'tech':
                    curProcess.setTech(val)
                elif key == 'layermap':
                    curProcess.setLayermap(val)
                else:
                    raise Exception(f'Invalid process config setting, line {i}')
        return settings[process]

    def getProcess(self) -> _Process:
        return self._mProcess

    def getItems(self) -> dict[str, _EmirItem]:
        return self._mItems

    def _raise(self, msg: str):
        raise Exception(f"{msg}, file: {self._mConfigFile}, line: {self._mLine}")

    def _addItem(self, values: dict):
        for key, value in values.items():
            if value is None:
                self._raise(f'{key} is not set')
        cell = values[_CELL]
        if cell in self._mItems:
            self._raise(f'Cell {cell} is already defined')
        self._mItems[cell] = _EmirItem(cell, values[_LAYOUT], values[_SOURCE], values[_POST], values[_NET])

    def _parse(self):
        globalVar = {}
        with open(self._mConfigFile) as fp:
            isGlobal = False
            for line in fp:
                self._mLine += 1
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if line == '.global':
                    isGlobal = True
                elif line == '.section':
                    values = {_CELL: None, _LAYOUT: None, _SOURCE: None, _POST: None, _NET: None}
                elif line == '.end':
                    if isGlobal:
                        isGlobal = False
                    else:
                        for key, val in values.items():
                            if val is None:
                                values[key] = globalVar.get(key, None)
                        self._addItem(values)
                else:
                    parts = [p.strip() for p in line.split(':')]
                    if len(parts) != 2:
                        self._raise(f'Invalid file format')
                    key, value = parts
                    if key in [_LAYOUT, _SOURCE, _POST]:
                        value = os.path.abspath(value)
                    if isGlobal:
                        globalVar[key] = value
                    else:
                        if key in values:
                            values[key] = value
                        else:
                            self._raise(f'Invalid key: {key}')


class EmirMgr:
    def __init__(self, calibreHome: str, spectre: str, configFile: str, workspace: str, process: str, reportDir: str):
        self._mCalibreHome = calibreHome
        self._mSpectre = spectre
        self._mWorkspace = os.path.abspath(workspace)
        self._mReportDir = os.path.abspath(reportDir)
        cp = _ConfigParser(configFile, process)
        self._mItems = cp.getItems()
        self._mProcess = cp.getProcess()
        self._mJobs = 0
        self._mFinishedJobs = 0
        self._mEfs: dict[str, _EmirFlow] = {}

    def _showProgress2(self, job: Job) -> CheckPostStatus:
        self._mFinishedJobs += 1
        print(f'\rfinished: {self._mJobs}/{self._mJobs}    ', end='')
        if self._mFinishedJobs == self._mJobs:
            print()
        self._mEfs[job.bsubCmd].checkLog()
        return CheckPostStatus.OK

    def run(self, queue: str, maxJobs: int):
        if not os.path.exists(self._mWorkspace):
            os.mkdir(self._mWorkspace)
        if not os.path.exists(self._mReportDir):
            os.mkdir(self._mReportDir)
        lm = LsfManager()
        lm.setMaxRunning(maxJobs)
        for cell, item in self._mItems.items():
            runDir = os.path.join(self._mWorkspace, cell)
            if not os.path.exists(runDir):
                os.mkdir(runDir)
            log = os.path.join(runDir, 'lsf.log')
            err = os.path.join(runDir, 'lsf.err')
            if os.path.exists(log):
                open(log, 'w').close()
            if os.path.exists(err):
                open(err, 'w').close()
            ef = _EmirFlow(runDir, self._mReportDir, item, self._mProcess, self._mCalibreHome, self._mSpectre)
            runSp = ef.makeEnv()
            cmd = f'bsub -q {queue} -o {log} -e {err} -cwd {runDir} {runSp}'
            self._mEfs[cmd] = ef
            lm.addBsubCmd(cmd, postCallback=self._showProgress2)
            self._mJobs += 1

        logging.info('running emir ...')
        lm.runAll()
