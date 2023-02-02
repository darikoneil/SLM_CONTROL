from __future__ import annotations
import pathlib
from functools import wraps
import string
from typing import Callable
from .dev_tools.parsing import parameterize, amend_args
from .dev_tools.style import TerminalStyle
from os import path
from os.path import exists
import numpy as np


@parameterize
def validate_exists(function: Callable, pos: int = 0) -> Callable:
    """
    Decorator for validating existence of paths

    :param function: function to be decorated
    :type function: Callable
    :param pos: index of the argument to be validated
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        string_input = str(args[pos])
        if not exists(string_input):
            raise FileNotFoundError(f"{TerminalStyle.GREEN}Invalid Path: "
                             f"{TerminalStyle.YELLOW} Could not locate  "
                                    f"{TerminalStyle.BLUE}{string_input}{TerminalStyle.RESET}")
        # noinspection PyArgumentList
        return function(*args, **kwargs)
    return decorator


@parameterize
def validate_extension(function: Callable, required_extension: str, pos: int = 0) -> Callable:
    """
    Decorator for validating extension requirements

    :param function: function to be decorated
    :type function: Callable
    :param required_extension: required extension
    :type required_extension: str
    :param pos: index of the argument to be validated
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        if not pathlib.Path(args[pos]).suffix:
            args = amend_args(args,  "".join([str(args[pos]), required_extension]), pos)
        if pathlib.Path(args[pos]).suffix != required_extension:
            raise ValueError(f"{TerminalStyle.GREEN}Input {pos}: {TerminalStyle.YELLOW}"
                             f"filepath must contain the required extension {TerminalStyle.BLUE}"
                             f"{required_extension}{TerminalStyle.RESET}")
        # noinspection PyArgumentList
        return function(*args, **kwargs)
    return decorator


@parameterize
def validate_path(function: Callable, pos: int = 0) -> Callable:
    """
    Decorator for validating paths

    :param function: function to be decorated
    :type function: Callable
    :param pos: index of the argument to be validated
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        string_input = str(args[pos])
        if [_char for _char in list(string_input) if _char is ":"].__len__() != 1:
            raise ValueError(f"{TerminalStyle.GREEN}Invalid Path: "
                             f"{TerminalStyle.YELLOW}No root detected: "
                             f"{TerminalStyle.GREEN}{string_input}{TerminalStyle.RESET}")
        if not set(string_input) <= set(string.ascii_letters + string.digits + "." + "\\" + ":" + "-" + "_"):
            raise ValueError(f"{TerminalStyle.GREEN}Invalid Path: "
                             f"{TerminalStyle.YELLOW}Filenames are limited to standard letters, digits, backslash, "
                             f"colon, hyphen, and underscore only."
                             f"{TerminalStyle.RESET}")
        # noinspection PyArgumentList
        return function(*args, **kwargs)
    return decorator


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
