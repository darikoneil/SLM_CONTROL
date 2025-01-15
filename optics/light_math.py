import numpy as np
from operator import mul
from itertools import accumulate
from math import sin, pi


__all__ = [

]


"""
This module contains miscellaneous functions implementing various optical equations.
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


def find_effective_na(numerical_aperture: float,
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


def find_phase_offset():
    ...

