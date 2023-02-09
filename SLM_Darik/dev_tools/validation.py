from __future__ import annotations
import pathlib
from functools import wraps
import string
from typing import Callable
from PPVD.parsing import parameterize, amend_args
from PPVD.style import TerminalStyle
from os import path
from os.path import exists
import numpy as np


@parameterize
def validate_phase_mask(function: Callable, pos: int = 0) -> Callable:
    """
    Decorator to validate phase masks before functions

    :param function: function to be decorated
    :type function: Callable
    :param pos: index of the argument to be validated
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        _phase_mask = args[pos]
        if not isinstance(_phase_mask, np.ndarray):
            raise TypeError(f"{TerminalStyle.GREEN} Input {pos}: {TerminalStyle.YELLOW}requires np.ndarray"
                            f"{TerminalStyle.RESET}")
        if len(_phase_mask.shape) != 1:
            raise AssertionError(f"{TerminalStyle.GREEN} Input {pos}: "
                                 f"{TerminalStyle.YELLOW}requires flat image (vector){TerminalStyle.RESET}")
        if np.min(_phase_mask) < 0 or np.max(_phase_mask) > 1:
            raise ValueError(f"{TerminalStyle.GREEN} Input {pos}: "
                                 f"{TerminalStyle.YELLOW}must be within range 0.0 - 1.0{TerminalStyle.RESET}")
        return function(*args, **kwargs)
    return decorator


@parameterize
def validate_image_mask(function: Callable, pos: int = 0) -> Callable:
    """
    Decorator to validate phase masks before functions

    :param function: function to be decorated
    :type function: Callable
    :param pos: index of the argument to be validated
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        _image_mask = args[pos]
        if not isinstance(_image_mask, np.ndarray):
            raise TypeError(f"{TerminalStyle.GREEN} Input {pos}: {TerminalStyle.YELLOW}requires np.ndarray"
                            f"{TerminalStyle.RESET}")
        if len(_phase_mask.shape) != 1:
            raise AssertionError(f"{TerminalStyle.GREEN} Input {pos}: "
                                 f"{TerminalStyle.YELLOW}requires flat image (vector){TerminalStyle.RESET}")
        return function(*args, **kwargs)
    return decorator
