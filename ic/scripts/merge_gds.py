#!/bin/env python

# 导入指定文件中的 gds 并合并到一个 cell 中

import argparse
import math
import gdspy
import numpy as np
from operator import attrgetter

_VALID_HEIGHT_RATIO = 0.8


class _Cell:
    def __init__(self, gdsCell: gdspy.Cell):
        self.gdsCell = gdsCell
        box = gdsCell.get_bounding_box()
        x1, y1 = box[0]
        x2, y2 = box[1]
        self.height = y2 - y1
        self.width = x2 - x1
        self.newX = 0
        self.newY = 0

    def setPos(self, newX: float, newY: float):
        self.newX = newX
        self.newY = newY


class _CellPack:
    def __init__(self, width: float):
        self.width = width
        self.totalHeight = 0
        self.widthSame = True
        self.cells: list[_Cell] = []

    def setWidthDiff(self):
        self.widthSame = False

    def add(self, cell: _Cell):
        self.totalHeight += cell.height
        self.cells.append(cell)

    def validHeight(self, maxH: float) -> bool:
        return self.totalHeight >= maxH * _VALID_HEIGHT_RATIO


class MergeCell:
    def __init__(self, outputCell: str, outputFile: str, gdsListFile: str, maxHeight: float):
        self.outputCell = outputCell
        self.outputFile = outputFile
        self.gdsFiles = self._getTargetGdsFiles(gdsListFile)
        self.maxHeight = maxHeight
        self._merge()

    @staticmethod
    def _getTargetGdsFiles(gdsListFile: str) -> set[str]:
        files = set()
        with open(gdsListFile) as fp:
            for line in fp:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                files.add(line)
        return files

    @staticmethod
    def _packSameWidth(cells: list[_Cell], maxHeight: float) -> list[_CellPack]:
        packCells = []
        curPack = None
        for cell in cells:
            if not curPack or curPack.width != cell.width or curPack.totalHeight + cell.height > maxHeight:
                curPack = _CellPack(cell.width)
                packCells.append(curPack)
            curPack.add(cell)
        return packCells

    @staticmethod
    def _addCellPack(cellPack: _CellPack, newX: float, newY: float = 0):
        for cell in cellPack.cells:
            cell.setPos(newX, newY)
            newY += cell.height

    @staticmethod
    def _mergePack(packCells: list[_CellPack]) -> list[_CellPack]:
        maxH = max([pc.totalHeight for pc in packCells])
        maxH = round(maxH, 6)
        print("try with max height:", maxH)
        taken = set()
        newPackCells = []
        for i in range(len(packCells)):
            if i in taken:
                continue
            manPc = packCells[i]
            newPackCells.append(manPc)
            if manPc.validHeight(maxH):
                continue

            curHeight = manPc.totalHeight
            for j in range(i + 1, len(packCells)):
                if j in taken:
                    continue
                subPc = packCells[j]
                if not subPc.validHeight(maxH) and curHeight + subPc.totalHeight < packCells[j - 1].totalHeight:
                    taken.add(j)
                    manPc.setWidthDiff()
                    for cell in subPc.cells:
                        manPc.add(cell)
                    curHeight += subPc.totalHeight
        return newPackCells

    def _tryWithHeight(self, cells: list[_Cell], maxH: float) -> tuple[float, float]:
        packCells = self._packSameWidth(cells, maxH)
        packCells.sort(key=lambda x: x.width, reverse=True)
        packCells = self._mergePack(packCells)
        packCells.sort(key=attrgetter('widthSame', 'totalHeight'), reverse=True)

        newX = 0
        for i, cellPack in enumerate(packCells):
            self._addCellPack(cellPack, newX)
            newX += cellPack.width
        maxH = max([pc.totalHeight for pc in packCells])
        maxH = round(maxH, 6)
        return newX, maxH

    def _merge(self):
        # load gds cells
        gdsLib = gdspy.GdsLibrary()
        for file in self.gdsFiles:
            gdsLib.read_gds(file)

        cells = [_Cell(c) for c in gdsLib.cells.values()]
        cells.sort(key=attrgetter('width', 'height'), reverse=True)
        maxH = self.maxHeight if self.maxHeight else math.sqrt(sum([c.height for c in cells]))
        while True:
            maxX, maxY = self._tryWithHeight(cells, maxH)
            if maxX >= 0.9 * maxY:
                break
            maxH *= 0.9
        self._write(cells)

    def _write(self, cells: list[_Cell]):
        outLib = gdspy.GdsLibrary()
        mergedCell = gdspy.Cell(self.outputCell)
        for cell in cells:
            newCell = cell.gdsCell.copy(cell.gdsCell.name, translation=np.array([cell.newX, cell.newY]))
            mergedCell.add(newCell)
        outLib.add(mergedCell)
        outLib.write_gds(self.outputFile)


def _parseArgs():
    parser = argparse.ArgumentParser(
        prog="merge_cell",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument('-c', '--cell_name', type=str, required=True, help='specify merged cell name')
    parser.add_argument('-o', '--output_gds', type=str, required=True, help='specify output gds file')
    parser.add_argument('-gl', '--gds_list', type=str, required=True, help='specify gds file list needed to be merged')
    parser.add_argument('-mh', '--max_height', type=float, required=False, help='specify max height of merged cells')
    return parser.parse_args()


if __name__ == "__main__":
    args = _parseArgs()
    _cellName = args.cell_name
    _outputGds = args.output_gds
    _gdsList = args.gds_list
    _maxHeight = args.max_height
    MergeCell(_cellName, _outputGds, _gdsList, _maxHeight)
