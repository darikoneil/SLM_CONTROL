from __future__ import annotations
from typing import Self
import os
from ctypes import *  # Hate this type of import
from scipy import misc
from time import sleep
cdll.LoadLibrary("Blink_SDK_C")


class SLM:
    """
    Instance factory for Meadowlark SLMs
    """
    slm_lib = CDLL("Blink_SDK_C")
    sdk_path = "C:\\Program Files\\Meadowlark Optics\\OverDrive Plus SDK"
    true_frames = c_int(3)

    def __init__(self):
        self.sdk = None
        # noinspection PyTypeChecker
        self.lut_file = c_char_p("".join([sdk_path, "\\SLM_lut.txt"]))
        self.calibration_image = misc.imread("".join([sdk_path, "\\512white.bmp"]), flatten=0)
        self._bit_depth = c_uint(8)
        self._slm_resolution = c_uint(512)
        self.num_boards_found = c_uint(false)
        self.constructed_okay = c_bool(false)
        self.is_nematic_type = c_bool(true)
        self.RAW_write_enable = c_bool(true)
        self.use_GPU = c_bool(true)
        self.max_transients = c_uint(20)

    def __enter__(self):
        """
        Override default method and create interface with slm (SDK)

        :rtype: Self
        """
        self.sdk = self.slm_lib.Create_SDK(self.bit_depth, self.slm_resolution, byref(self.num_boards_found),
                                           byref(self.constructed_okay), self.is_nematic_type, self.RAW_write_enable,
                                           self.use_GPU, self.max_transients, self.lut_file)

    @property
    def bit_depth(self) -> c_uint:
        """
        Bit depth for SLM (default 8-bit, 0-255)

        :rtype: c_uint

        """
        return self._bit_depth

    @bit_depth.setter
    def bit_depth(self, value) -> Self:
        """
        bit_depth setter

        :param value: desired bit depth (can be 8 or 16-bit)
        :rtype: Self
        """
        if value != 8 and value != 16:
            raise ValueError("Bit depth must be 8 or 16-bit")
        self._bit_depth = c_uint(value)

    @property
    def slm_resolution(self) -> c_uint:
        """
        Resolution of SLM (default 512)

        :rtype: c_uint
        """
        return self._slm_resolution

    @slm_resolution.setter
    def slm_resolution(self, value) -> Self:
        """
        slm_resolution setter

        :param value: desired resolution (SDK assumes square resolution; 256 or 512)
        :rtype: Self
        """
        if value not in [256, 512]:
            raise ValueError("SLM resolution must be 256 or 512")
        self._slm_resolution = c_uint(512)

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



