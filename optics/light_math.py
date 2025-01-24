import numpy as np
from operator import mul
from itertools import accumulate
from math import sin, pi
from collections import namedtuple
from types import SimpleNamespace


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


def complete_lens_makers_equation(): ...


def find_phase_offset(): ...


def find_xy_resolution(): ...


def find_z_resolution(): ...


def find_depth_of_field(): ...


def find_radiant_flux(): ...


def photodiode_battery_check(measured_voltage: float,
                             load_resistor: int = 50,
                             current_limiting_resistor: int = 1050,
                             battery_voltage: float = 9.0
                             ) -> namedtuple:

    expected_v_out = find_expected_v_out(load_resistor, current_limiting_resistor, battery_voltage)
    return (namedtuple('PhotodiodeBatteryCheck',
                      ['expected_v_out', 'measured_v_out', 'is_battery_ok'])
            (expected_v_out, measured_voltage, expected_v_out <= measured_voltage)
            )


def find_expected_v_out(load_resistor: int = 50,
                        current_limiting_resistor: int = 1050,
                        battery_voltage: float = 9.0) -> float:
    return battery_voltage * load_resistor / (load_resistor + current_limiting_resistor)


def find_bandwidth_and_response(load_resistor: int = 50,
                                diode_capacitance: float = 1e-12) -> float:
    return 1 / (2 * pi * load_resistor * diode_capacitance)


def find_rise_time(load_resistor: int = 50,
                   diode_capacitance: float = 1e-12) -> float:
    return 0.35 / (2 * pi * load_resistor * diode_capacitance)


def find_expected_current(peak_response: float, incident_power) -> float:
    return peak_response * incident_power


class Photodiode(SimpleNamespace):
    wavelength_range: tuple[int, int] = (200e-9, 1100e-9)
    peak_wavelength: int = 730e-9
    peak_response: float = 0.44
    shunt_resistance: float = 1e9
    diode_capacitance: 1e-12
    rise_time: 1e-9
    max_dark_current: 2.5e-9
    voltage_output: tuple[float, float] = (0.0, 10.0)
    bias_voltage: float = 10.0
    peak_response_at_920nm: float = 0.19


def peak_pulse_power(average_power: float, repetition_rate: float, pulse_width: float)-> float:
    """
    mw, MHz, fs
    """
    return average_power * 1e-3 / (repetition_rate *1e6 * pulse_width * 1e-15)
