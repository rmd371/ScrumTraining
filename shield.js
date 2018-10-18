class Shield {
	constructor(game, energyLevel = 9001) {
		this.isUp = false;
		this.energyLevel = energyLevel;
		this.damaged = false;
		this.game = game;
	}

	raise() {
		this.isUp = true;
	}

	transferEnergy(energyToTransfer) {
		this.energyLevel = Math.max(0, Math.min(this.energyLevel + energyToTransfer, 10000));
	}

	damage() {
		this.damaged = true;
	}

	enemyFire() {
		const energyToRemove = 1000;
		if(this.isUp) {
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
