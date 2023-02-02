from __future__ import annotations
from typing import Callable, Tuple, Any
from functools import wraps
from .dev_tools.style import TerminalStyle
from os import getcwd
from os.path import isdir


def parameterize(decorator: Callable) -> Callable:
    """
    Function for decorating decorators with parameters

    Based on -> https://stackoverflow.com/questions/46734219/flask-error-with-two-parameterized-functions

    :param decorator: a decorator
    :type decorator: Callable
    """

    def outer(*args, **kwargs):

        def inner(func):
            # noinspection PyArgumentList
            return decorator(func, *args, **kwargs)

        return inner

    return outer


@parameterize
def convert_optionals(function: Callable, permitted: Tuple, required: Any, pos: int = 0) -> Callable:
    """
    Decorator that converts a tuple of permitted types to type supported by the decorated method

    :param function: function to be decorated
    :type function: Callable
    :param permitted: permitted types
    :type permitted: Tuple
    :param required: type required by code
    :type required: Any
    :param pos: index of argument to be converted
    :type pos: int
    """
    @wraps(function)
    def decorator(*args, **kwargs):
        allowed_input = args[pos]
        if isinstance(allowed_input, permitted):
            allowed_input = required(allowed_input)
        if not isinstance(allowed_input, required):
            raise TypeError(f"{TerminalStyle.GREEN}Input {pos}: {TerminalStyle.YELLOW}"
                            f"inputs are permitted to be of the following types "
                            f"{TerminalStyle.BLUE}{permitted}{TerminalStyle.RESET}")
        args = amend_args(args, allowed_input, pos)
        # noinspection PyArgumentList
        return function(*args, **kwargs)
    return decorator
