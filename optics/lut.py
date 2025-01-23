import numpy as np
from pydantic import BaseModel, Field, ConfigDict, field_validator


class LUT(BaseModel):
    """
    Look-up table for a specific element

    :var key: Name of the LUT
    :var phase: Phase values
    :var values: Corresponding values
    """

    model_config = ConfigDict(frozen=False, validate_assignment=True, extra="forbid")
    key: str
    phase: np.ndarray
    values: np.ndarray

    @field_validator("phase", mode="after")
    @classmethod
    def validate_phase(cls, phase: np.ndarray) -> np.ndarray:
        """
        Validate the phase values are non-negative values between 0-2Pi
        """
        assert (phase >= 0).all() and (phase <= 2 * np.pi).all()
        return phase

    @field_validator("values", mode="after")
    @classmethod
    def validate_values(cls, values: np.ndarray) -> np.ndarray:
        """
        Validate the values are non-negative values
        """
        assert (values >= 0).all()
        return (
            values
            if values.dtype == np.uint8
            else values.astype(np.uint8, casting="unsafe")
        )


# Boot up
# stripes
# measure 0v1
