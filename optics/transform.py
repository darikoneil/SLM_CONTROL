from pydantic import BaseModel
from typing import NamedTuple


__all__ = [

]


"""
This file is for affine transform
"""

class Coordinates(NamedTuple):
    x: float
    y: float
    z: float


class TransformCalibration(BaseModel):
    coordinates: tuple[Coordinates, ...]
    zero_order: tuple[Coordinates, ...]
    first_order: tuple[Coordinates, ...]
    pix_step: float
    transform: tuple[Coordinates, Coordinates, Coordinates]
    field_of_view: tuple[float, float]
    pixels_per_line: int
    lines_per_frame: int
    zoom: float

