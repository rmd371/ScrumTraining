class Game {
    constructor(ship) {
        this.ship = ship;
    }

    timePassed(days){
        this.ship.restAndRepair(days);
    }
}
