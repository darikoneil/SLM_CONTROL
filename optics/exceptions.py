class EnumNameValueMismatchError(ValueError):
    """
    Raised when the name and value of a serialized enumeration do not match

    :param name: name of the enumeration

    :param value: value of the enumeration
    """

    def __init__(self, enum: Any, name: str, value: int):
        self.name = name
        self.value = value
        # noinspection PyCallingNonCallable
        super().__init__(
            f"Name {self.name} and value {self.value} of the enumeration do not match."
            f"Expected {enum.__name__}({self.name}, {enum(value)})."
        )
