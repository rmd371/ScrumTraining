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

	transferEnergy(energyToTransfer) {
		this.energyLevel = Math.max(0, Math.min(this.energyLevel + energyToTransfer, 10000));
	}

	enemyFire(energyToRemove = 1000) {
		// const energyToRemove = 1000;
		if(this.isUp && this.damaged === false) {
			if(this.energyLevel >= energyToRemove) {
				this.transferEnergy(-energyToRemove);
			}
			else {
				if(this.energyLevel > 0) {
					this.transferEnergy(-this.energyLevel);
				}
				this.game.damageRandomSystem();
			}
		}
		else {
			this.game.damageRandomSystem();
		}
	}
}
