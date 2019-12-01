# definition of user structure


class User:
    def __init__(self, name, surname, bank_account, email,
                 password, username, profile_pic, phone_number, country) -> None:
        # @todo: add lvl of protection for the sensitive data provide design for it.
        self.name = name
        self.surname = surname
        # can be null
        self.bank_account = bank_account
        # @todo: verification of email
        self.email = email
        self.password = password
        self.username = username
        # nullable
        self.profile_pic = profile_pic
        # @todo: verification of phone_number
        self.phone_number = phone_number
        # @todo: predefined country list.
        self.country = country

        super().__init__()

    def __str__(self) -> str:
        return super().__str__()

    def __repr__(self) -> str:
        return super().__repr__()
