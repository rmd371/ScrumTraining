describe("shield", function() {
    let shield;
    let game;

    beforeEach(() => {
        game = new Game();
        shield = new Shield(game);
        spyOn(game, "damageRandomSystem");
    });

    it ('starts out lowered', function() {
        expect(shield.isUp).toBe(false);
    });

    it ('can be raised', function() {
        shield.raise();
        expect(shield.isUp).toBe(true);
    });

    it ('should start with 9001 units of energy', function() {
        expect(shield.energyLevel).toBe(9001);
    });

    it ('should transfer 10 units of energy', function() {
        const origEnergyLevel = shield.energyLevel;
        shield.transferEnergy(10);
        expect(shield.energyLevel).toBe(origEnergyLevel + 10);
    });

    it ('should have a maximum of 10000', function() {
        const energyToGetTo10000PlusOne = (10000 - shield.energyLevel) + 1;
        shield.transferEnergy(energyToGetTo10000PlusOne);
        expect(shield.energyLevel).toBe(10000);
    });

    it ('should have a minimum of 0', function() {
        const currentEnergyPlusOne = shield.energyLevel + 1; 
        shield.transferEnergy(-currentEnergyPlusOne);
        expect(shield.energyLevel).toBe(0);
    });

    it ('should damage a random subsystem when shield is up and amount energy fire is greater than energy level', function() {
        const currentEnergyMinusOne = shield.energyLevel - 1;

        shield.transferEnergy(-currentEnergyMinusOne);
        shield.raise();
        shield.enemyFire();
        
        expect(game.damageRandomSystem).toHaveBeenCalled();
    });

    it ('should not remove energy when shield is down', function() {
        const currentEnergy = shield.energyLevel;

        shield.enemyFire();
        
        expect(currentEnergy).toBe(shield.energyLevel);
    });
});
