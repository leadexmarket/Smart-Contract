var LEAD = artifacts.require("./LEAD.sol");
var PreSale = artifacts.require("./PreSale.sol");
var TokenSale = artifacts.require("./TokenSale.sol");

module.exports = function (deployer, network, accounts) {
    deployer.deploy(LEAD).then(function () {
        return LEAD.deployed();
    }).then(function (token_instanse) {
    	// 1535760000 - 1.09.2018
    	// 1541030400 - 1.11.2018
    	// 0xadf28828d53c60f8BA8f43802eB4aF2eF538f8a1, 1535760000, 1541030400, 0xbafb633a044DF0b67DDd15AB1CDB2959d8999898
        return deployer.deploy(PreSale, token_instanse.address, 1535760000, 1541030400, accounts[8]).then(function () {
            return PreSale.deployed();
        }).then(function (presale_instanse) {
            token_instanse.setSaleAgent(presale_instanse.address);
	        // 1541030400 - 1.11.2018
	    	// 1546300800 - 1.01.2019
            return deployer.deploy(TokenSale, token_instanse.address, 1541030400, 1546300800, accounts[8]).then(function () {
            	return TokenSale.deployed();
	        }).then(function (tokensale_instanse) {
	            token_instanse.setSaleAgent2(tokensale_instanse.address);
	        });
        });
    });
};
