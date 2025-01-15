from pydantic import BaseModel


"""
Generic configurations and settings live here
"""


class Objective(BaseModel):
    """
    Objective lens settings
    """
    magnification: float
    numerical_aperture: float
    working_distance: float # mm
    refractive_index: float
    field_of_view: tuple[float, float] # um
    back_focal_plane_diameter: float # mm
    parfocal_length: float # mm


class SLM(BaseModel):
    resolution: tuple[int, int]
    # um
    pixel_pitch: tuple[float, float]
    # mm
    array_size: tuple[float, float]
