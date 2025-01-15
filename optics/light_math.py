import numpy as np
from operator import mul
from itertools import accumulate


__all__ = [

]


"""
This module contains miscellaneous functions implementing various optical equations.
"""


def calculate_beam_diameter(beam_diameter: float, *telescopes: float) -> float:
    """
    Calculate the beam diameter after passing through a series of telescopes.

    :param beam_diameter: The initial beam diameter.
    :param telescopes: The magnification factor of each telescope.
    :returns: The beam diameter after passing through the telescopes.
    """
    vector = [beam_diameter, *telescopes]
    return list(accumulate(vector, mul))[-1]
