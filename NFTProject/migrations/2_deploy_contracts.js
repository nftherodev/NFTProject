const MarbleHero = artifacts.require("MarbleHero");

module.exports = function(deployer) {
	deployer.deploy(MarbleHero);
};
