class Shield extends Subsystem {
	constructor(game, energyLevel = 9001) {
		super();
		this.isUp = false;
		this.energyLevel = energyLevel;
		this.game = game;
	}

	raise() {
		this.isUp = true;
	}

	receiveEnergyFromShip(energyToTransfer) {
	    const storedEnergyLevel = this.energyLevel;
		this.energyLevel = Math.min(this.energyLevel + energyToTransfer, 10000);

		if (this.energyLevel > 10000) {
            const additionEnergyLevel =this.energyLevel - storedEnergyLevel;
            if (additionEnergyLevel > 0) {
                sendEnergyBacktoShip(additionEnergyLevel);
            }
		}
	}

	sendEnergyBacktoShip(energy){
	    //do something
    }

	enemyFire(energyToRemove = 1000) {
		// const energyToRemove = 1000;
		if(this.isUp && this.damaged === false) {
			if(this.energyLevel >= energyToRemove) {
				this.energyLevel -= energyToRemove;
			}
			else {
				if(this.energyLevel > 0) {
					this.receiveEnergyFromShip(-this.energyLevel);
				}
				this.game.damageRandomSystem();
			}
		}
		else {
			this.game.damageRandomSystem();
		}
	}
}
