local Enums = {}

export type BankAccountTypeEnum = "Savings" | "Spending"
export type CompanyBankAccountTypeEnum = "Spending"

Enums.BankAccountType = {
	Savings = "Savings",
	Spending = "Spending"
}

Enums.CompanyBankAccountTypeEnume = {
	Spending = "Spending"
}

return Enums
