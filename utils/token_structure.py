# structure of tokens defined


class SMTM_token:

    def __init__(self) -> None:
        super().__init__()

    def __str__(self) -> str:
        return super().__str__()

    def __repr__(self) -> str:
        return super().__repr__()

# if we want to have hash, both eq and hash should be defined.
# ideally has has to return a number.
    def __eq__(self, o: object) -> bool:
        return super().__eq__(o)

    def __hash__(self) -> int:
        return super().__hash__()


