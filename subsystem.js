class Subsystem {
    constructor() {

        // subsystems can take damaged, and be repaired
        //
        this.damageTakenInDays = 0;
        // this.damaged = false;
    }
    get damaged(){
        return this.damageTakenInDays !== 0;
    }

    damage(daysOfDamage) {
    this.damageTakenInDays += daysOfDamage;
    }

    restAndRepair(daysRested){
        this.damageTakenInDays =  Math.max(0, this.damageTakenInDays-daysRested);
    }
}
