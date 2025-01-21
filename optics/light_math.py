import numpy as np
from operator import mul
from itertools import accumulate
from math import sin, pi


__all__ = []


"""
This module contains some light math 
(miscellaneous functions implementing various optical equations).
"""


def find_beam_diameter(beam_diameter: float, *telescopes: float) -> float:
    """
    Calculate the beam diameter after passing through a series of telescopes.

    :param beam_diameter: The initial beam diameter (mm).
    :param telescopes: The magnification factor of each telescope.
    :returns: The beam diameter after passing through the telescopes.
    """
    vector = [beam_diameter, *telescopes]
    return list(accumulate(vector, mul))[-1]


def find_effective_na(
    numerical_aperture: float,
    slm_image_width: float,
    back_focal_plane_diameter: float,
) -> float:
    """
    Calculate the effective numerical aperture of a system

    :param numerical_aperture: The numerical aperture of the objective lens.
    :param slm_image_width: The width of SLM image (mm).
    :param back_focal_plane_diameter: The diameter of the back focal plane (mm).
    :returns: The effective numerical aperture of the system.
    """
    return numerical_aperture * slm_image_width / back_focal_plane_diameter


def find_diffraction_efficiency(levels: int) -> float:
    return 100.0 * (sin(pi / levels) / (pi / levels)) ** 2


def find_rayleigh_length(
    wavelength: Number,
    beam_diameter: Optional[Number] = None,
    n: Number = 1,
    w0: Optional[Number] = None,
) -> float: ...


def find_diffraction_limit(
    wavelength: Number,
    f: Number,
    beam_diameter: Optional[Number] = None,
    w0: Optional[Number] = None,
) -> float: ...


def complete_lens_makers_equation(): ...


def find_phase_offset(): ...


def find_xy_resolution(): ...


def find_z_resolution(): ...


def find_depth_of_field(): ...


def find_radiant_flux(): ...
