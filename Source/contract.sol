// Block Chain University Spring 2015
// Huang Pan
contract bank {

	// Global State Variables
	uint lastTimeStamp; // Time Stamp of last updated block

	// General bank parameters
	struct myBank {
		address ownerAddr; // owner; need to implement multisig elders
		uint reserve; // Reserve = sum(savings) - sum(loans) + capital injection
		uint reservePct; // Reserve ratio, in %; percentage of bank capital to keep in reserve
		uint annualSaveRateInPct; // Annual Savings Rate in %, compounded weekly
		uint annualLoanRateInPct; // Annual Loan Rate in %, compounded weekly
		uint maxLoanPct; // Max loan amount as a % of savings account amount
	}

	// Savings account
	struct mySave {
		address ownerAddr; // account owner
		uint balance; // account balance
	}

	// Loan account
	struct myLoan {
		address ownerAddr; // account owner
		uint balance; // account balance
		uint maxLoanAmt; // current maximum loan amount
	}
	
	// Mappings
    mapping (address => myBank) villageBank;
    mapping (address => mySave) saver1;
    mapping (address => myLoan) loaner1;

    function bank() { // Constructor
	
		// Create Bank
        villageBank[msg.sender].ownerAddr = msg.sender;
		//villageBank[msg.sender].reserve = address(this).balance; 
		villageBank[msg.sender].reserve = 1000000000000000; // large reserve
		villageBank[msg.sender].reservePct = 50; 
		villageBank[msg.sender].annualSaveRateInPct = 2; 
		villageBank[msg.sender].annualLoanRateInPct = 6; 
		villageBank[msg.sender].maxLoanPct = 300; 
		
		// Create Savers
        saver1[msg.sender].ownerAddr = msg.sender;
        saver1[msg.sender].balance = 0;

		// Create Loaners
        loaner1[msg.sender].ownerAddr = msg.sender;
        loaner1[msg.sender].balance = 0;
        loaner1[msg.sender].maxLoanAmt = 0;
	
		// Log initialization time stamp
		lastTimeStamp = block.timestamp;
	
    }
	
    function calcInterest(uint rateP1, uint numBlocks) constant returns (uint rate) {
        uint rateT = rateP1;
		for (uint ix = 0; ix<numBlocks;ix++) {
			rateT *= rateP1/8192;
        }
        return rateT;
    }
	
    // Savings Deposit
    function deposit(uint amount) { 
        saver1[msg.sender].balance += amount; 
    }
	
    // Savings Withdrawal
    function withdraw(uint amount) {
		if (saver1[msg.sender].balance >= amount) {
			msg.sender.send(amount);
			saver1[msg.sender].balance -= amount;
		} else { // trying to withdraw more money than balance
			// (1) return err msg somehow?
			// (2) use in credit score if multiple times?
		}
    }

    // Get a loan
    function getLoan(uint amount, uint numBlocks) {
		uint finalAmount = (amount*calcInterest(loanRate, numBlocks))/8192;
		if (loaner1[msg.sender].balance >= finalAmount) {
			msg.sender.send(amount);
            loaner1[msg.sender].balance += finalAmount;
        } 
    }
	
    // Pay a loan off
    function payLoan() { // this function is close to the right
        if (loaner1[msg.sender].balance <= msg.value) {
            // some logic to actually take the money from the borrower,
            // and return any over-payment
            loaner1[msg.sender].balance = 0;
        } 
    }
	
    function payLoanStupid(uint payOff) {
        if (loaner1[msg.sender].balance == payOff) {
            loaner1[msg.sender].balance = 0;
        } 
    }

    function queryLoanBalance() constant returns (uint balance) {
        return loaner1[msg.sender].balance; 
	}
    function querySavingsBalance() constant returns (uint balance) {
        return saver1[msg.sender].balance; 
	}
    function queryOwner() constant returns (address addr) {
        return villageBank[msg.sender].ownerAddr; 
	}
    function queryBankBal() constant returns (uint bal) {
		return address(this).balance; 
	}
    function queryLoanRate() constant returns (uint rate) {
		return villageBank[msg.sender].annualLoanRateInPct; 
	}
    function querySaveRate() constant returns (uint rate) {
		return villageBank[msg.sender].annualSaveRateInPct; 
	}
    function queryReserve() constant returns (uint resrv) {
		return villageBank[msg.sender].reserve; 
	}
	
    function setSaveRate(uint rate) {
		if (msg.sender==villageBank[msg.sender].ownerAddr) {
			villageBank[msg.sender].annualSaveRateInPct=rate;
		}
	}
    function setLoanRate(uint rate) {
		if (msg.sender==villageBank[msg.sender].ownerAddr) {
			villageBank[msg.sender].annualLoanRateInPct=rate;
		}
	}
		
	function checkLoanFinal(uint amount, uint numBlocks) constant returns (uint retval){
        uint finalAmount = amount*calcInterest(loanRate, numBlocks);
		return finalAmount/8192;
	}
	
} // contract bank