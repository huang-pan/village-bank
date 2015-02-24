contract bank {
    // General parameters
    address owner; // Bank owner
    uint reserve; // Reserve = sum(savings)-sum(loans)
    uint reserveRatio; // Reserve ratio

    // Info about savers
    uint16 saveRate; // 1+interest rate per block for savings in Q0.16
    mapping (address => uint) saveBalances;
    uint prevUpdateBlock; // Block number of last update block
    
    // Info about borrowers
    uint16 loanRate; // 1+interest rate per block for loans in Q0.16
    mapping (address => uint) loanBalances;
    mapping (address => uint) loanBlock; // Block when loan to be paid
    mapping (address => uint) creditScore;

    // Constructor
    function bank() {
        owner = msg.sender;
    }
    function calcInterest(uint rateP1, uint numBlocks)
                 constant returns (uint rate) {
        uint rateT = rateP1;
		for (uint ix = 0; ix<numBlocks;ix++) {
			rateT *= rateP1;
        }
        return rate;
    }

    // Savings Deposit
    function deposit() {
        // may need more logic to actually take the money
        saveBalances[msg.sender] += msg.value; // balances initialized to 0
    }
    // Savings Withdrawal
    function withdrawal(uint amount) {
		if (reserve >= amount) {
			if (saveBalances[msg.sender] >= amount) {
                // some logic to send the money to the withdrawer
                saveBalances[msg.sender] -= amount;
				reserve -= amount;
            } else { // trying to withdraw more money than balance
				// (1) return err msg somehow?
                // (2) use in credit score if multiple times?
            }
        } else { // not enough money in bank
            // (1) return err msg somehow
            // (2) queue people up for withdrawals
        }
    }

    // Get a loan
    function getLoan(address receiver, uint amount, uint numBlocks) {
		if (prevUpdateBlock < block.number) { // maybe this is always true?
        }

        uint finalAmount = amount*calcInterest(loanRate, numBlocks);
		if ((creditScore[msg.sender] >= finalAmount) ||
			(saveBalances[msg.sender] >= finalAmount)) {
            // some logic to actually send the money to the borrower
            loanBalances[msg.sender] += finalAmount;
        } // maybe send an error
    }
    // Pay a loan off
    function payLoan(address receiver) {
        if (loanBalances[msg.sender] <= msg.value) {
            // some logic to actually take the money from the borrower,
            // and return any over-payment
            loanBalances[msg.sender] = 0;
            if (loanBlock[msg.sender] == block.number) {
                creditScore[msg.sender] += loanBalances[msg.sender];
            }
        } 
    }
    // compound savings on a regular basis. This means 
//    function compoundSavings() {
//    }
	

    function queryLoanBalance() constant returns (uint balance) {
        return loanBalances[msg.sender];
    }
    function querySavingsBalance() constant returns (uint balance) {
        return saveBalances[msg.sender];
    }
    function queryOwner() constant returns (address addr) {
        return owner;
    }

}

