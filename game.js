class Ship {
	constructor() {
		this.shield = new Shield();
		this.engine = { damaged: false, damage: () => this.damaged = true }
		this.weapon = { damaged: false, damage: () => this.damaged = true }
	}

	damageRandomSystem() {
		const subsystemNbr = Math.floor(Math.random() * 3) + 1;

		if(subsystemNbr === 1) {
			this.shield.damage();
		}
		else if(subsystemNbr === 2) {
			this.engine.damage();
		}
		else if(subsystemNbr === 3) {
			this.weapon.damage();
		}
	}
}
