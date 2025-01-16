from pydantic import BaseModel, ConfigDict, Field, field_validator
from typing import Any, Literal
from optics.types import PathConfiguration


"""
////////////////////////////////////////////////////////////////////////////////////////
// Mutable
////////////////////////////////////////////////////////////////////////////////////////
"""


class Beam(BaseModel):
    """
    A beam of light

    :var key: Name of the beam
    :var diameter: Diameter of the beam in mm
    :var mode: Configuration of the beam's optical path
    :var wavelength: Wavelength of the beam in nm
    """
    model_config = ConfigDict(frozen=False,
                              validate_assignment=True,
                              extra="forbid")

    key: str
    diameter: float
    mode: PathConfiguration
    wavelength: float


class DAQ(BaseModel):
    """
    DAQ configuration

    :var key: Name of the DAQ
    :var counter: ID of counter channel
    :var analog_input: ID of analog input channel
    :var analog_output: ID of analog output channel
    """
    model_config = ConfigDict(frozen=False,
                              validate_assignment=True,
                              extra="forbid")

    key: str
    counter: int = Field(..., ge=0)
    analog_input: int = Field(..., ge=0)
    analog_output: int = Field(..., ge=0)


"""
////////////////////////////////////////////////////////////////////////////////////////
// Immutable
////////////////////////////////////////////////////////////////////////////////////////
"""


class Objective(BaseModel):
    """
    An objective lens

    :var key: Name of the objective
    :var magnification: Magnification of the objective
    :var numerical_aperture: Numerical aperture of the objective
    :var working_distance: Working distance of the objective in mm
    :var refractive_index: Refractive index of the objective
    :var field_of_view: Field of view of the objective in um
    :var back_focal_plane_diameter: Back focal plane diameter of the objective in mm
    :var parfocal_length: Parfocal length of the objective in mm
    :var using_orbital: Whether the objective is using the orbital attachment
    """
    model_config = ConfigDict(frozen=True, extra="forbid")

    key: str
    magnification: float = Field(..., ge=1)
    numerical_aperture: float = Field(..., gt=0)
    working_distance: float = Field(..., gt=0)# mm
    refractive_index: float = Field(1.33, gt=0)
    field_of_view: tuple[float, float]
    back_focal_plane_diameter: float = Field(..., gt=0)
    parfocal_length: float = 75
    using_orbital: bool = False

    @field_validator("field_of_view", mode="after")
    @classmethod
    def validate_field_of_view(cls, field_of_view: Any) -> tuple[float, float]:
        """
        Validate the field of view of the objective is a tuple of two nonzero floats
        """
        assert all((size > 0 for size in field_of_view))
        return field_of_view


class SLM(BaseModel):
    """
    A spatial light modulator

    :var key: Name of the SLM
    :var resolution: Resolution of the SLM in pixels
    :var pixel_pitch: Pixel pitch of the SLM in um
    :var array_size: Size of the SLM in mm
    """
    model_config = ConfigDict(frozen=True, extra="ignore")

    key: str
    resolution: tuple[int, int]
    pixel_pitch: tuple[float, float]
    array_size: tuple[float, float]

    @field_validator("resolution", mode="after")
    @classmethod
    def validate_resolution(cls, resolution: Any) -> tuple[int, int]:
        """
        Validate the resolution of the SLM is a tuple of two positive integers
        """
        assert all((size > 0 for size in resolution))
        return resolution

    @field_validator("pixel_pitch", "array_size", mode="after")
    @classmethod
    def validate_pixel_pitch(cls, pixel_pitch: Any) -> tuple[float, float]:
        """
        Validate the pixel pitch  and array size of the SLM is a tuple of two positive
        floats
        """
        assert all((pitch > 0 for pitch in pixel_pitch))
        return pixel_pitch
