#!/bin/env python3
import gdspy
import sys
import numpy as np

# 读写 gds
gl = gdspy.GdsLibrary()
gl.read_gds('input.gds', units='import')
gl.write_gds('output.gds')
# 使用导入的 gds 单位创建新的 library
gl2 = gdspy.GdsLibrary(unit=gl.unit, precision=gl.precision)


# 读取 polygon
gf = sys.argv[1]
p = gdspy.GdsLibrary()
p.read_gds(gf)
for cellName, cell in p.cells.items():
    print('=================')
    assert isinstance(cell, gdspy.Cell)
    for polygon in cell.polygons:
        assert isinstance(polygon, gdspy.Polygon)
        print('CELL:', cellName)
        print('LAYER:', polygon.layers)
        print('DATATYPE:', polygon.datatypes)
        print('POLYGONS:', polygon.polygons)
        poly1 = polygon.polygons[0]
        assert isinstance(poly1, np.ndarray)
        xs = poly1[:, 0]
        ys = poly1[:, 1]
        print('x0:', xs.min(), ', y0:', ys.min())
        print('x1:', xs.max(), ', y1:', ys.max())
        print()


# 创建 polygon
gl = gdspy.GdsLibrary(unit=p.unit, precision=p.precision)
cell = gl.new_cell('cell_name')
points = [(0, 0), (0, 1), (1, 1), (1, 0)]
poly = gdspy.Polygon(points, layer=10, datatype=0)
cell.polygons.append(poly)
