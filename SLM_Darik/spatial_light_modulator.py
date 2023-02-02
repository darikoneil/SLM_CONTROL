from __future__ import annotations
from typing import Self, Union

import os
from ctypes import *  # Hate this type of import
from PIL import Image
import numpy as np


from .dev_tools.parsing import convert_optionals, require_full_path
from .dev_tools.validation import validate_exists, validate_path, validate_extension

cdll.LoadLibrary("Blink_SDK_C") # Load SDK


class SLM:
    """
    Instance factory for Meadowlark SLMs
    """
    slm_lib = CDLL("Blink_SDK_C")
    sdk_path = "C:\\Program Files\\Meadowlark Optics\\OverDrive Plus SDK"
    true_frames = c_int(3) # constant

    def __init__(self):

        self._bit_depth = c_uint(8)
        self._calibration_image = read_image("".join([sdk_path, "\\512white.bmp"]))
        self._is_nematic_type = c_bool(true)
        # noinspection PyTypeChecker
        self._regional_lut_file = read_lut("".join([sdk_path, "\\SLM_lut.txt"]))
        self._max_transients = c_uint(20)
        self._RAW_write_enable = c_bool(true)
        self._use_GPU = c_bool(true)
        self._slm_resolution = c_uint(512)

        self.constructed_okay = c_bool(false) # was sdk constructed properly
        self.num_boards_found = c_uint(false) # number of slm's found
        self.sdk = None # interface with slm (SDK)

    def __enter__(self):
        """
        Override default method and create interface with slm (SDK)

        :rtype: Self
        """
        self.sdk = self.slm_lib.Create_SDK(self.bit_depth, self.slm_resolution, byref(self.num_boards_found),
                                           byref(self.constructed_okay), self.is_nematic_type, self.RAW_write_enable,
                                           self.use_GPU, self.max_transients, self.regional_lut_file)

    @property
    def bit_depth(self) -> c_uint:
        """
        Bit depth for SLM (default 8-bit, 0-255)

        :rtype: c_uint

        """
        return self._bit_depth

    @bit_depth.setter
    def bit_depth(self, value: int) -> Self:
        """
        bit_depth setter

        :param value: desired bit depth (can be 8 or 16-bit)
        :rtype: Self
        """
        if value != 8 and value != 16:
            raise ValueError("Bit depth must be 8 or 16-bit")
        self._bit_depth = c_uint(value)

    @property
    def calibration_image(self) -> np.ndarray:
        """
        Calibration image for SLM

        :rtype: np.ndarray
        """
        return self._calibration_image

    @calibration_image.setter
    def calibration_image(self, path: Union[str, pathlib.Path]) -> Self:
        """
        calibration image setter

        :param path: path to calibration file
        :type path: str or pathlib.Path
        :rtype: Self
        """
        self._calibration_image = read_image("".join([sdk_path, path]))

    @property
    def is_nematic_type(self):
        """
        Boolean indicated whether the SLM is a nematic type SLM (almost always would be)

        :rtype: c_bool
        """
        return self._is_nematic_type

    @is_nematic_type.setter
    def is_nematic_type(self, flag: bool) -> Self:
        """
        nematic type setter

        :param flag: boolean indicating nematic type
        :type flag: bool
        :rtype: Self
        """
        assert(isinstance(flag, bool)) # make sure we passed a boolean here
        self._is_nematic_type = c_bool(flag)

    @property
    def regional_lut_file(self) -> c_char_p:
        """
        Regional lut file used during overdrive

        :rtype: c_char_p
        """
        return self._regional_lut_file

    @regional_lut_file.setter
    def regional_lut_file(self, path: Union[str, pathlib.Path]) -> Self:
        """
        lut file setter

        :param path: path to lut file
        :type path: str or pathlib.Path
        :rtype: Self
        """
        self._regional_lut_file = read_lut(path)

    @property
    def max_transients(self) -> c_uint:
        """
        The maximum number of transient frames calculated by overdrive plus algorithm

        :rtype: c_uint
        """
        return self._max_transients

    @max_transients.setter
    def max_transients(self, value) -> Self:
        """
        max transients setter

        :param value: maximum number of transient frames calculated by overdrive plus algorithm
        :type value: int
        :rtype: Self
        """
        self._max_transients = c_uint(value)

    @property
    def RAW_write_enable(self) -> c_bool:
        """
        Boolean indicating whether to use RAM for writing (almost always the case, faster)

        :rtype: c_bool
        """
        return self._RAW_write_enable

    @RAW_write_enable.setter
    def RAW_write_enable(self, flag: bool) -> Self:
        """
        raw write enable setter

        :param flag: boolean indicating whether to use RAM for writing
        :type flag: bool
        :rtype: Self
        """
        assert(isinstance(flag, bool))
        self._RAW_write_enable = c_bool(flag)

    @property
    def slm_resolution(self) -> c_uint:
        """
        Resolution of SLM (default 512)

        :rtype: c_uint
        """
        return self._slm_resolution

    @slm_resolution.setter
    def slm_resolution(self, value: int) -> Self:
        """
        slm_resolution setter

        :param value: desired resolution (SDK assumes square resolution; 256 or 512)
        :rtype: Self
        """
        if value not in [256, 512]:
            raise ValueError("SLM resolution must be 256 or 512")
        self._slm_resolution = c_uint(512)

    @property
    def use_GPU(self) -> c_bool:
        """
        Boolean indicating whether to use GPU for phase calculations (overdrive)

        :rtype: c_bool
        """
        return self._use_GPU

    @use_GPU.setter
    def use_GPU(self, flag: bool) -> Self:
        """
        use gpu setter

        :param flag: boolean indicating whether to sue gpu
        :type flag: bool
        :rtype: Self
        """
        assert(isinstance(flag, bool))
        self._use_GPU = c_bool(flag)

    def power_on(self):
        # noinspection PyTypeChecker
        self.slm_lib.SLM_power(self.sdk, c_bool(true))

    def power_off(self):
        # noinspection PyTypeChecker
        self.slm_lib.SLM_power(self.sdk, c_bool(false))

    def set_basic_parameters(self):
        """
        Here we set some basic parameters for the SLM, load a blank image to the SLM, and upload linear lut

        :rtype: Self
        """
        self.slm_lib.Set_true_frames(self.sdk, self.true_frames)
        self.slm_lib.Write_cal_buffer(self.sdk, 1, self.calibration_image) # load blank calibration image
        self.slm_lib.Load_linear_LUT(self.sdk, 1) # load linear LUT

    def __exit__(self, exc_type, exc_value, traceback):
        """

        Override default method and destroy slm interface (SDK)

        :rtype: None
        """
        self.slm_lib.Delete_SDK(self.sdk)


@convert_optionals(permitted=(str, pathlib.Path), required=str, pos=0)
@validate_path(pos=0)
@validate_extension(required_extension=".bmp", pos=0)
@validate_exists(pos=0)
def read_image(path: str) -> np.ndarray:
    """
    Reads bmp as F-flattened np.ndarray

    :param path: path to image
    :type: str or pathlib.Path
    :return: flattened image
    :rtype: np.ndarray
    """
    # noinspection PyTypeChecker
    return np.asarray(Image.open(path)).flatten(order="F") # SDK expects images as column-flattened np.ndarray


@convert_optionals(permitted=(str, pathlib.Path), required=str, pos=0)
@validate_path(pos=0)
@validate_extension(required_extension=".txt", pos=0)
@validate_exists(pos=0)
def read_lut(path: str) -> c_char_p:
    """
    Reads lut .txt file

    :param path: path to lut file
    :type path: str or pathlib.Path
    :return: lut
    :rtype: c_char_p
    """
    # noinspection PyTypeChecker
    return c_char_p(path)
