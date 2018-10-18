class Shield {
	constructor(ship, energyLevel = 9001) {
		this.isUp = false;
		this.energyLevel = energyLevel;
		this.damaged = false;
		this.ship = ship;
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
				this.ship.damageRandomSystem();
			}
		}
		else {
			this.ship.damageRandomSystem();
		}
	}
}
