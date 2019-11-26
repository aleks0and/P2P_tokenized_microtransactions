# structure of tokens defined

# @todo: definition of token types
# @todo: verify variable types

class SMTM_token:
    def __init__(self, name, surname, account_name, balance, email_address,
                 status, token_type, date_in, date_out) -> None:
        self.name = name
        self.surname = surname
        # can be nullable but we want to keep it as string?
        if account_name is None:
            self.account_name = 'None'
        else:
            self.account_name = account_name
        if type(balance) == int:
            self.balance = balance
        else:
            # assign different token type
            self.balance = balance
        self.email_address = email_address
        # 0 / 1 paid - pending
        self.status = status
        # from predefined list.
        self.token_type = token_type
        # datetime format
        self.date_in = date_in
        # date of completion None in other times.
        self.date_out = date_out
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


