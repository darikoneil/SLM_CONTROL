from enum import IntEnum
from optics.types import EnumNameValueMismatchError


"""
////////////////////////////////////////////////////////////////////////////////////////
// Enumerations
////////////////////////////////////////////////////////////////////////////////////////
"""


class _IntEnum(IntEnum):
    """
    :class:`IntEnum <enum.IntEnum>` that can be serialized and deserialized.
    """

    @classmethod
    def __deserialize__(cls, value: str) -> "_ExporgoIntEnum":
        if isinstance(value, str):
            name, value = value[1:-1].split(", ")
            value = int(value)
        elif isinstance(value, tuple):
            name, value = value
        else:
            raise TypeError(f"Cannot deserialize {value} into {cls.__name__}")
        enum_ = cls(value)

        try:
            assert enum_.name == name
        except AssertionError as exc:
            raise EnumNameValueMismatchError(cls, name, value) from exc
        return enum_

    def __serialize__(self) -> str:
        return f"({self.name}, {self.value})"


class PathConfiguration(_IntEnum):
    """
    Configuration for a specific optical path

    :var IMAGING_SCANNED: Imaging with a scanned beam (galvo-galvo, resonant-galvo)
    :var IMAGING_SCANLESS: Imaging with a scanless beam (SLM)
    :var STIMULATION_SPIRAL: Stimulation with a spiral beam
    :var STIMULATION_HYBRID: Stimulation with a hybrid strategy
    :var STIMULATION_SCANLESS: Stimulation with a scanless beam (SLM)
    """

    #: Imaging with a scanned beam (galvo-galvo, resonant-galvo)
    IMAGING_SCANNED = 0
    #: Imaging with a scanless beam (SLM)
    IMAGING_SCANLESS = 1
    #: Stimulation with a spiral beam
    STIMULATION_SPIRAL = 2
    #: Stimulation with a hybrid strategy
    STIMULATION_HYBRID = 3
    #: Stimulation with a scanless beam (SLM)
    STIMULATION_SCANLESS = 4
